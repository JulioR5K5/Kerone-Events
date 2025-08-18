// js/registrarServicio.js
document.addEventListener('DOMContentLoaded', function () {
  // Inicia modales de Materialize
  M.Modal.init(document.querySelectorAll('.modal'));

  // ---- refs
  const BASE = 'http://localhost:8080/Kerone-Events/controllers/regServicioController.jsp';
  const formCreate = document.getElementById('formServicio');
  const btnCreate  = document.querySelector('button[form="formServicio"]');
  const modalCreateEl = document.getElementById('modalServicio');
  const modalEditEl   = document.getElementById('modalEditServicio');
  const formEdit  = document.getElementById('formEditServicio');

  // ===== helpers (visibles para todo lo de abajo) =====
  function escapeHtml(str){
    return String(str).replace(/[&<>"']/g, m => (
      {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]
    ));
  }
  function escapeAttr(str){ return String(str).replace(/"/g,'&quot;'); }

  function renderTable(payload){
    const ulist = document.getElementById('listServicios');
    if (!ulist) return;
    ulist.innerHTML = '';

    const rows = (payload && payload.data) ? payload.data : [];
    rows.forEach(s => {
      const li = document.createElement('li');
      li.className = 'collection-item service-item';

      const priceChip  = `<span class="chip chip-price">$ ${Number(s.price).toFixed(2)}</span>`;
      const statusChip = (String(s.status) === '1')
        ? `<span class="chip chip-on">Activo</span>`
        : `<span class="chip chip-off">Inactivo</span>`;

      li.innerHTML = `
        <div class="service-main">
          <div class="service-name blue-text text-darken-2">${escapeHtml(s.name || '')}</div>
          <div class="service-meta">
            <span class="grey-text">ID: ${s.id}</span>
            ${priceChip}
            ${statusChip}
          </div>
        </div>
        <div class="service-actions">
          <a class="btn-small btn-edit" style="background:#0a2a66;border-radius:12px;"
             title="Editar"
             data-id="${s.id}"
             data-name="${escapeAttr(s.name || '')}"
             data-price="${Number(s.price).toFixed(2)}"
             data-status="${s.status}">
            <i class="material-icons">edit</i>
          </a>
          <a class="btn-small red btn-delete" style="border-radius:12px;" title="Eliminar"
             data-id="${s.id}" data-name="${escapeAttr(s.name || '')}">
            <i class="material-icons">delete</i>
          </a>
        </div>`;
      ulist.appendChild(li);
    });
  }

  function loadServicios(){
    fetch(BASE + '?action=list')
      .then(r => { if(!r.ok) throw new Error('HTTP '+r.status); return r.json(); })
      .then(renderTable)
      .catch(() => M.toast({ html:'No se pudo cargar la lista', classes:'red' }));
  }

  // Carga inicial
  loadServicios();

  // ---- crear servicio
  if (formCreate) {
    formCreate.addEventListener('submit', function (e) {
      e.preventDefault();

      const name   = document.getElementById('name_service').value.trim();
      const price  = (document.getElementById('price_service').value || '').replace(',', '.');
      const status = document.getElementById('status_service').checked ? '1' : '0';

      if (!name || !price) {
        M.toast({ html: 'Completa nombre y precio', classes: 'red' });
        return;
      }

      if (btnCreate) btnCreate.disabled = true;

      fetch(BASE, {
        method: 'POST',
        headers: {'Content-Type':'application/x-www-form-urlencoded'},
        body: new URLSearchParams({
          name_service: name,
          price_service: price,
          status_service: status
        }).toString()
      })
      .then(r => { if(!r.ok) throw new Error('HTTP '+r.status); return r.json(); })
      .then(d => {
        if (d && d.ok) {
          M.toast({ html: 'Servicio guardado', classes: 'green' });
          formCreate.reset();
          const inst = M.Modal.getInstance(modalCreateEl);
          if (inst) inst.close();
          loadServicios();
        } else {
          M.toast({ html: 'No se pudo guardar', classes: 'red' });
        }
      })
      .catch(() => M.toast({ html:'Error de conexión', classes:'red' }))
      .finally(() => { if (btnCreate) btnCreate.disabled = false; });
    });
  }

  // ---- abrir modal de edición (delegación)
  document.addEventListener('click', function (e) {
    const btn = e.target.closest('.btn-edit');
    if (!btn) return;

    const id     = btn.dataset.id;
    const name   = btn.dataset.name || '';
    const price  = btn.dataset.price || '0.00';
    const status = btn.dataset.status === '1';

    document.getElementById('edit_id_service').value = id;
    document.getElementById('edit_name_service').value = name;
    document.getElementById('edit_price_service').value = price;
    document.getElementById('edit_status_service').checked = status;

    M.updateTextFields();
    const inst = M.Modal.getInstance(modalEditEl) || M.Modal.init(modalEditEl);
    inst.open();
  });

  // ---- actualizar servicio
  if (formEdit) {
    formEdit.addEventListener('submit', function (e) {
      e.preventDefault();

      const id     = document.getElementById('edit_id_service').value;
      const name   = document.getElementById('edit_name_service').value.trim();
      const price  = (document.getElementById('edit_price_service').value || '').replace(',', '.');
      const status = document.getElementById('edit_status_service').checked ? '1' : '0';

      fetch(BASE + '?action=update', {
        method: 'POST',
        headers: {'Content-Type':'application/x-www-form-urlencoded'},
        body: new URLSearchParams({
          id_service: id,
          name_service: name,
          price_service: price,
          status_service: status
        }).toString()
      })
      .then(r => { if(!r.ok) throw new Error('HTTP '+r.status); return r.json(); })
      .then(d => {
        if (d && d.ok) {
          const inst = M.Modal.getInstance(modalEditEl);
          if (inst) inst.close();
          Swal.fire({ icon:'success', title:'Registro actualizado', timer:1200, showConfirmButton:false });
          loadServicios();
        } else {
          Swal.fire({ icon:'error', title:'No se pudo actualizar' });
        }
      })
      .catch(() => Swal.fire({ icon:'error', title:'Error de conexión' }));
    });
  }

  // ---- eliminar servicio (delegación + confirmación)
  document.addEventListener('click', function(e){
    const btn = e.target.closest('.btn-delete');
    if(!btn) return;

    const id = btn.dataset.id;
    const name = btn.dataset.name || 'este servicio';

    Swal.fire({
      icon: 'warning',
      title: '¿Quieres eliminar el servicio?',
      html: 'Vas a eliminar <b>'+escapeHtml(name)+'</b>',
      showCancelButton: true,
      confirmButtonText: 'Si, eliminar',
      cancelButtonText: 'Cancelar'
    }).then(function(res){
      if(!res.isConfirmed) return;

      fetch(BASE + '?action=delete', {
        method: 'POST',
        headers: {'Content-Type':'application/x-www-form-urlencoded'},
        body: new URLSearchParams({ id_service: id }).toString()
      })
      .then(r => { if(!r.ok) throw new Error('HTTP '+r.status); return r.json(); })
      .then(d => {
        if(d && d.ok){
          Swal.fire({ icon:'success', title:'Registro eliminado', timer:1100, showConfirmButton:false });
          loadServicios();
        }else{
          Swal.fire({ icon:'error', title:'No se pudo eliminar' });
        }
      })
      .catch(() => Swal.fire({ icon:'error', title:'Error de conexión' }));
    });
  });

});
