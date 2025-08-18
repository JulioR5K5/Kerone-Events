// js/regCliente.js
document.addEventListener('DOMContentLoaded', function () {
  const APP  = '/' + window.location.pathname.split('/')[1];
  const BASE = window.location.origin + APP + '/controllers/regClienteController.jsp';

  const formCreate   = document.getElementById('formCliente');
  const btnCreate    = document.querySelector('button[form="formCliente"]');
  const modalCreate  = document.getElementById('modalCliente');
  const formEdit     = document.getElementById('formEditCliente');
  const modalEdit    = document.getElementById('modalEditCliente');

  const escapeHtml = s => String(s).replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]));
  const escapeAttr = s => String(s).replace(/"/g,'&quot;');

  function renderList(payload){
    const ul = document.getElementById('listClientes');
    if (!ul) return;
    ul.innerHTML = '';

    const rows = (payload && payload.data) ? payload.data : [];
    rows.forEach(c => {
      const li = document.createElement('li');
      li.className = 'collection-item service-item';

      const fullName = `${c.name || ''} ${c.lastname || ''}`.trim();
      const chipEmail = c.email ? `<span class="chip">${escapeHtml(c.email)}</span>` : '';
      const chipPhone = c.phone ? `<span class="chip">${escapeHtml(c.phone)}</span>` : '';
      const chipLoc   = (c.city||c.state) ? `<span class="chip">${escapeHtml((c.city||'') + (c.state? ', '+c.state : ''))}</span>` : '';
      const chipCp    = c.cp ? `<span class="chip">CP ${escapeHtml(c.cp)}</span>` : '';

      li.innerHTML = `
        <div class="service-main">
          <div class="service-name blue-text text-darken-2">${escapeHtml(fullName || '(Sin nombre)')}</div>
          <div class="service-meta">
            <span class="grey-text">ID: ${c.id}</span>
            ${chipEmail}${chipPhone}${chipLoc}${chipCp}
          </div>
        </div>
        <div class="service-actions">
          <a class="btn-small btn-edit" style="background:#0a2a66;border-radius:12px;"
             title="Editar"
             data-id="${c.id}"
             data-name="${escapeAttr(c.name||'')}"
             data-lastname="${escapeAttr(c.lastname||'')}"
             data-email="${escapeAttr(c.email||'')}"
             data-phone="${escapeAttr(c.phone||'')}"
             data-address="${escapeAttr(c.address||'')}"
             data-city="${escapeAttr(c.city||'')}"
             data-state="${escapeAttr(c.state||'')}"
             data-cp="${escapeAttr(c.cp||'')}">
            <i class="material-icons">edit</i>
          </a>
          <a class="btn-small red btn-delete" style="border-radius:12px;" title="Eliminar"
             data-id="${c.id}" data-name="${escapeAttr(fullName)}">
            <i class="material-icons">delete</i>
          </a>
        </div>`;
      ul.appendChild(li);
    });
  }

  function loadClientes(){
    fetch(BASE + '?action=list', { headers:{'Accept':'application/json'} })
      .then(async r=>{
        const txt = await r.text();
        if(!r.ok){ console.error('LIST HTTP', r.status, txt); throw new Error('HTTP '+r.status); }
        try{ return JSON.parse(txt); }catch(e){ console.error('LIST no-JSON:', txt); throw e; }
      })
      .then(renderList)
      .catch(()=> M.toast({ html:'No se pudo cargar la lista', classes:'red' }));
  }

  // Carga inicial
  loadClientes();

  // Crear
  if (formCreate) {
    formCreate.addEventListener('submit', function (e) {
      e.preventDefault();

      const body = new URLSearchParams({
        name_user:        document.getElementById('name_user').value.trim(),
        pa_lastname_user: document.getElementById('pa_lastname_user').value.trim(),
        email_user:       document.getElementById('email_user').value.trim(),
        phone_user:       document.getElementById('phone_user').value.trim(),
        address:          document.getElementById('address').value.trim(),
        city:             document.getElementById('city').value.trim(),
        state:            document.getElementById('state').value.trim(),
        cp:               document.getElementById('cp').value.trim()
      });

      if (!body.get('name_user')) { M.toast({html:'Nombre requerido', classes:'red'}); return; }

      if (btnCreate) btnCreate.disabled = true;

      console.log('CREATE ->', BASE, body.toString());
      fetch(BASE, {
        method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded','Accept':'application/json'},
        body: body.toString()
      })
      .then(async r=>{
        const txt = await r.text();
        if(!r.ok){ console.error('CREATE HTTP', r.status, txt); throw new Error('HTTP '+r.status); }
        try{ return JSON.parse(txt); }catch(e){ console.error('CREATE no-JSON:', txt); throw e; }
      })
      .then(d=>{
        if(d && d.ok){
          M.toast({html:'Cliente guardado', classes:'green'});
          formCreate.reset();
          const inst = M.Modal.getInstance(modalCreate); if (inst) inst.close();
          loadClientes();
        }else{
          M.toast({html:'No se pudo guardar', classes:'red'});
        }
      })
      .catch(()=> M.toast({html:'Error de conexión', classes:'red'}))
      .finally(()=>{ if (btnCreate) btnCreate.disabled = false; });
    });
  }

  // Abrir edición
  document.addEventListener('click', function (e) {
    const btn = e.target.closest('.btn-edit');
    if (!btn) return;

    document.getElementById('edit_id_cliente').value        = btn.dataset.id;
    document.getElementById('edit_name_user').value         = btn.dataset.name || '';
    document.getElementById('edit_pa_lastname_user').value  = btn.dataset.lastname || '';
    document.getElementById('edit_email_user').value        = btn.dataset.email || '';
    document.getElementById('edit_phone_user').value        = btn.dataset.phone || '';
    document.getElementById('edit_address').value           = btn.dataset.address || '';
    document.getElementById('edit_city').value              = btn.dataset.city || '';
    document.getElementById('edit_state').value             = btn.dataset.state || '';
    document.getElementById('edit_cp').value                = btn.dataset.cp || '';

    M.updateTextFields();
    const inst = M.Modal.getInstance(modalEdit) || M.Modal.init(modalEdit);
    inst.open();
  });

  // Actualizar
  if (formEdit) {
    formEdit.addEventListener('submit', function (e) {
      e.preventDefault();

      const body = new URLSearchParams({
        id_cliente:       document.getElementById('edit_id_cliente').value,
        name_user:        document.getElementById('edit_name_user').value.trim(),
        pa_lastname_user: document.getElementById('edit_pa_lastname_user').value.trim(),
        email_user:       document.getElementById('edit_email_user').value.trim(),
        phone_user:       document.getElementById('edit_phone_user').value.trim(),
        address:          document.getElementById('edit_address').value.trim(),
        city:             document.getElementById('edit_city').value.trim(),
        state:            document.getElementById('edit_state').value.trim(),
        cp:               document.getElementById('edit_cp').value.trim()
      });

      fetch(BASE + '?action=update', {
        method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded','Accept':'application/json'},
        body: body.toString()
      })
      .then(async r=>{
        const txt = await r.text();
        if(!r.ok){ console.error('UPDATE HTTP', r.status, txt); throw new Error('HTTP '+r.status); }
        try{ return JSON.parse(txt); }catch(e){ console.error('UPDATE no-JSON:', txt); throw e; }
      })
      .then(d=>{
        if(d && d.ok){
          const inst = M.Modal.getInstance(modalEdit); if (inst) inst.close();
          Swal.fire({icon:'success', title:'Registro actualizado', timer:1200, showConfirmButton:false});
          loadClientes();
        }else{
          Swal.fire({icon:'error', title:'No se pudo actualizar'});
        }
      })
      .catch(()=> Swal.fire({icon:'error', title:'Error de conexión'}));
    });
  }

  // Eliminar
  document.addEventListener('click', function(e){
    const btn = e.target.closest('.btn-delete');
    if(!btn) return;

    const id   = btn.dataset.id;
    const name = btn.dataset.name || 'este cliente';

    Swal.fire({
      icon: 'warning',
      title: '¿Eliminar?',
      html: 'Vas a eliminar <b>'+escapeHtml(name)+'</b>',
      showCancelButton: true,
      confirmButtonText: 'Sí, eliminar',
      cancelButtonText: 'Cancelar'
    }).then(function(res){
      if(!res.isConfirmed) return;

      fetch(BASE + '?action=delete', {
        method: 'POST',
        headers: {'Content-Type':'application/x-www-form-urlencoded','Accept':'application/json'},
        body: new URLSearchParams({ id_cliente: id }).toString()
      })
      .then(async r=>{
        const txt = await r.text();
        if(!r.ok){ console.error('DELETE HTTP', r.status, txt); throw new Error('HTTP '+r.status); }
        try{ return JSON.parse(txt); }catch(e){ console.error('DELETE no-JSON:', txt); throw e; }
      })
      .then(d=>{
        if(d && d.ok){
          Swal.fire({ icon:'success', title:'Registro eliminado', timer:1100, showConfirmButton:false });
          loadClientes();
        }else{
          Swal.fire({ icon:'error', title:'No se pudo eliminar' });
        }
      })
      .catch(() => Swal.fire({ icon:'error', title:'Error de conexión' }));
    });
  });

});
