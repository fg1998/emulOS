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
