<jsp:include page="includes/header.jsp"/>
<jsp:include page="includes/nav.jsp"/>

<style>
  .btn-round{ border-radius:20px; }

  /* Lista “cards” con grid responsivo */
  .collection.pagos-list{ border-radius:12px; overflow:hidden; }

  /* Encabezado y filas con la misma grilla */
  .pago-head,
  .pago-item{
    display:grid;
    grid-template-columns: 1fr 140px 140px 120px; /* Evento | Total | Adeudo | Acciones */
    gap:16px;
    align-items:center;
    padding:14px 16px;
  }
  .pago-head{ font-weight:600; padding:10px 16px; }

  /* Columna principal */
  .pago-title{ font-weight:700; color:#0a2a66; margin-bottom:4px; }
  .pago-tags{
    font-size:.92rem; color:#666;
    display:flex; gap:14px; flex-wrap:wrap;
  }

  /* Chips */
  .chip{ border-radius:12px; padding:6px 10px; font-weight:600; }
  .chip-total{ background:#e3f2fd; color:#0a2a66; }
  .chip-debt{  background:#ffebee; color:#c62828; }

  /* Acciones */
  .pago-actions{ display:flex; gap:10px; justify-content:flex-start; }
  .btn-aqua{ background:linear-gradient(90deg,#12cbc4,#1289a7)!important; border-radius:12px; }
  .btn-danger{ background:#e53935!important; border-radius:12px; }

  /* Responsive */
  @media (max-width: 720px){
    .pago-head, .pago-item{ grid-template-columns: 1fr; }
    .pago-head span:nth-child(n+2){ display:none; } /* oculta títulos de columnas en móvil */
    .pago-actions{ margin-top:6px; }
  }
</style>

<div class="container">
  <div class="row">
    <div class="col s12 m10 l8 offset-m1 offset-l2">
      <div class="section" style="display:flex;justify-content:space-between;align-items:center;">
        <h5 class="blue-text text-darken-2" style="margin:0;">Pagos</h5>
      </div>

      <!-- Lista de pagos (la llena pagos.js) -->
      <ul id="pagosList" class="collection pagos-list z-depth-1"></ul>
    </div>
  </div>
</div>

<!-- Modal: Registrar pago -->
<div id="modalPago" class="modal">
  <div class="modal-content">
    <h5 class="blue-text text-darken-2">Registrar pago</h5>

    <form id="formPago" method="post" action="#">
      <!-- Info del evento (solo lectura) -->
      <div class="row" style="margin-bottom:6px;">
        <div class="col s12">
          <div class="grey-text text-darken-2" style="font-size:.95rem;">Evento</div>
          <div id="pay_event_name" style="font-weight:600;" class="blue-text text-darken-2">—</div>
        </div>
      </div>

      <div class="row" style="margin-bottom:0;">
        <div class="col s12 m6">
          <div class="grey-text text-darken-2" style="font-size:.95rem;">Adeudo actual</div>
          <div id="pay_adeudo_actual" style="font-weight:600;">$ 0.00</div>
        </div>
        <div class="col s12 m6">
          <div class="grey-text text-darken-2" style="font-size:.95rem;">Total del evento</div>
          <div id="pay_monto_total" style="font-weight:600;">$ 0.00</div>
        </div>
      </div>

      <div class="divider" style="margin:12px 0;"></div>

      <!-- Fecha de pago -->
      <div class="input-field">
        <input id="fecha_pago" name="fecha_pago" type="date" required>
        <label for="fecha_pago" class="active">Fecha de pago</label>
      </div>

      <!-- Monto -->
      <div class="input-field">
        <input id="monto_pago" name="monto_pago" type="number" min="0" step="0.01" required>
        <label for="monto_pago" class="active">Monto a pagar</label>
      </div>

      <!-- Tipo de pago (estático) -->
      <div class="input-field">
        <span class="grey-text text-darken-2">Tipo de pago</span>
        <select id="tipo_pago" name="tipo_pago" class="browser-default" required>
          <option value="" disabled selected>Selecciona tipo</option>
          <option value="anticipo">Anticipo</option>
          <option value="parcialidad">Parcialidad</option>
          <option value="liquidacion">Liquidacion</option>
        </select>
      </div>

      <!-- Método de pago (ESTÁTICO y con IDs REALES si quieres) -->
      <div class="input-field">
        <span class="grey-text text-darken-2">Método de pago</span>
        <select id="id_metodo_pago" name="id_metodo_pago" class="browser-default" required>
          <option value="" disabled selected>Selecciona método</option>
          <option value="3">Efectivo</option>
          <option value="7">Tarjeta</option>
          <option value="9">Transferencia</option>
        </select>
      </div>

      <!-- Hidden para el POST -->
      <input type="hidden" id="pay_id_folio"        name="id_folio_services" value="">
      <input type="hidden" id="pay_id_reservation"  name="id_reservation"    value="">
    </form>
  </div>

  <div class="modal-footer" style="display:flex;gap:10px;">
    <a href="#!" class="modal-close btn-flat">Cancelar</a>
    <button form="formPago" type="submit" class="btn btn-round" style="background:#0a2a66;">Guardar pago</button>
  </div>
</div>

<script src="js/pagos.js"></script>
