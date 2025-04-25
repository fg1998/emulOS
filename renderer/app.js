
document.addEventListener("DOMContentLoaded", () => {
  const splash = document.getElementById("splash-screen");
  const main = document.querySelector("main");

  if (splash && main) {
    setTimeout(() => {
      splash.style.display = "none";
      main.style.display = "flex";
    }, 4000);
  }
});
const fs = require('fs');
const path = require('path');





const dataFile = path.join(__dirname, '../data/emulators.json');
let data = JSON.parse(fs.readFileSync(dataFile));

const brandList = document.getElementById('brand-list');
const systemList = document.getElementById('system-list');

let currentBrand = null;
let showFavorites = false;

function renderSidebar() {
  brandList.innerHTML = '';
  data.brands.forEach(b => {
    const div = document.createElement('div');
    div.innerHTML = `<i class="fa fa-desktop" style="margin-right: 8px;"></i> ${b.desc}`;
    div.dataset.brand = b.name;
    div.onclick = () => {
      document.querySelectorAll('#brand-list div').forEach(d => d.classList.remove('brand-selected'));
      div.classList.add('brand-selected');

      currentBrand = b.name;
      showFavorites = false;
      renderSystems();
    };
    brandList.appendChild(div);
  });
}

const favToggle = document.querySelector('.favorites-toggle');
favToggle.innerHTML = '<i class="fa fa-star" style="color: gold; margin-right: 8px;"></i> Favoritos';
favToggle.onclick = () => {
  currentBrand = null;
  showFavorites = true;
  renderSystems();
};

function toggleFavorite(systemName) {
  
  const system = data.systems.find(s => s.name === systemName);

  if (system) {
    system.favorite = !(system.favorite === true || system.favorite === true);
    console.log(system.favorite)

    fs.writeFileSync(dataFile, JSON.stringify(data, null, 2));
    console.log(dataFile)
    renderSystems();
  }
}

function addNewSystemPrompt() {
  const name = prompt("Nome do sistema:");
  const desc = prompt("Descrição:");
  if (!name || !desc || !currentBrand) return;

  const newSystem = {
    name,
    desc,
    brand: currentBrand,
    emulator: currentBrand,
    favorite: false,
    parameter: ""
  };
  data.systems.push(newSystem);
  fs.writeFileSync(dataFile, JSON.stringify(data, null, 2));
  renderSystems();
}

function editSystem(systemName) {
  const sys = data.systems.find(s => s.name === systemName);
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

  data.systems = data.systems.filter(s => s.name !== systemName);
  fs.writeFileSync(dataFile, JSON.stringify(data, null, 2));
  renderSystems();
}

function renderSystems() {
  systemList.innerHTML = '';

  let filtered = [];
  if (showFavorites) {
    filtered = data.systems.filter(sys => sys.favorite === true || sys.favorite === true);
  } else {
    filtered = data.systems.filter(sys => sys.brand === currentBrand);
  }

  if (filtered.length === 0) {
    systemList.innerHTML = '<p style="color: #ccc;">Nenhum sistema encontrado.</p>';
    return;
  }

  filtered.forEach(sys => {
    const card = document.createElement('div');
    card.className = 'card';

    const img = document.createElement('img');
    img.src = 'assets/' + (sys.image || `${sys.brand}_not_found.png`);
    img.onerror = () => { img.src = 'assets/default.png'; };
    card.appendChild(img);

    /*
// Criar ícone de favorito
const fav = document.createElement('div');
fav.className = 'favorite-icon';
fav.dataset.id = sys.id;
fav.textContent = sys.favorite ? '★' : '☆';
fav.style.color = sys.favorite ? 'gold' : 'gray';
fav.style.fontSize = '1.2em';
fav.style.marginTop = '5px';
fav.style.cursor = 'pointer';
card.appendChild(fav);


      const star = document.createElement('span');
      star.className = 'favorite-icon';
      star.dataset.id = sys.id;
      star.innerText = sys.favorite ? '★' : '☆';
      card.appendChild(star);
*/

    const title = document.createElement('div');
    title.className = 'title';
    title.textContent = sys.name;
    card.appendChild(title);

    const desc = document.createElement('div');
    desc.className = 'desc';
    desc.textContent = sys.desc;
    card.appendChild(desc);

    const icons = document.createElement('div');
    icons.className = 'icons';


    const favIcon = document.createElement('span');
    favIcon.innerHTML = `<i class="fa fa-star ${sys.favorite === true  ? 'fav-icon': '' }"></i>`;
    favIcon.onclick = () => toggleFavorite(sys.name);
    icons.appendChild(favIcon);

    
    const editIcon = document.createElement('span');
    editIcon.innerHTML = '<i class="fa fa-play"></i>';
    editIcon.onclick = () => {
      const runModal = document.getElementById("run-modal");
      const runDesc = document.getElementById("run-desc");
    
      runDesc.textContent = data.emulators.find(e => e.key === sys.emulator).desc|| "Sem descrição disponível.";
      //runDesc.textContent = 
      
      //console.log(data.emulators)
      //console.log(sys)
      //console.log(data.emulators.find(e => e.key === sys.emulator).desc)

      runModal.classList.add("show");
      runModal.style.display = "flex";
    };
    icons.appendChild(editIcon);
    

    const deleteIcon = document.createElement('span');
    deleteIcon.innerHTML = '<i class="fa fa-trash"></i>';
    deleteIcon.onclick = () => deleteSystem(sys.name);
    icons.appendChild(deleteIcon);

    const gearIcon = document.createElement('span');
gearIcon.innerHTML = '<i class="fa fa-gear"></i>';
gearIcon.onclick = () => configSystem(sys);
icons.appendChild(gearIcon);

    card.appendChild(icons);
    systemList.appendChild(card);
  });
}

renderSidebar();

document.addEventListener('DOMContentLoaded', () => {
  const modal = document.getElementById('about-modal');
  const openBtn = document.getElementById('about');
  const closeBtn = document.getElementById('close-about');

  if (modal && openBtn && closeBtn) {
    modal.classList.remove('show'); setTimeout(() => { modal.style.display = 'none'; }, 500);
    openBtn.addEventListener('click', () => {
      modal.classList.add('show'); modal.style.display = 'flex';
    });
    closeBtn.addEventListener('click', () => {
      modal.classList.remove('show'); setTimeout(() => { modal.style.display = 'none'; }, 500);
    });
  }
});


document.addEventListener('DOMContentLoaded', () => {
  // Animação de troca
  const list = document.getElementById('system-list');
  const brandItems = document.querySelectorAll('#brand-list div');

  brandItems.forEach(item => {
    item.addEventListener('click', () => {
      if (list) {
        list.classList.remove('fade-in');
        list.classList.add('fade-out');
        setTimeout(() => {
          list.classList.remove('fade-out');
          list.classList.add('fade-in');
        }, 100);
      }
    });
  });

  // Selecionar automaticamente a primeira Brand
  if (brandItems.length > 0) {
    brandItems[0].click();
  }
});


document.addEventListener('DOMContentLoaded', () => {
  const runModal = document.getElementById("run-modal");
  const closeRun = document.getElementById("close-run");
  const runDesc = document.getElementById("run-desc");

  document.querySelectorAll(".fa-play").forEach(button => {
    button.addEventListener("click", (e) => {
      const card = e.currentTarget.closest(".card");
      const desc = card?.dataset?.desc || "Sem descrição disponível.";
      runDesc.textContent = desc;
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



function configSystem(sys) {
  window.currentSystemConfig = sys;
  const modal = document.getElementById("config-modal");

  const fieldBrand = document.getElementById("config-brand");
  const fieldName = document.getElementById("config-name");
  const fieldDesc = document.getElementById("config-desc");
  const fieldEmulator = document.getElementById("config-emulator");
  const fieldParam = document.getElementById("config-parameter");

  // Preencher dropdown de brands
  fieldBrand.innerHTML = '';
  data.brands.forEach(b => {
    const option = document.createElement('option');
    option.value = b.name;
    option.textContent = b.desc;
    if (b.name === sys.brand) option.selected = true;
    fieldBrand.appendChild(option);
  });

  fieldName.value = sys.name || '';
  fieldDesc.value = sys.desc || '';
  fieldEmulator.innerHTML = '';
  data.emulators.forEach(e => {
    const option = document.createElement('option');
    option.value = e.key;
    option.textContent = e.key;
    if (e.key === sys.emulator) option.selected = true;
    fieldEmulator.appendChild(option);
  });
  fieldParam.value = sys.parameter || '';

  modal.classList.add("show");
  modal.style.display = "flex";
}


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
  const saveButton = document.getElementById("save-config");
  const modal = document.getElementById("config-modal");

  if (saveButton) {
    saveButton.addEventListener("click", () => {
      if (!window.currentSystemConfig) return;

      const sys = window.currentSystemConfig;
      sys.brand = document.getElementById("config-brand").value;
      sys.name = document.getElementById("config-name").value;
      sys.desc = document.getElementById("config-desc").value;
      sys.emulator = document.getElementById("config-emulator").value;
      sys.parameter = document.getElementById("config-parameter").value;

      const fs = require('fs');
      const path = require('path');
      const dataFile = path.join(__dirname, '../data/emulators.json');
      fs.writeFileSync(dataFile, JSON.stringify(data, null, 2));

      modal.classList.remove("show");
      setTimeout(() => {
        modal.style.display = "none";
        renderSystems();
      }, 500);
    });
  }
});


document.addEventListener("DOMContentLoaded", () => {
  const powerBtn = document.getElementById("power-button");
  const powerModal = document.getElementById("power-modal");
  const closeBtn = document.getElementById("close-power-modal");
  const rebootBtn = document.getElementById("reboot-system");
  const shutdownBtn = document.getElementById("shutdown-system");
  const exitBtn = document.getElementById("exit-frontend");
  const { exec } = require("child_process");

  if (powerBtn && powerModal) {
    powerBtn.addEventListener("click", () => {
      powerModal.style.display = "flex";
      powerModal.classList.add("show");
    });
  }
  if (closeBtn && powerModal) {
    closeBtn.addEventListener("click", () => {
      powerModal.classList.remove("show");
      setTimeout(() => { powerModal.style.display = "none"; }, 500);
    });
  }
  if (rebootBtn) {
    rebootBtn.addEventListener("click", () => {
      exec("sudo reboot", (err) => { if (err) alert("Erro ao reiniciar: " + err); });
    });
  }
  if (shutdownBtn) {
    console.log('ShutDown')
    shutdownBtn.addEventListener("click", () => {
      exec("sudo halt", (err) => { if (err) alert("Erro ao desligar: " + err); });
    });
  }
  if (exitBtn) {
    exitBtn.addEventListener("click", () => {
      window.close();
    });
  }
});
