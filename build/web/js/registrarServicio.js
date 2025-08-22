// js/registrarServicio.js — versión XHR compatible con todos los navegadores
document.addEventListener('DOMContentLoaded', function () {
  // Materialize modals
  if (window.M && M.Modal) M.Modal.init(document.querySelectorAll('.modal'));

  // ====== CONFIG ======
  var BASE = 'http://localhost:8080/Kerone-Events/controllers/regServicioController.jsp';

  // ====== HELPERS ======
  function $(id){ return document.getElementById(id); }
  function escapeHtml(str){
    return String(str==null?'':str).replace(/[&<>"']/g, function(m){
      return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m];
    });
  }
  function escapeAttr(str){ return String(str==null?'':str).replace(/"/g,'&quot;'); }
  function toastOk(msg){ if (window.M) M.toast({html: msg, classes: 'green'}); }
  function toastErr(msg){ if (window.M) M.toast({html: msg, classes: 'red'}); }

  // XHR util (GET/POST) con no-cache
  function xhrJSON(method, url, data, cbOk, cbErr){
    try{
      var xhr = new XMLHttpRequest();
      // anti-caché
      var sep = url.indexOf('?')>-1 ? '&' : '?';
      url += sep + 'nocache=' + Date.now();

      xhr.open(method, url, true);
      if (method === 'POST') {
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
      }
      xhr.setRequestHeader('Cache-Control','no-cache, no-store, must-revalidate');
      xhr.setRequestHeader('Pragma','no-cache');
      xhr.setRequestHeader('Expires','0');

      xhr.onreadystatechange = function(){
        if (xhr.readyState === 4){
          if (xhr.status >= 200 && xhr.status < 300){
            var text = xhr.responseText || '';
            try {
              var json = JSON.parse(text);
              cbOk && cbOk(json);
            } catch(e){
              cbErr && cbErr('Respuesta no es JSON válido');
            }
          } else {
            cbErr && cbErr('HTTP '+xhr.status);
          }
        }
      };
      xhr.send(data || null);
    }catch(e){
      cbErr && cbErr('Error XHR');
    }
  }

  // ====== RENDER ======
  function renderServicios(payload){
    var ulist = $('listServicios');
    var tbody = $('tbodyServicios');
    if (ulist) ulist.innerHTML = '';
    if (tbody) tbody.innerHTML = '';

    var rows = (payload && payload.data) ? payload.data : [];
    for (var i=0; i<rows.length; i++){
      var s = rows[i];
      var id = s.id;
      var name = s.name || '';
      var price = Number(s.price||0).toFixed(2);
      var status = String(s.status)==='1';

      if (ulist){
        var li = document.createElement('li');
        li.className = 'collection-item service-item';
        li.innerHTML =
          '<div class="service-main">'+
            '<div class="service-name blue-text text-darken-2">'+escapeHtml(name)+'</div>'+
            '<div class="service-meta">'+
              '<span class="grey-text">ID: '+id+'</span>'+
              '<span class="chip chip-price">$ '+price+'</span>'+
              (status ? '<span class="chip chip-on">Activo</span>' : '<span class="chip chip-off">Inactivo</span>')+
            '</div>'+
          '</div>'+
          '<div class="service-actions">'+
            '<a class="btn-small btn-edit blue" '+
               'data-id="'+id+'" '+
               'data-name="'+escapeAttr(name)+'" '+
               'data-price="'+price+'" '+
               'data-status="'+(status?'1':'0')+'">'+
              '<i class="material-icons">edit</i>'+
            '</a>'+
            '<a class="btn-small red btn-delete" data-id="'+id+'" data-name="'+escapeAttr(name)+'">'+
              '<i class="material-icons">delete</i>'+
            '</a>'+
          '</div>';
        ulist.appendChild(li);
      }

      if (tbody){
        var tr = document.createElement('tr');
        tr.innerHTML =
          '<td>'+id+'</td>'+
          '<td>'+escapeHtml(name)+'</td>'+
          '<td>$ '+price+'</td>'+
          '<td>'+(status?'Activo':'Inactivo')+'</td>'+
          '<td>'+
            '<a class="btn-small btn-edit blue" '+
               'data-id="'+id+'" '+
               'data-name="'+escapeAttr(name)+'" '+
               'data-price="'+price+'" '+
               'data-status="'+(status?'1':'0')+'">'+
              '<i class="material-icons">edit</i>'+
            '</a> '+
            '<a class="btn-small red btn-delete" data-id="'+id+'" data-name="'+escapeAttr(name)+'">'+
              '<i class="material-icons">delete</i>'+
            '</a>'+
          '</td>';
        tbody.appendChild(tr);
      }
    }
  }

  // ====== CARGA INICIAL ======
  function loadServicios(){
    xhrJSON('GET', BASE+'?action=list', null, function(json){
      if (json && json.ok) {
        renderServicios(json);
      } else {
        toastErr('No se pudo cargar la lista');
      }
    }, function(){
      toastErr('No se pudo cargar la lista');
    });
  }
  loadServicios();

  // ====== CREAR ======
  var formCreate = $('formServicio');
  var btnCreate  = document.querySelector('button[form="formServicio"]');
  if (formCreate){
    formCreate.addEventListener('submit', function(e){
      e.preventDefault();
      var name   = ($('name_service').value||'').trim();
      var price  = ( $('price_service').value||'' ).replace(',', '.');
      var status = $('status_service').checked ? '1':'0';

      if (!name || !price){ toastErr('Completa nombre y precio'); return; }
      if (btnCreate) btnCreate.disabled = true;

      var body = 'name_service='+encodeURIComponent(name)+
                 '&price_service='+encodeURIComponent(price)+
                 '&status_service='+encodeURIComponent(status);

      xhrJSON('POST', BASE, body, function(json){
        if (json && json.ok){
          toastOk('Servicio guardado');
          formCreate.reset();
          var inst = window.M && M.Modal.getInstance( $('modalServicio') );
          if (!inst && window.M) inst = M.Modal.init( $('modalServicio') );
          if (inst) inst.close();
          loadServicios();
        } else {
          toastErr('No se pudo guardar');
        }
        if (btnCreate) btnCreate.disabled = false;
      }, function(){
        toastErr('Error de conexión');
        if (btnCreate) btnCreate.disabled = false;
      });
    });
  }

  // ====== EDITAR ======
  document.addEventListener('click', function(e){
    var btn = e.target.closest && e.target.closest('.btn-edit');
    if (!btn) return;

    $('edit_id_service').value = btn.getAttribute('data-id');
    $('edit_name_service').value = btn.getAttribute('data-name') || '';
    $('edit_price_service').value = btn.getAttribute('data-price') || '0.00';
    $('edit_status_service').checked = (btn.getAttribute('data-status') === '1');

    if (window.M){
      M.updateTextFields();
      var inst = M.Modal.getInstance( $('modalEditServicio') ) || M.Modal.init( $('modalEditServicio') );
      inst.open();
    }
  });

  // ====== ACTUALIZAR ======
  var formEdit = $('formEditServicio');
  if (formEdit){
    formEdit.addEventListener('submit', function(e){
      e.preventDefault();

      var id     = $('edit_id_service').value;
      var name   = ($('edit_name_service').value||'').trim();
      var price  = ( $('edit_price_service').value||'' ).replace(',', '.');
      var status = $('edit_status_service').checked ? '1':'0';

      var body = 'id_service='+encodeURIComponent(id)+
                 '&name_service='+encodeURIComponent(name)+
                 '&price_service='+encodeURIComponent(price)+
                 '&status_service='+encodeURIComponent(status);

      xhrJSON('POST', BASE+'?action=update', body, function(json){
        if (json && json.ok){
          if (window.Swal) Swal.fire({icon:'success', title:'Registro actualizado', timer:1200, showConfirmButton:false});
          var inst = window.M && M.Modal.getInstance( $('modalEditServicio') );
          if (inst) inst.close();
          loadServicios();
        } else {
          if (window.Swal) Swal.fire({icon:'error', title:'No se pudo actualizar'});
          else toastErr('No se pudo actualizar');
        }
      }, function(){
        if (window.Swal) Swal.fire({icon:'error', title:'Error de conexión'});
        else toastErr('Error de conexión');
      });
    });
  }

  // ====== ELIMINAR ======
  document.addEventListener('click', function(e){
    var btn = e.target.closest && e.target.closest('.btn-delete');
    if (!btn) return;

    var id = btn.getAttribute('data-id');
    var name = btn.getAttribute('data-name') || 'este servicio';

    function doDelete(){
      var body = 'id_service='+encodeURIComponent(id);
      xhrJSON('POST', BASE+'?action=delete', body, function(json){
        if (json && json.ok){
          if (window.Swal) Swal.fire({icon:'success', title:'Registro eliminado', timer:1100, showConfirmButton:false});
          else toastOk('Registro eliminado');
          loadServicios();
        } else {
          if (window.Swal) Swal.fire({icon:'error', title:'No se pudo eliminar'});
          else toastErr('No se pudo eliminar');
        }
      }, function(){
        if (window.Swal) Swal.fire({icon:'error', title:'Error de conexión'});
        else toastErr('Error de conexión');
      });
    }

    if (window.Swal){
      Swal.fire({
        icon:'warning',
        title:'¿Quieres eliminar el servicio?',
        html:'Vas a eliminar <b>'+escapeHtml(name)+'</b>',
        showCancelButton:true,
        confirmButtonText:'Sí, eliminar',
        cancelButtonText:'Cancelar'
      }).then(function(res){ if (res.isConfirmed) doDelete(); });
    } else {
      if (confirm('Eliminar: '+name+' ?')) doDelete();
    }
  });

});

