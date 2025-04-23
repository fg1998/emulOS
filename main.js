const { app, BrowserWindow } = require('electron');
const path = require('path');

function createWindow() {
  const win = new BrowserWindow({
    width: 1280,
    height: 800,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: true,
      contextIsolation: false
    }
  });

  win.loadFile('renderer/index.html');
  win.webContents.openDevTools(); // DevTools ativado
}

app.whenReady().then(() => {
  createWindow();
  app.on('activate', function () {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', function () {
  if (process.platform !== 'darwin') app.quit();
});


const fs = require('fs');
const { ipcMain } = require('electron');

ipcMain.handle('toggle-favorite', (event, systemId) => {
  const dataPath = path.join(__dirname, 'data', 'emulators.json');
  const data = JSON.parse(fs.readFileSync(dataPath));
  let updated = false;

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
