<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="includes/header.jsp"/>
<jsp:include page="includes/nav.jsp"/>

<style>
  .form-card{ border-radius:14px; }
  .btn-round{ border-radius:20px; }
  .color-opcion{ display:flex; gap:14px; align-items:center; flex-wrap:wrap; }
  .color-opcion label{ display:flex; align-items:center; gap:8px; cursor:pointer; }
  .swatch{ width:20px; height:20px; border-radius:50%; display:inline-block; border:2px solid rgba(0,0,0,.15); }
  .section-title{ margin:14px 0 6px; font-weight:600; color:#1a237e; }
  .service-row{ display:grid; grid-template-columns: 1fr 120px 140px; gap:12px; }
  @media(max-width:600px){ .service-row{ grid-template-columns: 1fr 100px 120px; } }
  .services-list .collection-item{ display:grid; grid-template-columns: 2fr 80px 110px 110px; gap:8px; align-items:center; }
  @media(max-width:600px){
    .services-list .collection-item{ grid-template-columns: 1fr; row-gap:6px; }
  }
</style>

<div class="container">
  <div class="row">
    <div class="col s12 m10 l8 offset-m1 offset-l2">
      <div class="card form-card z-depth-1">
        <div class="card-content">
          <span class="card-title blue-text text-darken-2">Nueva reservación</span>

          <form id="formReserva" method="post" action="#">

            <!-- Nombre del evento -->
            <div class="input-field">
              <input id="evento" name="evento" type="text" required>
              <label for="evento">Nombre del evento</label>
            </div>

            <!-- Color del evento -->
            <div class="section-title">Color del evento</div>
            <div class="color-opcion">
              <label><input name="color_evento" type="radio" value="#e53935" required/><span class="swatch" style="background:#e53935;"></span>Rojo</label>
              <label><input name="color_evento" type="radio" value="#43a047"/><span class="swatch" style="background:#43a047;"></span>Verde</label>
              <label><input name="color_evento" type="radio" value="#fbc02d"/><span class="swatch" style="background:#fbc02d;"></span>Amarillo</label>
              <label><input name="color_evento" type="radio" value="#1e88e5"/><span class="swatch" style="background:#1e88e5;"></span>Azul</label>
              <label><input name="color_evento" type="radio" value="#9575cd"/><span class="swatch" style="background:#9575cd;"></span>Morado claro</label>
            </div>

            <!-- Fechas -->
            <div class="row" style="margin-top:8px;">
              <div class="col s12 m6">
                <div class="input-field">
                  <input id="fecha_inicio" name="date_reservation_start" type="datetime-local" required>
                  <label for="fecha_inicio" class="active">Fecha inicio</label>
                </div>
              </div>
              <div class="col s12 m6">
                <div class="input-field">
                  <input id="fecha_fin" name="date_reservation_end" type="datetime-local" required>
                  <label for="fecha_fin" class="active">Fecha fin</label>
                </div>
              </div>
            </div>

            <!-- Estatus de la reservación -->
            <div class="input-field">
              <span class="section-title">Estatus de la reservación</span>
              <select name="status_reservation" class="browser-default" required>
                <option value="" disabled selected>Selecciona estatus</option>
                <option value="adeudo">Adeudo</option>
                <option disabled value="pagada">Pagada</option>
                <option value="activa">Activa</option>
              </select>
            </div>

            <!-- Cliente y Administrador -->
            <div class="row">

              <div class="col s12 m6">
                <div class="input-field">
                  <span class="section-title">Cliente</span>
                  <select id="selCliente" name="id_cliente" class="browser-default" required>
                    <option value="" disabled selected>Selecciona un cliente</option>
                    <!-- opciones se llenan por JS -->
                  </select>
                </div>
              </div>

              <div class="col s12 m6">
                <div class="input-field">
                  <span class="section-title">Administrador</span>
                  <select id="selAdmin" name="id_user" class="browser-default" required>
                    <option value="" disabled selected>Selecciona administrador</option>
                    <!-- opciones por JS -->
                  </select>
                </div>
              </div>

            <!-- Servicios (selección + cantidad) -->
            <div class="section-title">Servicios</div>
            <div class="service-row">
              <div class="input-field">
                <select id="selServicio" name="id_service" class="browser-default">
                  <option value="" disabled selected>Selecciona un servicio</option>
                  <option value="1" data-precio="100">Mesa — $100.00</option>
                  <option value="2" data-precio="14">Silla — $14.00</option>
                  <option value="3" data-precio="50">Sillas x4 — $50.00</option>
                </select>
              </div>
              <div class="input-field">
                <input id="cantidad" name="amount_service" type="number" min="1" step="1" value="1">
                <label for="cantidad" class="active">Cantidad</label>
              </div>
              <div class="input-field" style="display:flex;align-items:center;">
                <a class="btn btn-round blue darken-4 waves-effect" href="#!">Agregar</a>
              </div>
            </div>

            <!-- Lista de servicios agregados (placeholder, solo diseño) -->
            <ul class="collection services-list z-depth-1" style="border-radius:12px; margin-top:10px;">
              <li class="collection-item">
                <span><b>Servicio</b></span>
                <span><b>Cant.</b></span>
                <span><b>P. Unit.</b></span>
                <span><b>Total</b></span>
              </li>
              <!-- Ejemplo visual (quitar cuando se programe) -->
              <li class="collection-item">
                <span>Sillas x4</span>
                <span>2</span>
                <span>$50.00</span>
                <span>$100.00</span>
              </li>
            </ul>

            <!-- Totales (solo visual) -->
            <div class="right-align" style="margin-top:12px;">
              <span class="grey-text">Total servicios:</span>
              <span class="blue-text text-darken-2" style="font-weight:600;">$0.00</span>
            </div>

            <!-- Botón principal -->
            <div style="margin-top:18px;">
              <button type="submit" class="btn btn-round waves-effect waves-light" style="background:#0a2a66;">
                Guardar reservación
              </button>
            </div>

          </form>
        </div>
      </div>
    </div>
  </div>
</div>




<script src="js/regEvent.js"></script>