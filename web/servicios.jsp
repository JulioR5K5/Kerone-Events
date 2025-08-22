<jsp:include page="includes/header.jsp"/>
<jsp:include page="includes/nav.jsp"/>

<style>
  /* Botones redondeados */
  .btn-round{ border-radius:20px; }
  .actions .btn-small{ border-radius:12px; }

  :root{ --k-gap:12px; }

  /* ================== LISTA (card) ================== */
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

  /* Chips */
  .chip-price{ background:#e3f2fd; color:#0a2a66; }
  .chip-on{ background:#e8f5e9; color:#2e7d32; }
  .chip-off{ background:#ffebee; color:#c62828; }

  /* ================== RESPONSIVE VISIBILITY ================== */
  /* Por defecto (desktop/tablet ≥ 993px): mostrar tabla, ocultar lista */
  .k-table{ display:table; width:100%; }
  .k-list{ display:none; }

  /* En mobile (≤ 992px): ocultar tabla, mostrar lista */
  @media (max-width: 992px){
    .k-table{ display:none; }
    .k-list{ display:block; }
    .collection .service-item{ grid-template-columns: 1fr; align-items:flex-start; }
    .service-actions{ margin-top:8px; }
  }

  /* ================== MODALES ================== */
  .modal{ max-width:720px; }
  @media (max-width: 992px){
    .modal{ width:96% !important; }
  }
  .modal .modal-content{
    padding-bottom:8px;
    max-height: calc(90vh - 60px);
    overflow:auto;
  }

  /* Inputs legibles sin romper Materialize */
  .input-field input[type="text"],
  .input-field input[type="number"]{ font-size:1rem; }
</style>

<div class="container">
  <div class="row">
    <div class="col s12 m10 l8 offset-m1 offset-l2">

      <!-- Barra superior -->
      <div class="section" style="display:flex;justify-content:space-between;align-items:center;">
        <h5 class="blue-text text-darken-2" style="margin:0;">Servicios</h5>
        <a href="#modalServicio" class="btn modal-trigger blue btn-round">
          <i class="material-icons left">add</i>Agregar servicio
        </a>
      </div>

      <!-- Tabla (desktop/tablet) -->
      <table class="highlight responsive-table k-table">
        <thead>
          <!-- Si quieres cabeceras, descomenta y rellena -->
          <!--
          <tr>
            <th>ID</th>
            <th>Nombre</th>
            <th>Precio</th>
            <th>Estatus</th>
            <th class="center-align">Acciones</th>
          </tr>
          -->
        </thead>
        <tbody id="tbodyServicios">
          <!-- filas dinámicas aquí -->
        </tbody>
      </table>

      <!-- Lista (mobile) -->
      <ul id="listServicios" class="collection z-depth-1 k-list" style="border-radius:12px;">
        <!-- ítems dinámicos aquí -->
      </ul>

    </div>
  </div>
</div>

<!-- Modal: nuevo servicio -->
<div id="modalServicio" class="modal">
  <div class="modal-content">
    <h5 class="blue-text text-darken-2">Nuevo servicio</h5>

    <form id="formServicio" method="post" action="#">
      <div class="input-field">
        <input id="name_service" name="name_service" type="text" required>
        <label for="name_service">Nombre del servicio</label>
      </div>

      <div class="input-field">
        <input id="price_service" name="price_service" type="number" min="0" step="0.01" required>
        <label for="price_service">Precio</label>
      </div>

      <div class="switch" style="margin:10px 0 20px;">
        <label>
          Inactivo
          <input id="status_service" name="status_service" type="checkbox" checked>
          <span class="lever"></span>
          Activo
        </label>
      </div>
    </form>
  </div>

  <div class="modal-footer" style="display:flex;gap:10px;">
    <a href="#!" class="modal-close btn-flat">Cancelar</a>
    <button form="formServicio" type="submit" class="btn btn-round" style="background:#0a2a66;">Enviar</button>
  </div>
</div>

<!-- Modal: editar servicio -->
<div id="modalEditServicio" class="modal">
  <div class="modal-content">
    <h5 class="blue-text text-darken-2">Editar servicio</h5>

    <form id="formEditServicio" method="post" action="#">
      <input type="hidden" id="edit_id_service" name="id_service">

      <div class="input-field">
        <input id="edit_name_service" name="name_service" type="text" required>
        <label for="edit_name_service" class="active">Nombre del servicio</label>
      </div>

      <div class="input-field">
        <input id="edit_price_service" name="price_service" type="number" min="0" step="0.01" required>
        <label for="edit_price_service" class="active">Precio</label>
      </div>

      <div class="switch" style="margin:10px 0 0;">
        <label>
          Inactivo
          <input id="edit_status_service" name="status_service" type="checkbox">
          <span class="lever"></span>
          Activo
        </label>
      </div>
    </form>
  </div>
  <div class="modal-footer" style="display:flex;gap:10px;">
    <a href="#!" class="modal-close btn-flat">Cancelar</a>
    <button form="formEditServicio" type="submit" class="btn btn-round" style="background:#0a2a66;">Actualizar</button>
  </div>
</div>

<script>
  document.addEventListener('DOMContentLoaded', function(){
    if (window.M && M.Modal) M.Modal.init(document.querySelectorAll('.modal'));
  });
</script>

<script src="https://cdnjs.cloudflare.com/ajax/libs/fetch/3.6.20/fetch.min.js"></script>
<script src="js/registrarServicio.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
