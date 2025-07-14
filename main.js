const { app, BrowserWindow, ipcMain, screen, dialog } = require("electron");
const path = require("path");
const fs = require("fs").promises;
const { stdout, stderr } = require("process");
const { system } = require("systeminformation");
const execFile = require("child_process").execFile;

function createWindow() {
  const { width, height } = screen.getPrimaryDisplay().workAreaSize;
  const win = new BrowserWindow({
    x: 0,
    y: 0,
    width: width,
    height: height,
    //kiosk: true,
    fullscreen: true,
    autoHideMenuBar: true,
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
      nodeIntegration: true,
      contextIsolation: false,
    },
  });

  win.loadFile("renderer/index.html");
  //win.webContents.openDevTools(); // DevTools ativado
}

app.whenReady().then(() => {
  createWindow();
  app.on("activate", function () {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on("window-all-closed", function () {
  if (process.platform !== "darwin") app.quit();
});

ipcMain.on("wifiConfig", async (event, content) => {
  event.reply("writeLog", "Starting nmtui");
  const command = "xterm";
  //const command = "/home/fg1998/emulators/zesarux/zesarux"
  const param = "-fullscreen -e sudo nmtui";
  paramlist = param.split(" ");

  const extProcess = execFile(command, paramlist, (error, stdout, stderr) => {
    if (error) {
      console.log(error);
      event.reply("logMessage", `Error: ${error.message}`);
      return;
    }
    if (stdout) event.reply("wifiLog", `stdout: ${stdout.trim()}`);
    if (stderr) event.reply("wifiLog", `stderr: ${stderr.trim()}`);
  });
});

ipcMain.on("run-system", (event, content) => {
  event.reply("writeLog", `Starting ${content.name}`);

  let emulatorPath = content.emulator.path.replace("${emulatorpath}", content.config.emulatorpath);

  let epTEMP = content.emulator.param.replace(/\$\{configpath\}/g, content.config.configpath).replace(/\$\{biospath\}/g, content.config.biospath);
  let emulatorParam = epTEMP ? epTEMP.split(" ") : []; //content.emulator.param ? content.emulator.param.split(' ') : "";
  let spTEMP = content.parameter.replace(/\$\{configpath\}/g, content.config.configpath).replace(/\$\{biospath\}/g, content.config.biospath);
  let systemParam = spTEMP ? spTEMP.split(" ") : [];
  let totalParam = [...emulatorParam, ...systemParam];

  event.reply("writeLog", emulatorPath + " " + totalParam.join(" "));

  //For system Tools - They are using 'none' as emulator
  if(emulatorPath === "") {
    emulatorPath = totalParam[0];
    totalParam = []
  }

  const extProcess = execFile(emulatorPath, totalParam, (error, stdout, stderr) => {
    if (error) {
      console.log("****", error);
      event.reply("writeLog", `[red] Error: ${error.message}`);
      return;
    }
    if (stdout) event.reply("run-system", `stdout: ${stdout.trim()}`);
    if (stderr) event.reply("run-system", `stderr: ${stderr.trim()}`);
  });
});

ipcMain.handle("toggle-favorite", (event, systemId) => {
  const dataPath = path.join(__dirname, "data", "emulators.json");
  const data = JSON.parse(fs.readFileSync(dataPath));
  let updated = false;

  data.forEach((brand) => {
    brand.emulators.forEach((emulator) => {
      emulator.systems.forEach((system) => {
        if (system.id === systemId) {
          system.favorite = !system.favorite;
          updated = true;
        }
      });
    });
  });

  if (updated) {
    fs.writeFileSync(dataPath, JSON.stringify(data, null, 2));
  }

  return updated;
});

ipcMain.handle("open-folder-dialog", async (event) => {
  const win = BrowserWindow.getFocusedWindow(); // pega a janela atual
  const result = await dialog.showOpenDialog(win, {
    title: "Selecione uma pasta",
    properties: ['openDirectory']
  });

  if (result.canceled || result.filePaths.length === 0) {
    return null;
  }

  return result.filePaths[0];
});





