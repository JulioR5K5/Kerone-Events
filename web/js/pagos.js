// js/pagos.js
(function(){
  'use strict';

  const APP = '/' + location.pathname.split('/')[1];
  const BASE_PAGOS = location.origin + APP + '/controllers/pagosController.jsp';

  document.addEventListener('DOMContentLoaded', init);

  function init(){
    if (window.M && M.Modal) M.Modal.init(document.querySelectorAll('.modal'));
    loadPagos();
    document.addEventListener('click', onOpenModalClick);
    const form = document.getElementById('formPago');
    if (form) form.addEventListener('submit', onSubmitPago);
  }

  /* -------- fetch helper -------- */
  function fetchAction(action, opts){
    const url = `${BASE_PAGOS}?action=${encodeURIComponent(action)}`;
    return fetch(url, opts || { headers:{ 'Accept':'application/json' } })
      .then(async r => {
        const txt = await r.text();
        try { return JSON.parse(txt); }
        catch(_){ throw new Error(`HTTP ${r.status}: ${txt.slice(0,200)}`); }
      });
  }

  const toast = (msg, cls)=> (window.M&&M.toast)&&M.toast({html:msg, classes:cls||''});
  const fmtMoney = n => Number(n||0).toFixed(2);
  const escHTML  = s => String(s||'').replace(/[&<>"']/g, m=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[m]));
  const escAttr  = s => String(s||'').replace(/"/g,'&quot;');
  const fmtDT    = s => s ? String(s).replace('T',' ').slice(0,16) : '-';

  /* -------- LIST -------- */
  function loadPagos(){
    fetchAction('list')
      .then(d => {
        if(!d || !d.ok) throw new Error(d && d.msg || 'payload');
        renderPagosList(d.data || []);
      })
      .catch(err => {
        console.error('[LIST pagos]', err);
        toast('No se pudo cargar la lista de pagos', 'red');
      });
  }

  function renderPagosList(rows){
    const ul = document.getElementById('pagosList');
    if(!ul) return;

    ul.innerHTML = `
      <li class="collection-item pago-head">
        <span class="ph-col ph-info">Evento / Cliente</span>
        <span class="ph-col ph-total">Total</span>
        <span class="ph-col ph-adeudo">Adeudo</span>
        <span class="ph-col ph-acciones">Acciones</span>
      </li>
    `;

    (rows||[]).forEach(r=>{
      const li = document.createElement('li');
      li.className = 'collection-item pago-item';
      li.innerHTML = `
        <div class="pago-main">
          <div class="pago-title">${escHTML(r.evento)}</div>
          <div class="pago-tags">
            <span class="grey-text">Cliente: <b>${escHTML(r.cliente)}</b></span>
            <span class="grey-text">Inicio: <b>${fmtDT(r.start)}</b></span>
            <span class="grey-text">Fin: <b>${fmtDT(r.end)}</b></span>
          </div>
        </div>

        <div class="pago-badges">
          <span class="chip chip-total">$ ${fmtMoney(r.total)}</span>
          <span class="chip chip-debt">$ ${fmtMoney(r.adeudo)}</span>
        </div>

        <div class="pago-actions">
          <a class="btn-small btn-aqua btn-pay"
             data-evento="${escAttr(r.evento)}"
             data-total="${r.total}"
             data-adeudo="${r.adeudo}"
             data-id-res="${r.id_reservation}"
             data-id-folio="${r.id_folio}"
             title="Registrar pago">
            <i class="material-icons">attach_money</i>
          </a>
          <a class="btn-small btn-danger" title="Eliminar"><i class="material-icons">delete</i></a>
        </div>
      `;
      ul.appendChild(li);
    });
  }

  /* -------- Abrir modal -------- */
  function onOpenModalClick(e){
    const btn = e.target.closest('.btn-pay');
    if(!btn) return;

    document.getElementById('pay_event_name').textContent   = btn.dataset.evento || '—';
    document.getElementById('pay_monto_total').textContent  = '$ ' + fmtMoney(btn.dataset.total || 0);
    document.getElementById('pay_adeudo_actual').textContent= '$ ' + fmtMoney(btn.dataset.adeudo || 0);

    document.getElementById('pay_id_reservation').value = btn.dataset.idRes   || '';
    document.getElementById('pay_id_folio').value       = btn.dataset.idFolio || '';

    if (window.M && M.Modal){
      M.Modal.getInstance(document.getElementById('modalPago')).open();
    }
  }

  /* -------- Guardar pago (SIN id_metodo_pago) -------- */
  function onSubmitPago(e){
    e.preventDefault();

    const fd = new FormData(e.target);

    // Si en tu HTML todavía existe un <select id="id_metodo_pago">, lo IGNORAMOS:
    fd.delete('id_metodo_pago');

    const debug = {}; fd.forEach((v,k)=> debug[k]=v);
    console.log('[PAGO -> POST body]', debug);

    const body = new URLSearchParams(fd).toString();

    fetch(`${BASE_PAGOS}?action=save`, {
      method: 'POST',
      headers: { 'Content-Type':'application/x-www-form-urlencoded', 'Accept':'application/json' },
      body
    })
    .then(r => r.text())
    .then(txt => {
      let d; try{ d = JSON.parse(txt); }catch(_){
        console.error('save no-json:', txt);
        throw new Error('Respuesta no JSON');
      }
      if(!d || !d.ok){
        console.error('save payload:', d);
        throw new Error(d && d.msg || 'No se guardó el pago');
      }
      toast('Pago registrado', 'green');
      if (window.M && M.Modal) M.Modal.getInstance(document.getElementById('modalPago')).close();
      e.target.reset();
      loadPagos();
    })
    .catch(err => {
      console.error('[SAVE pago]', err);
      toast('No se pudo guardar el pago: ' + (err.message||''), 'red');
    });
  }
})();
