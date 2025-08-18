// js/regEvent.js — REEMPLAZA TODO
(function(){
  'use strict';

  // Construye la URL base según tu despliegue actual
  const APP = '/' + location.pathname.split('/')[1];
  const BASE_EVENT = location.origin + APP + '/controllers/regEventController.jsp';

  document.addEventListener('DOMContentLoaded', init);

  function init(){
    loadClientes();
    loadAdmins();
    loadServicios(); 
    serviceCartInit();
    bindFormSubmit(); 
    // aquí puedes sumar luego:
    // loadServicios();
    // loadStatuses();
  }

  /* =================== GENÉRICOS =================== */

  // Pide al controller por acción y devuelve JSON (tolerante a header)
  function fetchAction(action){
    return fetch(`${BASE_EVENT}?action=${encodeURIComponent(action)}`, {
      headers: { 'Accept':'application/json' }
    })
    .then(r => r.text())
    .then(txt => {
      try { return JSON.parse(txt); }
      catch(e){ console.error(action, 'no-json:', txt); throw e; }
    });
  }

  // Llena un <select> por id o name con [{id, name}]
  function fillSelect(selIdOrName, rows, placeholder){
    const el = document.getElementById(selIdOrName)
           || document.querySelector(`select[name="${selIdOrName}"]`);
    if(!el) return;

    el.innerHTML = '';
    const ph = document.createElement('option');
    ph.value = ''; ph.disabled = true; ph.selected = true;
    ph.textContent = placeholder || 'Selecciona una opción';
    el.appendChild(ph);

    (rows || []).forEach(r => {
      const opt = document.createElement('option');
      opt.value = r.id;
      opt.textContent = r.name || (`Opción ${r.id}`);
      el.appendChild(opt);
    });
  }

  function toastRed(msg){
    if (window.M && M.toast) M.toast({ html: msg, classes: 'red' });
  }

  /* =================== CLIENTES =================== */
  function loadClientes(){
    fetchAction('clients')
      .then(d => {
        if(!d || !d.ok) throw new Error(d && d.msg || 'payload');
        fillSelect('selCliente', d.data, 'Selecciona un cliente');
      })
      .catch(() => toastRed('No se pudieron cargar clientes'));
  }

  /* =================== ADMINISTRADORES =================== */
  function loadAdmins(){
    fetchAction('admins')
      .then(d => {
        if(!d || !d.ok) throw new Error(d && d.msg || 'payload');
        fillSelect('selAdmin', d.data, 'Selecciona administrador');
      })
      .catch(() => toastRed('No se pudieron cargar administradores'));
  }

    /* =================== SERVICIOS =================== */
  function loadServicios(){
    fetchAction('services')
      .then(d => {
        if(!d || !d.ok) throw new Error(d && d.msg || 'payload');
        fillServiceSelect(d.data || []);
      })
      .catch(() => toastRed('No se pudieron cargar servicios'));
  }

  function fillServiceSelect(rows){
    const sel = document.getElementById('selServicio')
            || document.querySelector('select[name="id_service"]');
    if(!sel) return;

    sel.innerHTML = '';
    const ph = document.createElement('option');
    ph.value = ''; ph.disabled = true; ph.selected = true;
    ph.textContent = 'Selecciona un servicio';
    sel.appendChild(ph);

    (rows || []).forEach(r => {
      const opt = document.createElement('option');
      opt.value = r.id;
      opt.setAttribute('data-precio', r.price); // para usarlo luego
      const precio = Number(r.price || 0);
      opt.textContent = `${r.name} — $${precio.toFixed(2)}`;
      sel.appendChild(opt);
    });
  }




/* ================= CARRO DE SERVICIOS (localStorage) ================= */
const CART_KEY = 'kerone_services_cart';

function serviceCartInit(){
  // Vincula botón Agregar
  const addBtn =
    document.getElementById('btnAddServicio') ||
    document.querySelector('.service-row .btn');
  if (addBtn){
    addBtn.addEventListener('click', onAddServiceClick);
  }

  // Carga y pinta lo que haya en localStorage
  renderCart(getCart());
  updateCartTotal();
}

function onAddServiceClick(e){
  e.preventDefault();

  const sel = document.getElementById('selServicio')
           || document.querySelector('select[name="id_service"]');
  const qtyInput = document.getElementById('cantidad')
                 || document.querySelector('input[name="amount_service"]');

  if(!sel || !qtyInput){
    toastRed('Faltan controles de servicio');
    return;
  }

  const id = sel.value;
  if(!id){
    toastRed('Selecciona un servicio');
    return;
  }

  const opt = sel.options[sel.selectedIndex];
  const name = opt ? opt.textContent.split(' — ')[0].trim() : 'Servicio';
  const price = Number(opt ? (opt.getAttribute('data-precio') || 0) : 0);
  let qty = parseInt(qtyInput.value, 10);
  if(isNaN(qty) || qty < 1) qty = 1;

  // Añade o acumula
  const cart = getCart();
  const idx = cart.findIndex(it => String(it.id) === String(id));
  if (idx >= 0){
    cart[idx].qty += qty;
    cart[idx].total = Number((cart[idx].qty * cart[idx].price).toFixed(2));
  }else{
    cart.push({
      id: Number(id),
      name: name,
      price: Number(price),
      qty: qty,
      total: Number((qty * price).toFixed(2))
    });
  }
  setCart(cart);

  // Render + total
  renderCart(cart);
  updateCartTotal();

  // Log para ver en herramientas de desarrollador
  console.log('CART ->', cart);

  // Feedback
  if (window.M && M.toast) M.toast({html:'Servicio agregado', classes:'green'});
}

/* ---------------- Persistencia ---------------- */
function getCart(){
  try{
    const raw = localStorage.getItem(CART_KEY);
    return raw ? JSON.parse(raw) : [];
  }catch(_){
    return [];
  }
}
function setCart(cart){
  localStorage.setItem(CART_KEY, JSON.stringify(cart));
}

/* ---------------- Render UI ---------------- */
function renderCart(cart){
  const list = document.querySelector('ul.services-list');
  if(!list) return;

  // Header con columna Acciones
  list.innerHTML = `
    <li class="collection-item"
        style="display:flex;gap:12px;justify-content:space-between;font-weight:600;">
      <span>Servicio</span>
      <span>Cant.</span>
      <span>P. Unit.</span>
      <span>Total</span>
      <span>Acciones</span>
    </li>
  `;

  (cart || []).forEach(it => {
    const li = document.createElement('li');
    li.className = 'collection-item';
    li.style.display = 'flex';
    li.style.gap = '12px';
    li.style.alignItems = 'center';
    li.style.justifyContent = 'space-between';

    li.innerHTML = `
      <span>${escapeHtml(it.name)}</span>
      <span>${it.qty}</span>
      <span>$${formatMoney(it.price)}</span>
      <span>$${formatMoney(it.total)}</span>

      <span class="svc-actions" style="display:flex;gap:6px;">
        <!-- Disminuir (azul claro) -->
        <a class="btn-floating btn-small svc-dec"
           data-act="dec" data-id="${it.id}"
           title="Disminuir"
           style="background:linear-gradient(90deg,#3f6fb8,#6c8fd1)">
          <i class="material-icons">remove</i>
        </a>

        <!-- Aumentar (azul oscuro) -->
        <a class="btn-floating btn-small svc-inc"
           data-act="inc" data-id="${it.id}"
           title="Aumentar"
           style="background:linear-gradient(90deg,#0a2a66,#174792)">
          <i class="material-icons">add</i>
        </a>

        <!-- Eliminar (rojo) -->
        <a class="btn-floating btn-small red svc-del"
           data-act="del" data-id="${it.id}"
           title="Eliminar">
          <i class="material-icons">delete</i>
        </a>
      </span>
    `;
    list.appendChild(li);
  });
}


function updateCartTotal(){
  const cart = getCart();
  const sum = cart.reduce((a,b)=> a + (Number(b.total)||0), 0);
  // Busca target para total (con id o fallback)
  const totalEl = document.getElementById('totalServicios') ||
                  document.querySelector('div.right-align span:last-child');
  if (totalEl){
    totalEl.textContent = `$${formatMoney(sum)}`;
  }
}

/* ---------------- Utils ---------------- */
function formatMoney(n){
  return Number(n||0).toFixed(2);
}
function escapeHtml(str){
  return String(str).replace(/[&<>"']/g, m => ({
    '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'
  }[m]));
}


// Controles de + / - / borrar (delegación)
document.addEventListener('click', function(e){
  const btn = e.target.closest('.svc-dec, .svc-inc, .svc-del');
  if(!btn) return;

  const act = btn.dataset.act;             // dec | inc | del
  const id  = btn.dataset.id;
  let cart  = getCart();
  const idx = cart.findIndex(it => String(it.id) === String(id));
  if (idx < 0) return;

  if (act === 'inc') {
    cart[idx].qty += 1;
  } else if (act === 'dec') {
    cart[idx].qty -= 1;
    if (cart[idx].qty <= 0) cart.splice(idx, 1);   // si llega a 0, elimina
  } else if (act === 'del') {
    cart.splice(idx, 1);
  }

  if (idx >= 0 && cart[idx]) {
    cart[idx].total = Number((cart[idx].qty * cart[idx].price).toFixed(2));
  }

  setCart(cart);
  renderCart(cart);
  updateCartTotal();
});


/* ================= GUARDAR RESERVACIÓN ================= */
function bindFormSubmit(){
  const form = document.getElementById('formReserva');
  if(!form) return;
  form.addEventListener('submit', onReservaSubmit);
}

function onReservaSubmit(e){
  e.preventDefault();
  const form = e.currentTarget;

  const btn = form.querySelector('button[type="submit"]');
  if (btn) btn.disabled = true;

  // Arma payload desde el form + carrito
  const payload = buildSavePayload(form);

  fetch(`${BASE_EVENT}?action=save`, {
    method: 'POST',
    headers: {'Content-Type':'application/x-www-form-urlencoded'},
    body: new URLSearchParams(payload).toString()
  })
  .then(r => r.text())
  .then(txt => {
    let d;
    try { d = JSON.parse(txt); }
    catch(e){ console.error('SAVE no-json:', txt); throw e; }

    if (d && d.ok){
      // Toast verde con info básica
      if (window.M && M.toast) {
        const total = (d.price_total !== undefined) ? Number(d.price_total).toFixed(2) : '0.00';
        M.toast({ html:`Reservación guardada. Folio: ${d.id_folio} · Total $${total}`, classes:'green' });
      }
      // Limpia formulario y carrito
      resetReservaForm(form);
    } else {
      if (window.M && M.toast) M.toast({ html:'No se pudo guardar la reservación', classes:'red' });
    }
  })
  .catch(err => {
    console.error('SAVE', err);
    if (window.M && M.toast) M.toast({ html:'Error de conexión', classes:'red' });
  })
  .finally(() => { if (btn) btn.disabled = false; });
}

function buildSavePayload(form){
  // Campos del form
  const evento  = (form.evento?.value || '').trim();
  const color   = (document.querySelector('input[name="color_evento"]:checked')?.value) || '';
  const start   = form.date_reservation_start?.value || '';
  const end     = form.date_reservation_end?.value || '';
  const status  = form.status_reservation?.value || '';
  const idCli   = form.id_cliente?.value || '';
  const idUser  = form.id_user?.value || '';

  // Carrito -> CSVs para el controller
  const cart = getCart();
  const ids   = cart.map(it => it.id).join(',');
  const qtys  = cart.map(it => it.qty).join(',');
  const units = cart.map(it => it.price).join(',');

  return {
    evento: evento,
    color_evento: color,
    date_reservation_start: start,
    date_reservation_end: end,
    status_reservation: status,
    id_cliente: idCli,
    id_user: idUser,
    services_id: ids,
    services_qty: qtys,
    services_unit: units
  };
}

function resetReservaForm(form){
  try {
    form.reset();
    // Si usas labels flotantes de Materialize en inputs normales
    if (window.M && M.updateTextFields) M.updateTextFields();
  } catch(_) {}

  // Vacia carrito y UI
  localStorage.removeItem(CART_KEY);
  renderCart([]);
  updateCartTotal();
}



})();


