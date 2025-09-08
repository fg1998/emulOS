// main.js
const { app, BrowserWindow, ipcMain, screen, dialog } = require("electron");
const path = require("path");
const fs = require("fs");
const fsp = fs.promises;
const { execFile } = require("child_process");
const { https } = require("follow-redirects");
const tar = require("tar");
const unzipper = require("unzipper");

// Helpers de path
function getBasePath() {
  return app.isPackaged ? process.resourcesPath : app.getAppPath();
}
function getDataPath() {
  return path.join(getBasePath(), "data");
}
function getOsName() {
  switch (process.platform) {
    case "win32": return "win";
    case "darwin": return "mac";
    default: return "linux";
  }
}

function createWindow() {
  const { width, height } = screen.getPrimaryDisplay().workAreaSize;
  const win = new BrowserWindow({
    x: 0,
    y: 0,
    width,
    height,
    fullscreen: true,
    autoHideMenuBar: true,
    webPreferences: {
      // Passa o basePath pro renderer
      additionalArguments: [
        `--appPath=${getBasePath()}`
      ],
      preload: path.join(__dirname, "preload.js"),
      nodeIntegration: true,
      contextIsolation: false,
    },
  });

  win.loadFile("renderer/index.html");
  // win.webContents.openDevTools(); // habilite se quiser
}

app.whenReady().then(() => {
  console.log("[EmulOS]", {
    isPackaged: app.isPackaged,
    resourcesPath: process.resourcesPath,
    appPath: app.getAppPath(),
    dataPath: getDataPath(),
  });
  createWindow();
  app.on("activate", () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") app.quit();
});

// === WIFI (nmtui via xterm) ===
ipcMain.on("wifiConfig", async (event) => {
  event.reply("writeLog", "Starting nmtui");
  const command = "xterm";
  const paramlist = "-fullscreen -e sudo nmtui".split(" ");
  execFile(command, paramlist, (error, stdout, stderr) => {
    if (error) {
      console.log(error);
      event.reply("logMessage", `Error: ${error.message}`);
      return;
    }
    if (stdout) event.reply("wifiLog", `stdout: ${stdout.trim()}`);
    if (stderr) event.reply("wifiLog", `stderr: ${stderr.trim()}`);
  });
});

// === RUN SYSTEM ===
ipcMain.on("run-system", (event, content) => {
  event.reply("writeLog", `Starting ${content.name}`);

  let emulatorPath = content.emulator.path.replace("${emulatorpath}", content.config.emulatorpath);
  let epTEMP = content.emulator.param
    ?.replace(/\$\{configpath\}/g, content.config.configpath)
    ?.replace(/\$\{biospath\}/g, content.config.biospath);
  let emulatorParam = epTEMP ? epTEMP.split(" ") : [];

  let spTEMP = content.parameter
    ?.replace(/\$\{configpath\}/g, content.config.configpath)
    ?.replace(/\$\{biospath\}/g, content.config.biospath);
  let systemParam = spTEMP ? spTEMP.split(" ") : [];

  let totalParam = [...emulatorParam, ...systemParam];

  // system tools (emulator "none")
  if (!emulatorPath) {
    emulatorPath = totalParam[0];
    totalParam = [];
  }

  event.reply("writeLog", emulatorPath + " " + totalParam.join(" "));

  execFile(emulatorPath, totalParam, (error, stdout, stderr) => {
    if (error) {
      console.log("****", error);
      event.reply("writeLog", `[red] Error: ${error.message}`);
      return;
    }
    if (stdout) event.reply("run-system", `stdout: ${stdout.trim()}`);
    if (stderr) event.reply("run-system", `stderr: ${stderr.trim()}`);
  });
});

// === FAVORITE (se quiser usar no futuro pelo main) ===
ipcMain.handle("toggle-favorite", async (_event, systemId) => {
  const dataFile = path.join(getDataPath(), `emulators.${getOsName()}.json`);
  const data = JSON.parse(fs.readFileSync(dataFile, "utf8"));
  let updated = false;

  // ajuste aqui conforme seu schema real
  (data.brands || []).forEach((brand) => {
    (brand.emulators || []).forEach((emu) => {
      (emu.systems || []).forEach((sys) => {
        if (sys.id === systemId) {
          sys.favorite = !sys.favorite;
          updated = true;
        }
      });
    });
  });

  if (updated) {
    fs.writeFileSync(dataFile, JSON.stringify(data, null, 2));
  }
  return updated;
});

// === OPEN FOLDER DIALOG ===
ipcMain.handle("open-folder-dialog", async () => {
  const win = BrowserWindow.getFocusedWindow();
  const result = await dialog.showOpenDialog(win, {
    title: "Selecione uma pasta",
    properties: ["openDirectory"],
  });
  if (result.canceled || result.filePaths.length === 0) return null;
  return result.filePaths[0];
});

// === DOWNLOAD & EXTRACT ===
ipcMain.handle("download-and-extract", async (_event, { url, extractTo }) => {
  return new Promise((resolve, reject) => {
    try {
      if (!fs.existsSync(extractTo)) fs.mkdirSync(extractTo, { recursive: true });
    } catch (e) {
      return reject(e);
    }

    const fileName = path.basename(url);
    const tempFile = path.join(extractTo, `temp_${fileName}`);
    const file = fs.createWriteStream(tempFile);

    _event.sender.send("downloadMessage", "Downloading ...");

    https.get(url, (response) => {
      if (response.statusCode !== 200) {
        reject(new Error(`Download error: ${response.statusCode}`));
        return;
      }

      const totalSize = parseInt(response.headers["content-length"] || "0", 10);
      let downloaded = 0;

      response.on("data", (chunk) => {
        downloaded += chunk.length;
        if (totalSize) {
          const percent = ((downloaded / totalSize) * 100).toFixed(2);
          _event.sender.send("download-progress", percent);
        }
      });

      response.pipe(file);

      file.on("finish", () => {
        _event.sender.send("downloadMessage", "File Downloaded");
        file.close(async () => {
          try {
            if (fileName.endsWith(".tar.gz") || fileName.endsWith(".tgz")) {
              _event.sender.send("downloadMessage", "Uncompressing ... WAIT !");
              await tar.x({ file: tempFile, cwd: extractTo, unlink: true });
            } else if (fileName.endsWith(".zip")) {
              await new Promise((res, rej) => {
                fs.createReadStream(tempFile)
                  .pipe(unzipper.Extract({ path: extractTo }))
                  .on("close", res)
                  .on("error", rej);
              });
            } else {
              throw new Error("File not supported");
            }
            fs.unlinkSync(tempFile);
            _event.sender.send("download-progress", 100);
            _event.sender.send("downloadMessage", "Extract done !");
            resolve("Download and extract done");
          } catch (err) {
            reject(err);
          }
        });
      });
    }).on("error", (err) => {
      fs.unlink(tempFile, () => reject(err));
    });
  });
});
