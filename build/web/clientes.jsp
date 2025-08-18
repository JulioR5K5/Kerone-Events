<%-- 
    Document   : clientes
    Created on : 17/08/2025, 02:33:06 AM
    Author     : Students
--%>
<%-- clientes.jsp --%>
<jsp:include page="includes/header.jsp"/>
<jsp:include page="includes/nav.jsp"/>

<style>
  /* ---------- Botones redondeados ---------- */
  .btn-round{ border-radius:20px; }
  .actions .btn-small{ border-radius:12px; }

  /* ---------- Lista bonita y responsiva ---------- */
  :root{ --k-gap:12px; }

  .collection .service-item{
    display:grid;
    grid-template-columns: 1fr auto; /* info | acciones */
    align-items:center;
    gap:var(--k-gap);
    padding:14px 16px;
  }
  .service-main{ min-width:220px; }
  .service-name{ font-weight:600; margin:0 0 4px; overflow-wrap:anywhere; }
  .service-meta{ display:flex; gap:8px; flex-wrap:wrap; align-items:center; line-height:1.25; }
  .service-actions{ display:flex; gap:8px; white-space:nowrap; }

  /* Chips (por si los usas después) */
  .chip-on{ background:#e8f5e9; color:#2e7d32; }
  .chip-off{ background:#ffebee; color:#c62828; }

  /* ---------- Responsivo ---------- */
  @media (max-width: 992px){
    /* En tablet/móvil apilar acciones debajo */
    .collection .service-item{ grid-template-columns: 1fr; align-items:flex-start; }
    .service-actions{ margin-top:8px; }
  }

  /* Ajuste fino para pantallas muy angostas */
  @media (max-width: 360px){
    .service-actions .btn-small i{ font-size:20px; }
  }

  /* ---------- Modales responsivos ---------- */
  .modal{ max-width:720px; }                      /* desktop */
  @media (max-width: 992px){
    .modal{ width:96% !important; }               /* móvil/tablet */
  }
  .modal .modal-content{
    padding-bottom:8px;
    max-height: calc(90vh - 60px);                /* evita que se corte en teléfonos */
    overflow:auto;
  }

  /* Campos: mantiene buena legibilidad sin romper Materialize */
  .input-field input[type="text"],
  .input-field input[type="email"],
  .input-field input[type="tel"],
  .input-field input[type="number"]{
    font-size:1rem;
  }
</style>

<div class="container">
  <div class="row">
    <div class="col s12 m10 l8 offset-m1 offset-l2">

      <!-- Barra superior -->
      <div class="section" style="display:flex;justify-content:space-between;align-items:center;">
        <h5 class="blue-text text-darken-2" style="margin:0;">Clientes</h5>
        <a href="#modalCliente" class="btn modal-trigger blue btn-round">
          <i class="material-icons left">add</i>Registrar Cliente
        </a>
      </div>

      <!-- Lista (JS rellena) -->
      <ul id="listClientes" class="collection z-depth-1" style="border-radius:12px;">
        <!-- ítems dinámicos aquí -->
      </ul>

    </div>
  </div>
</div>

<!-- Modal: nuevo cliente -->
<div id="modalCliente" class="modal">
  <div class="modal-content">
    <h5 class="blue-text text-darken-2">Nuevo cliente</h5>

    <form id="formCliente" method="post" action="#">
      <div class="row">
        <div class="input-field col s12 m6">
          <input id="name_user" name="name_user" type="text" required>
          <label for="name_user">Nombre(s)</label>
        </div>

        <div class="input-field col s12 m6">
          <input id="pa_lastname_user" name="pa_lastname_user" type="text" required>
          <label for="pa_lastname_user">Apellido paterno</label>
        </div>

        <div class="input-field col s12 m6">
          <input id="email_user" name="email_user" type="email" required>
          <label for="email_user">Correo</label>
        </div>

        <div class="input-field col s12 m6">
          <input id="phone_user" name="phone_user" type="tel" required>
          <label for="phone_user">Telefono</label>
        </div>

        <div class="input-field col s12">
          <input id="address" name="address" type="text" required>
          <label for="address">Direccion</label>
        </div>

        <div class="input-field col s12 m4">
          <input id="city" name="city" type="text" required>
          <label for="city">Ciudad</label>
        </div>

        <div class="input-field col s12 m4">
          <input id="state" name="state" type="text" required>
          <label for="state">Estado</label>
        </div>

        <div class="input-field col s12 m4">
          <input id="cp" name="cp" type="number" min="0" step="1" required>
          <label for="cp">C.P.</label>
        </div>
      </div>
    </form>
  </div>

  <div class="modal-footer" style="display:flex;gap:10px;">
    <a href="#!" class="modal-close btn-flat">Cancelar</a>
    <button form="formCliente" type="submit" class="btn btn-round" style="background:#0a2a66;">Enviar</button>
  </div>
</div>

<!-- Modal: editar cliente -->
<div id="modalEditCliente" class="modal">
  <div class="modal-content">
    <h5 class="blue-text text-darken-2">Editar cliente</h5>

    <form id="formEditCliente" method="post" action="#">
      <input type="hidden" id="edit_id_cliente" name="id_cliente">

      <div class="row">
        <div class="input-field col s12 m6">
          <input id="edit_name_user" name="name_user" type="text" required>
          <label for="edit_name_user" class="active">Nombre(s)</label>
        </div>

        <div class="input-field col s12 m6">
          <input id="edit_pa_lastname_user" name="pa_lastname_user" type="text" required>
          <label for="edit_pa_lastname_user" class="active">Apellido paterno</label>
        </div>

        <div class="input-field col s12 m6">
          <input id="edit_email_user" name="email_user" type="email" required>
          <label for="edit_email_user" class="active">Correo</label>
        </div>

        <div class="input-field col s12 m6">
          <input id="edit_phone_user" name="phone_user" type="tel" required>
          <label for="edit_phone_user" class="active">Telefono</label>
        </div>

        <div class="input-field col s12">
          <input id="edit_address" name="address" type="text" required>
          <label for="edit_address" class="active">Direccion</label>
        </div>

        <div class="input-field col s12 m4">
          <input id="edit_city" name="city" type="text" required>
          <label for="edit_city" class="active">Ciudad</label>
        </div>

        <div class="input-field col s12 m4">
          <input id="edit_state" name="state" type="text" required>
          <label for="edit_state" class="active">Estado</label>
        </div>

        <div class="input-field col s12 m4">
          <input id="edit_cp" name="cp" type="number" min="0" step="1" required>
          <label for="edit_cp" class="active">C.P.</label>
        </div>
      </div>
    </form>
  </div>

  <div class="modal-footer" style="display:flex;gap:10px;">
    <a href="#!" class="modal-close btn-flat">Cancelar</a>
    <button form="formEditCliente" type="submit" class="btn btn-round" style="background:#0a2a66;">Actualizar</button>
  </div>
</div>

<!-- SweetAlert2 (si no lo tienes ya en header.jsp) -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<script>
  document.addEventListener('DOMContentLoaded', function(){
    if (window.M && M.Modal) M.Modal.init(document.querySelectorAll('.modal'));
  });
</script>

<script src="js/regCliente.js"></script>
