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
    div.textContent = b.desc;
    div.dataset.brand = b.name;
    div.onclick = () => {
      currentBrand = b.name;
      showFavorites = false;
      renderSystems();
    };
    brandList.appendChild(div);
  });
}

document.querySelector('.favorites-toggle').onclick = () => {
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
    editIcon.onclick = () => editSystem(sys.name);
    icons.appendChild(editIcon);

    const deleteIcon = document.createElement('span');
    deleteIcon.innerHTML = '<i class="fa fa-trash"></i>';
    deleteIcon.onclick = () => deleteSystem(sys.name);
    icons.appendChild(deleteIcon);

    const addIcon = document.createElement('span');
    addIcon.innerHTML = '<i class="fa fa-gear"></i>';
    addIcon.onclick = () => addNewSystemPrompt();
    icons.appendChild(addIcon);

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
    modal.style.display = 'none';
    openBtn.addEventListener('click', () => {
      modal.style.display = 'flex';
    });
    closeBtn.addEventListener('click', () => {
      modal.style.display = 'none';
    });
  }
});
