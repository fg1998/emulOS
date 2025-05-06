const { app, BrowserWindow, ipcMain, screen } = require('electron');
const path = require('path');
const fs = require('fs');
const { spawn } = require('child_process');

let mainWin;

function createWindow() {
  const { width, height } = screen.getPrimaryDisplay().workAreaSize;
  mainWin = new BrowserWindow({
    x: 0, y: 0,
    width, height,
    autoHideMenuBar: true,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: true,
      contextIsolation: false
    }
  });
  mainWin.loadFile('renderer/index.html');
}

app.whenReady().then(() => {
  createWindow();
  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

ipcMain.on('wifiConfig', (event) => {
  event.reply('writeLog', 'Starting nmtui');

  // 1) Minimiza a janela Electron
  if (mainWin) mainWin.minimize();

  // 2) Dispara xterm + nmtui em modo detached
  const child = spawn('xterm', ['-e', 'sudo', 'nmtui'], {
    detached: true,
    stdio: 'ignore'
  });
  child.unref();

  // 3) Força fullscreen com wmctrl após dar um tempinho
  setTimeout(() => {
    spawn('wmctrl', ['-r', 'nmtui', '-b', 'add,fullscreen']);
  }, 200);

  // 4) Quando fechar, restaura e foca a janela principal
  child.on('exit', () => {
    if (mainWin) {
      mainWin.restore();
      mainWin.focus();
    }
  });
});

ipcMain.on("run-system", (event, content) => {
  event.reply('writeLog', `Starting ${content.name}`);

  if (mainWin) mainWin.minimize();

  const emulatorPath  = content.emulator.path;
  const emulatorArgs  = content.emulator.param.split(' ');
  const systemArgs    = content.parameter.split(' ');
  const args          = [...emulatorArgs, ...systemArgs];

  const child = spawn(emulatorPath, args, {
    detached: true,
    stdio: 'ignore'
  });
  child.unref();

  setTimeout(() => {
    // adapta o título do window manager ao seu caso
    spawn('wmctrl', ['-r', content.name, '-b', 'add,fullscreen']);
  }, 200);

  child.on('exit', (code, signal) => {
    if (code !== 0) {
      event.reply('writeLog', `[red] Error: process exited with ${code || signal}`);
    }
    if (mainWin) {
      mainWin.restore();
      mainWin.focus();
    }
  });
});

ipcMain.handle('toggle-favorite', (event, systemId) => {
  const dataPath = path.join(__dirname, 'data', 'emulators.json');
  const data     = JSON.parse(fs.readFileSync(dataPath, 'utf-8'));
  let updated    = false;

  data.forEach(brand => {
    brand.emulators.forEach(emulator => {
      emulator.systems.forEach(system => {
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
