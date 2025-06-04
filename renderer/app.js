const fs = require("fs");
const fsPromises = require('fs').promises;
const path = require("path");
const { ipcRenderer, contentTracing } = require("electron");
const { exec } = require("child_process");
const { json } = require("stream/consumers");
const { log } = require("console");

// IPC EVENTS

ipcRenderer.on("writeLog", (event, message) => {
  logMessage(message, false);
});



// fila de mensagens
const messageQueue = [];
let typingInProgress = false;

function logMessage(msg, error) {
  const now = new Date();
  const ts = `[${now.getHours().toString().padStart(2, "0")}:` +
             `${now.getMinutes().toString().padStart(2, "0")}:` +
             `${now.getSeconds().toString().padStart(2, "0")}] `;
  messageQueue.push({ text: ts + msg, isError: !!error });
  if (!typingInProgress) processQueue();
}

function processQueue() {
  if (messageQueue.length === 0) {
    typingInProgress = false;
    return;
  }
  typingInProgress = true;
  const { text, isError } = messageQueue.shift();

  const logContainer = document.getElementById("log-container");
  const logContent   = document.getElementById("log-content");
  const p = document.createElement("p");
  logContent.appendChild(p);

  // cursor bloco
  const cursor = document.createElement("span");
  cursor.classList.add("log-cursor");
  p.appendChild(cursor);

  // 1) Parseia o texto em segmentos [texto, cor]
  const segments = [];
  const regex = /\[([a-zA-Z]+)\]/g;
  let lastIndex = 0, match;
  while ((match = regex.exec(text)) !== null) {
    if (match.index > lastIndex) {
      segments.push({ text: text.slice(lastIndex, match.index), color: null });
    }
    segments.push({ text: '', color: match[1].toLowerCase() });
    lastIndex = regex.lastIndex;
  }
  if (lastIndex < text.length) {
    segments.push({ text: text.slice(lastIndex), color: null });
  }
  // Agora mescla segmentos de cor com o próximo texto
  const merged = [];
  let currentColor = null;
  for (let seg of segments) {
    if (seg.color) {
      currentColor = seg.color;
    } else {
      merged.push({ text: seg.text, color: currentColor });
      currentColor = null;
    }
  }

  // 2) Tipo por caractere, criando spans coloridos
  let segIdx = 0, charIdx = 0;
  let activeSpan = null;

  function typeNext() {
    if (segIdx >= merged.length) {
      cursor.remove();
      processQueue();
      return;
    }

    const { text: segText, color } = merged[segIdx];

    // se mudou de segmento de cor, cria novo span
    if (charIdx === 0) {
      if (activeSpan) {
        // fechou segmento anterior
        activeSpan = null;
      }
      if (color) {
        activeSpan = document.createElement("span");
        activeSpan.style.color = color;
        p.insertBefore(activeSpan, cursor);
      }
    }

    // pega o caractere atual
    const ch = segText.charAt(charIdx);
    if (activeSpan) {
      activeSpan.insertAdjacentText("beforeend", ch);
    } else {
      cursor.insertAdjacentText("beforebegin", ch);
    }
    charIdx++;
    logContainer.scrollTop = logContainer.scrollHeight;

    if (charIdx >= segText.length) {
      // avança para próximo segmento
      segIdx++;
      charIdx = 0;
    }

    setTimeout(typeNext, 5);
  }

  typeNext();
}


document.addEventListener("DOMContentLoaded", () => {
  const splash = document.getElementById("splash-screen");
  const main = document.querySelector("main");

  if (splash && main) {
    setTimeout(() => {
      splash.style.display = "none";
      main.style.display = "flex";
    }, 2000);
  }

});

const dataFile = path.join(__dirname, "../data/emulators.json");
let data = JSON.parse(fs.readFileSync(dataFile));

const brandList = document.getElementById("brand-list");
const systemList = document.getElementById("system-list");

let currentBrand = null;
let showFavorites = false;

function renderSidebar() {
  brandList.innerHTML = "";
  data.brands.forEach((b) => {
    const div = document.createElement("div");
    div.innerHTML = `<i class="fa fa-desktop" style="margin-right: 8px;"></i> ${b.desc}`;
    div.dataset.brand = b.name;
    div.onclick = () => {
      document.querySelectorAll("#brand-list div").forEach((d) => d.classList.remove("brand-selected"));
      div.classList.add("brand-selected");

      currentBrand = b.name;
      showFavorites = false;
      renderSystems();
    };
    brandList.appendChild(div);
  });
}

const favToggle = document.querySelector(".favorites-toggle");
favToggle.innerHTML = '<i class="fa fa-star" style="color: gold; margin-right: 8px;"></i> Faves';
favToggle.onclick = () => {
  currentBrand = null;
  showFavorites = true;
  renderSystems();
};

function toggleFavorite(systemName) {
  const system = data.systems.find((s) => s.name === systemName);

  if (system) {
    system.favorite = !(system.favorite === true || system.favorite === true);

    fs.writeFileSync(dataFile, JSON.stringify(data, null, 2));
    renderSystems();
  }
}

function editSystem(systemName) {
  const sys = data.systems.find((s) => s.name === systemName);
  if (!sys) return;

  const newName = prompt("Novo nome do sistema:", sys.name);
  const newDesc = prompt("Nova descrição:", sys.desc);
  if (newName && newDesc) {
    sys.name = newName;
    sys.desc = newDesc;

    fs.writeFileSync(dataFile, JSON.stringify(data, null, 2));
    renderSystems();
  }
}

function deleteSystem(systemName) {
  const confirmDelete = confirm("Tem certeza que deseja excluir este sistema?");
  if (!confirmDelete) return;

  data.systems = data.systems.filter((s) => s.name !== systemName);

  fs.writeFileSync(dataFile, JSON.stringify(data, null, 2));
  renderSystems();
}

const emuByKey = new Map(
  data.emulators.map(e => [e.key, e])
);

function renderSystems() {
  const dataFile = path.join(__dirname, "../data/emulators.json");
  let data = JSON.parse(fs.readFileSync(dataFile));

  systemList.innerHTML = "";

  let filtered = [];
  if (showFavorites) {
    filtered = data.systems.filter((sys) => sys.favorite === true || sys.favorite === true);
  } else {
    filtered = data.systems.filter((sys) => sys.brand === currentBrand);
  }

  // ordena por year (crescente) e depois por name
filtered.sort((a, b) => {
  const yearDiff = parseInt(a.year, 10) - parseInt(b.year, 10);
  if (yearDiff !== 0) return yearDiff;
  return a.name.localeCompare(b.name);
});


  if (filtered.length === 0) {
    systemList.innerHTML = '<p style="color: #ccc;">Nenhum sistema encontrado.</p>';
    return;
  }

  filtered.forEach((sys) => {
    
    sys.emulator = emuByKey.get(sys.emulator) || null;

    const card = document.createElement("div");
    card.className = "card";

    const input = document.createElement("input");
    input.type = "hidden";
    input.id = "id";
    input.name = "id";
    input.value = sys.id;
    card.appendChild(input);


    const inputParam = document.createElement("input");
    inputParam.type = "hidden"
    inputParam.id = "parameter"
    inputParam.name = "parameter"
    inputParam.value = JSON.stringify(sys)
    card.appendChild(inputParam);

  
    const img = document.createElement("img");
    img.src = "assets/" + (sys.image || `not_found.png`);
    img.onerror = () => {
      img.src = "assets/not_found.png";
    };
    card.appendChild(img);

    const title = document.createElement("div");
    title.className = "title";
    title.innerHTML = `${sys.name} <small>(${sys.year})</small>`;
    card.appendChild(title);

    const desc = document.createElement("div");
    desc.className = "desc";
    desc.textContent = sys.desc;
    card.appendChild(desc);

    const icons = document.createElement("div");
    icons.className = "icons";

    const favIcon = document.createElement("span");
    favIcon.innerHTML = `<i class="fa fa-star ${sys.favorite === true ? "fav-icon" : ""}"></i>`;
    favIcon.onclick = () => toggleFavorite(sys.name);
    icons.appendChild(favIcon);

    const editIcon = document.createElement("span");
    editIcon.innerHTML = '<i class="fa fa-play"></i>';
    editIcon.onclick = () => {
      const runModal = document.getElementById("run-modal");
      const runDesc = document.getElementById("run-desc");
      const runParameter = document.getElementById("run-parameter")
      const runInstructions = document.getElementById("run-instructions")   
  

      //runDesc.textContent = data.emulators.find((e) => e.key === sys.emulator).desc || "Sem descrição disponível.";
      runDesc.textContent = sys.desc
      runInstructions.innerHTML = sys.emulator.instructions
      runParameter.value = JSON.stringify(sys);

      runModal.classList.add("show");
      runModal.style.display = "flex";
    };
    icons.appendChild(editIcon);

    const deleteIcon = document.createElement("span");
    deleteIcon.innerHTML = '<i class="fa fa-trash"></i>';
    deleteIcon.onclick = () => deleteSystem(sys.name);
    icons.appendChild(deleteIcon);

    const gearIcon = document.createElement("span");
    gearIcon.innerHTML = '<i class="fa fa-gear"></i>';
    gearIcon.onclick = () => configSystem(sys);
    icons.appendChild(gearIcon);

    card.appendChild(icons);
    systemList.appendChild(card);
  });
}

renderSidebar();

document.addEventListener("DOMContentLoaded", () => {
  const modal = document.getElementById("about-modal");
  const openBtn = document.getElementById("about");
  const closeBtn = document.getElementById("close-about");
  const errorModal = document.getElementById('error-modal');
  const closeError = document.getElementById('close-error')

  if (modal && openBtn && closeBtn) {
    modal.classList.remove("show");
    setTimeout(() => {
      modal.style.display = "none";
    }, 500);
    openBtn.addEventListener("click", () => {
      modal.classList.add("show");
      modal.style.display = "flex";
    });
    closeBtn.addEventListener("click", () => {
      modal.classList.remove("show");
      setTimeout(() => {
        modal.style.display = "none";
      }, 500);
    });
  }

  if(errorModal && closeError){
    closeError.addEventListener('click', () => {
      errorModal.classList.remove("show");
      setTimeout(() => {
        errorModal.style.display = "none";
      }, 500);
    });
    
  }

});

document.addEventListener("DOMContentLoaded", () => {
  // Animação de troca
  const list = document.getElementById("system-list");
  const brandItems = document.querySelectorAll("#brand-list div");

  brandItems.forEach((item) => {
    item.addEventListener("click", () => {
      if (list) {
        list.classList.remove("fade-in");
        list.classList.add("fade-out");
        setTimeout(() => {
          list.classList.remove("fade-out");
          list.classList.add("fade-in");
        }, 100);
      }
    });
  });

  // Selecionar automaticamente a primeira Brand
  if (brandItems.length > 0) {
    brandItems[0].click();
  }
});

document.addEventListener("DOMContentLoaded", () => {
  const runModal = document.getElementById("run-modal");
  const closeRun = document.getElementById("close-run");
  const runDesc = document.getElementById("run-desc");
  const runParameter = document.getElementById('run-parameter');

  document.querySelectorAll(".fa-play").forEach((button) => {
    button.addEventListener("click", (e) => {
      
      
      const card = e.currentTarget.closest(".card");
      const desc = card?.dataset?.desc || "Sem descrição disponível.";
      runDesc.textContent = desc;
      runParameter.value = card?.dataset.parameter
      
      runModal.classList.add("show");
    });
  });

  closeRun.addEventListener("click", () => {
    runModal.classList.remove("show");
    setTimeout(() => {
      runModal.style.display = "none";
    }, 500);
  });
});

function addEmulator() {

  window.currentSystemConfig = null;
  const modal = document.getElementById("config-modal");

  const fieldBrand = document.getElementById("config-brand");
  const fieldName = document.getElementById("config-name");
  const fieldDesc = document.getElementById("config-desc");
  const fieldEmulator = document.getElementById("config-emulator");
  const fieldParam = document.getElementById("config-parameter");
  const fieldImage = document.getElementById("config-image")
  const fieldYear = document.getElementById("config-year")

  fieldBrand.innerHTML = "";
  data.brands.forEach((b) => {
    const option = document.createElement("option");
    option.value = b.name;
    option.textContent = b.desc;
    fieldBrand.appendChild(option);
  });

  fieldName.value = "";
  fieldDesc.value = "";
  fieldEmulator.innerHTML = "";
  fieldYear.value = "";
  data.emulators.forEach((e) => {
    const option = document.createElement("option");
    option.value = e.key;
    option.textContent = e.key;
    fieldEmulator.appendChild(option);
  });
  fieldParam.value = "";
  fieldImage.value = "";

  modal.classList.add("show");
  modal.style.display = "flex";
}

function configSystem(sys) {
  window.currentSystemConfig = sys;
  const modal = document.getElementById("config-modal");

  const fieldBrand = document.getElementById("config-brand");
  const fieldName = document.getElementById("config-name");
  const fieldDesc = document.getElementById("config-desc");
  const fieldEmulator = document.getElementById("config-emulator");
  const fieldParam = document.getElementById("config-parameter");
  const fieldImage = document.getElementById("config-image")
  const fieldYear = document.getElementById('config-year');

  // Preencher dropdown de brands
  fieldBrand.innerHTML = "";
  data.brands.forEach((b) => {
    const option = document.createElement("option");
    option.value = b.name;
    option.textContent = b.desc;
    if (b.name === sys.brand) option.selected = true;
    fieldBrand.appendChild(option);
  });

  fieldName.value = sys.name || "";
  fieldDesc.value = sys.desc || "";
  fieldYear.value = sys.year || "";
  fieldEmulator.innerHTML = "";
  data.emulators.forEach((e) => {
    const option = document.createElement("option");
    option.value = e.key;
    option.textContent = e.key;

    if (e.key === sys.emulator.key) option.selected = true;
    fieldEmulator.appendChild(option);
  });
  fieldParam.value = sys.parameter || "";
  fieldImage.value = sys.image || "";

  modal.classList.add("show");
  modal.style.display = "flex";
}

document.addEventListener("DOMContentLoaded", () => {
  const saveButton = document.getElementById("save-config");
  const modal = document.getElementById("config-modal");

  if (saveButton) {
    saveButton.addEventListener("click", () => {
      const dataFile = path.join(__dirname, "../data/emulators.json");
      const dataObj = JSON.parse(fs.readFileSync(dataFile, "utf-8"));

      const brandVal = document.getElementById("config-brand").value;
      const nameVal = document.getElementById("config-name").value;
      const descVal = document.getElementById("config-desc").value;
      const emulatorVal = document.getElementById("config-emulator").value;
      const paramVal = document.getElementById("config-parameter").value;
      const imageVal = document.getElementById("config-image").value;
      const yearVal = document.getElementById("config-year").value

      if (!window.currentSystemConfig) {
        const newSystem = {
          id: Date.now().toString(),
          brand: brandVal,
          name: nameVal,
          desc: descVal,
          emulator: emulatorVal,
          parameter: paramVal,
          favorite: false,
          image: imageVal,
          year : yearVal
        };
        dataObj.systems.push(newSystem);
        logMessage(`new system add: ${newSystem.name}`);
      } else {
        const sys = window.currentSystemConfig;

        Object.assign(sys, {
          brand: brandVal,
          name: nameVal,
          desc: descVal,
          emulator: emulatorVal,
          parameter: paramVal,
          image : imageVal,
          year : yearVal
        });

        const idx = dataObj.systems.findIndex((s) => s.id === sys.id);
        if (idx !== -1) {
          Object.assign(dataObj.systems[idx], {
            brand: brandVal,
            name: nameVal,
            desc: descVal,
            emulator: emulatorVal,
            parameter: paramVal,
            image : imageVal,
            year : yearVal
          });

          logMessage(`System updated: ${dataObj.systems[idx].name}`);
        } else {
          console.warn(`No system found with id=${idVal}`);
        }
      }

      const oldName = path.join(__dirname, "../data/emulators_old.json");

      try {
        fs.renameSync(dataFile, oldName);
      } catch (err) {
        console.log(err);
      }
      fs.writeFileSync(dataFile, JSON.stringify(dataObj, null, 2));


      modal.classList.remove("show");
      setTimeout(() => {
        modal.style.display = "none";
        renderSystems();
      }, 500);
    });
  }
});

document.addEventListener("DOMContentLoaded", () => {
  const modal = document.getElementById("config-modal");
  const closeBtn = document.getElementById("close-config");

  closeBtn.addEventListener("click", () => {
    modal.classList.remove("show");
    setTimeout(() => {
      modal.style.display = "none";
    }, 500);
  });
});



document.addEventListener("DOMContentLoaded", () => {
  const powerBtn = document.getElementById("power-button");
  const powerModal = document.getElementById("power-modal");
  const closeBtn = document.getElementById("close-power-modal");
  const rebootBtn = document.getElementById("reboot-system");
  const shutdownBtn = document.getElementById("shutdown-system");
  const exitBtn = document.getElementById("exit-frontend");
  const wifiBtn = document.getElementById("config-wifi");
  const addemulatorBtn = document.getElementById("add-emulator");
  const runBtn = document.getElementById('run-system')
 

  if (powerBtn && powerModal) {
    powerBtn.addEventListener("click", () => {
      powerModal.style.display = "flex";
      powerModal.classList.add("show");
    });
  }
  if (closeBtn && powerModal) {
    closeBtn.addEventListener("click", () => {
      powerModal.classList.remove("show");
      setTimeout(() => {
        powerModal.style.display = "none";
      }, 500);
    });
  }

  if (addemulatorBtn) {
    addemulatorBtn.addEventListener("click", () => {
      addEmulator();
    });
  }

  if(runBtn) {
    runBtn.addEventListener("click", async () => {

      const runParameterLocal = JSON.parse(document.getElementById('run-parameter').value)
      const runModal = document.getElementById("run-modal");

      runModal.classList.remove("show");
      runModal.style.display = 'none'

      // General Config
      runParameterLocal.config = data.config
      
      let romcheck = runParameterLocal.romcheck || [];

      try {
        await Promise.all(
          romcheck.map(async (rom) => {
            const biosFileToCheck = path.join(runParameterLocal.config.biospath, rom);
            
            try {
              await fsPromises.access(biosFileToCheck, fs.constants.F_OK);
            } catch(err) {
   
              //logMessage(`[red] File '${runParameterLocal.romcheck[i]}' was not found in path '${runParameterLocal.config.biospath}' `)
              throw new Error(`Missing file: ${rom}`)
            }
          })
        );
        ipcRenderer.send("run-system", runParameterLocal);


      } catch(error) {
        logMessage(`[red]${error}`)
        doError("missing_bios")
      }


      

    })
  }

  if (wifiBtn) {
    wifiBtn.addEventListener("click", () => {
      logMessage("Wifi Button clicked");

      ipcRenderer.send("wifiConfig");
    });
  }

  if (rebootBtn) {
    rebootBtn.addEventListener("click", () => {
      exec("sudo nmtui", (err) => {
        if (err) alert("Erro ao reiniciar: " + err);
      });
    });
  }
  if (shutdownBtn) {

    shutdownBtn.addEventListener("click", () => {
      exec("sudo halt", (err) => {
        if (err) alert("Erro ao desligar: " + err);
      });
    });
  }
  if (exitBtn) {
    exitBtn.addEventListener("click", () => {
      window.close();
    });
  }

});


window.addEventListener('load', () => {

  setTimeout(() => {
    logMessage("Welcome to [white] ** EmulOS **");
    logMessage("If you appreciate EmulOS, please consider supporting our development on Patreon")
    logMessage("[yellow] Caso você seja um compatriota brasileiro, considere fazer uma doação via PIX para fg1998@gmail.com")
  }, 3000);
  
});

function doError(errorType){
  const errorModal = document.getElementById('error-modal');
  const errorMessage = document.getElementById('error-message');
  errorMessage.innerHTML += '<p>It seems a required BIOS or OS file is missing from the expected folder. emulOS depends on the same BIOS files as RetroPie, so you’ll need to obtain them by either</p>'
  errorMessage.innerHTML += '<li>Transferring the files via SSH from your device</li>'
  errorMessage.innerHTML += "<li>Downloading them directly with curl from their raw URLs</li>"
  errorMessage.innerHTML += '<p>Please note that many of these files are proprietary—make sure you have a valid license or own the original hardware before using them. To download via curl, click the download button below and follow the on-screen instructions.</p>'
  errorModal.classList.add("show");
  errorModal.style.display = "flex";
}