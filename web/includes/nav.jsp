<%-- nav.jsp --%>

<style>
  /* NAV con efecto flujo de luz (mismos colores) */
  nav.kerone{
    background: linear-gradient(90deg,#2d6cdf,#60a5fa,#2d6cdf) !important;
    background-size:300% 100%;
    animation:k-flow 6s linear infinite;
    z-index:1000; /* por encima de overlay/sidenav/contenido */
  }
  @keyframes k-flow{
    0%{background-position:0% 0}
    50%{background-position:100% 0}
    100%{background-position:0% 0}
  }

  /* SOLO alineación: sin cambiar tamaños del logo ni texto */
  nav .brand-logo{
    display:flex !important;
    align-items:center;
    gap:12px;
    left:16px !important;        /* evita centrado en xs de Materialize */
    transform:none !important;   /* para que no se desplace */
    white-space:nowrap;
  }
  nav .brand-logo img{ display:block; }   /* sin height/width -> respeta tu tamaño original */
  nav .brand-logo span{ display:block; }  /* sin font-size -> respeta tu tamaño original */

  /* Sidenav fijo mini debajo del nav */
  .sidenav.k-mini.sidenav-fixed{
    transform: translateX(0) !important;
    width:72px;
    overflow-x:hidden;
    transition:width .15s ease;
    top:64px;                      /* altura nav desktop */
    height:calc(100% - 64px);
    z-index:999;                   /* por encima del overlay */
  }
  @media (max-width: 992px){
    .sidenav.k-mini.sidenav-fixed{
      top:56px;                    /* altura nav móvil */
      height:calc(100% - 56px);
    }
  }

  /* Al hover: se EXPANDE ENCIMA (no empuja contenido) */
  .sidenav.k-mini.sidenav-fixed:hover{
    width:260px;
    box-shadow: 0 8px 24px rgba(0,0,0,.28);
  }
  .sidenav.k-mini a{ display:flex; align-items:center; gap:14px; }
  .sidenav.k-mini .menu-label{ white-space:nowrap; opacity:0; transition:opacity .15s; }
  .sidenav.k-mini.sidenav-fixed:hover .menu-label{ opacity:1; }

  /* El contenido mantiene padding fijo del mini */
  body.kerone-layout{ padding-left:72px; }
  @media (max-width: 992px){ body.kerone-layout{ padding-left:72px; } }

  /* Overlay oscuro cuando el sidenav está expandido (no aplasta nada) */
  .kerone-scrim{
    position:fixed; inset:0;
    background:rgba(0,0,0,.38);
    opacity:0; pointer-events:none;
    transition:opacity .12s ease;
    z-index:950; /* debajo del nav/sidenav, encima del contenido */
  }
  .kerone-scrim.show{ opacity:1; pointer-events:auto; }
</style>

<!-- NAV superior (misma estructura) -->
<nav class="kerone">
  <div class="nav-wrapper">
    <a href="#!" class="brand-logo" style="gap:12px;">
      <img src="img/logPf.png" alt="Logo" style="width: 42px;">
      <span>Play & Fun</span>
    </a>
  </div>
</nav>

<!-- SIDENAV fijo y siempre visible -->
<ul id="slide-out" class="sidenav k-mini sidenav-fixed">
  <li><a href="eventoReg.jsp" class="waves-effect">
    <i class="material-icons">event</i><span class="menu-label">Registrar Evento</span></a></li>

  <li><a href="servicios.jsp" class="waves-effect">
    <i class="material-icons">room_service</i><span class="menu-label">Servicios</span></a></li>

  <li><a href="clientes.jsp" class="waves-effect">
    <i class="material-icons">group</i><span class="menu-label">Clientes</span></a></li>

  <li><a href="pagos.jsp" class="waves-effect">
    <i class="material-icons">payment</i><span class="menu-label">Pagos</span></a></li>
</ul>

<!-- Overlay que oscurece el contenido al expandir el menú -->
<div id="keroneScrim" class="kerone-scrim"></div>

<script>
  document.addEventListener('DOMContentLoaded', function(){
    // Mantén el espacio del mini-sidenav
    document.body.classList.add('kerone-layout');

    const side  = document.querySelector('.sidenav.k-mini.sidenav-fixed');
    const scrim = document.getElementById('keroneScrim');

    if (side && scrim){
      side.addEventListener('mouseenter', () => scrim.classList.add('show'));
      side.addEventListener('mouseleave', () => scrim.classList.remove('show'));
      scrim.addEventListener('click', () => scrim.classList.remove('show'));
      document.addEventListener('keydown', e => { if(e.key==='Escape') scrim.classList.remove('show'); });
    }

    // Inicializa Materialize si está cargado
    if (window.M && M.Sidenav){
      M.Sidenav.init(document.querySelectorAll('.sidenav'), {edge:'left', draggable:false});
    }
  });
</script>
