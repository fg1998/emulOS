
// === Confirm modal logic ===
const confirmModal = document.getElementById('confirmModal');
const confirmTitle = document.getElementById('confirmTitle');
const confirmMessage = document.getElementById('confirmMessage');
const confirmOk = document.getElementById('confirmOk');
const confirmCancel = document.getElementById('confirmCancel');

function openConfirm({ title, message, onConfirm }) {
  confirmTitle.textContent = title;
  confirmMessage.textContent = message;
  confirmModal.classList.remove('hidden');

  // Reset event handlers
  const newOk = confirmOk.cloneNode(true);
  const newCancel = confirmCancel.cloneNode(true);
  confirmOk.replaceWith(newOk);
  confirmCancel.replaceWith(newCancel);

  newOk.addEventListener('click', () => {
    confirmModal.classList.add('hidden');
    onConfirm();
  });
  newCancel.addEventListener('click', () => {
    confirmModal.classList.add('hidden');
  });
}

document.addEventListener('DOMContentLoaded', () => {
  const btnShutdown = document.getElementById('btnShutdown');
  const btnReboot = document.getElementById('btnReboot');
  const btnExitFrontend = document.getElementById('btnExitFrontend');

  if (btnShutdown) {
    btnShutdown.onclick = () => {
      openConfirm({
        title: 'Desligar Sistema',
        message: 'Tem certeza que deseja desligar o sistema?',
        onConfirm: () => window.ipcRenderer.send('shutdown-system')
      });
    };
  }
  if (btnReboot) {
    btnReboot.onclick = () => {
      openConfirm({
        title: 'Reiniciar Sistema',
        message: 'Tem certeza que deseja reiniciar o sistema?',
        onConfirm: () => window.ipcRenderer.send('reboot-system')
      });
    };
  }
  if (btnExitFrontend) {
    btnExitFrontend.onclick = () => {
      openConfirm({
        title: 'Sair do Frontend',
        message: 'Tem certeza que deseja sair do frontend?',
        onConfirm: () => window.ipcRenderer.send('exit-frontend')
      });
    };
  }
});

const wifi = require("node-wifi");
const si = require("systeminformation");

// Inicializa o node-wifi (usa interface padrão)
wifi.init({ iface: null });

async function checkWifiStatus() {
  console.log("🔍 Verificando redes disponíveis...\n");

  // Listar redes visíveis
  try {
    const networks = await si.wifiNetworks();
    console.log("📶 Redes próximas:");
    networks.forEach((net, i) => {
      console.log(` ${i + 1}. ${net.ssid} (${net.signalLevel}%)`);
    });
  } catch (err) {
    console.error("Erro ao listar redes com systeminformation:", err);
  }

  console.log("\n🔍 Verificando conexão atual...\n");

  // Verificar a conexão atual
  wifi.getCurrentConnections((err, connections) => {
    if (err) {
      console.error("Erro ao verificar conexão com node-wifi:", err);
      return;
    }

    if (connections.length > 0) {
      console.log("✅ Conectado ao Wi-Fi:", connections[0].ssid);
    } else {
      console.log("❌ Não conectado a nenhuma rede Wi-Fi");
    }
  });
}

checkWifiStatus();
