<%@page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@include file="../conexion.jsp"%>

<%!
  private static String esc(String s){ return (s==null) ? "" : s.replace("\"","\\\""); }

  /* ---------- LISTA ---------- */
  private static String listPagos(java.sql.Connection cx){
    java.sql.PreparedStatement ps=null; java.sql.ResultSet rs=null;
    StringBuilder sb = new StringBuilder();
    try{
      ps = cx.prepareStatement(
        "SELECT r.id_reservation, r.id_folio_services, " +
        "       r.price_total     AS adeudo_actual, " +
        "       fs.total_services AS total_original, " +
        "       r.date_reservation_start AS start_dt, " +
        "       r.date_reservation_end   AS end_dt, " +
        "       ec.evento, c.name_user, c.pa_lastname_user, " +
        "       COALESCE(SUM(p.monto_pago),0) AS pagado " +
        "FROM reservations r " +
        "JOIN eventoscalendar ec ON ec.id = r.id_evento " +
        "JOIN cliente c ON c.id_cliente = r.id_cliente " +
        "JOIN folioservices fs ON fs.id_folio_services = r.id_folio_services " +
        "LEFT JOIN pagos p ON p.id_folio_services = r.id_folio_services " +
        "GROUP BY r.id_reservation, r.id_folio_services, adeudo_actual, total_original, " +
        "         start_dt, end_dt, ec.evento, c.name_user, c.pa_lastname_user " +
        "ORDER BY r.id_reservation DESC"
      );
      rs = ps.executeQuery();

      sb.append("{\"ok\":true,\"data\":[");
      boolean first=true;
      while(rs.next()){
        if(!first) sb.append(','); first=false;

        String evento  = esc(rs.getString("evento"));
        String cliente = ((rs.getString("name_user")==null? "":rs.getString("name_user"))+" "+
                          (rs.getString("pa_lastname_user")==null? "":rs.getString("pa_lastname_user"))).trim();
        cliente = esc(cliente);

        java.math.BigDecimal totalOrig = rs.getBigDecimal("total_original");
        java.math.BigDecimal adeudoBD  = rs.getBigDecimal("adeudo_actual");
        java.math.BigDecimal pagadoBD  = rs.getBigDecimal("pagado");

        String start = rs.getString("start_dt"); if(start==null) start="";
        String end   = rs.getString("end_dt");   if(end==null)   end="";

        sb.append("{")
          .append("\"id_reservation\":").append(rs.getInt("id_reservation")).append(',')
          .append("\"id_folio\":").append(rs.getInt("id_folio_services")).append(',')
          .append("\"evento\":\"").append(evento).append("\",")
          .append("\"cliente\":\"").append(cliente).append("\",")
          .append("\"total\":").append(totalOrig==null? "0" : totalOrig.toPlainString()).append(',')
          .append("\"adeudo\":").append(adeudoBD==null ? "0" : adeudoBD.toPlainString()).append(',')
          .append("\"pagado\":").append(pagadoBD==null ? "0" : pagadoBD.toPlainString()).append(',')
          .append("\"start\":\"").append(esc(start)).append("\",")
          .append("\"end\":\"").append(esc(end)).append("\"")
          .append("}");
      }
      sb.append("]}");
    }catch(Exception e){
      sb = new StringBuilder("{\"ok\":false,\"data\":[],\"msg\":\"list error: "+esc(e.getMessage())+"\"}");
    }finally{
      try{ if(rs!=null) rs.close(); }catch(Exception ig){}
      try{ if(ps!=null) ps.close(); }catch(Exception ig){}
      try{ if(cx!=null) cx.close(); }catch(Exception ig){}
    }
    return sb.toString();
  }

  /* ---------- SAVE: inserta pago (sin id_metodo_pago) + descuenta adeudo ---------- */
  private static String savePago(java.sql.Connection cx,
                                 javax.servlet.http.HttpServletRequest req){
    java.sql.PreparedStatement ps1=null, ps2=null;
    try{
      cx.setAutoCommit(false);

      String fecha    = req.getParameter("fecha_pago");      // YYYY-MM-DD
      String montoS   = req.getParameter("monto_pago");      // "123.45"
      String tipo     = req.getParameter("tipo_pago");       // texto
      String idFolioS = req.getParameter("id_folio_services");
      String idResS   = req.getParameter("id_reservation");

      if (fecha==null || montoS==null || tipo==null || idFolioS==null || idResS==null){
        return "{\"ok\":false,\"msg\":\"missing params\"}";
      }

      int idFolio = Integer.parseInt(idFolioS);
      int idRes   = Integer.parseInt(idResS);

      // normaliza monto
      montoS = montoS.replace(',', '.');
      java.math.BigDecimal monto = new java.math.BigDecimal(montoS);

      // 1) insert en pagos (ya SIN id_metodo_pago)
      ps1 = cx.prepareStatement(
        "INSERT INTO pagos (fecha_pago, monto_pago, tipo_pago, id_folio_services) " +
        "VALUES (?,?,?,?)"
      );
      try { ps1.setDate(1, java.sql.Date.valueOf(fecha)); }
      catch(Exception _){ ps1.setString(1, fecha); }
      ps1.setBigDecimal(2, monto);
      ps1.setString(3, tipo);
      ps1.setInt(4, idFolio);
      ps1.executeUpdate();

      // 2) actualizar adeudo y status
      ps2 = cx.prepareStatement(
        "UPDATE reservations " +
        "SET price_total = GREATEST(price_total - ?, 0), " +
        "    status_reservation = CASE WHEN (price_total - ?) <= 0 THEN 'pagada' ELSE 'adeudo' END " +
        "WHERE id_reservation = ?"
      );
      ps2.setBigDecimal(1, monto);
      ps2.setBigDecimal(2, monto);
      ps2.setInt(3, idRes);
      ps2.executeUpdate();

      cx.commit();
      return "{\"ok\":true}";
    }catch(Exception e){
      try{ if(cx!=null) cx.rollback(); }catch(Exception ig){}
      return "{\"ok\":false,\"msg\":\"exception: "+esc(e.getMessage())+"\"}";
    }finally{
      try{ if(ps1!=null) ps1.close(); }catch(Exception ig){}
      try{ if(ps2!=null) ps2.close(); }catch(Exception ig){}
      try{ if(cx!=null) cx.close(); }catch(Exception ig){}
    }
  }
%>

<%
  request.setCharacterEncoding("UTF-8");
  String action = request.getParameter("action");
  if (action == null) action = "";

  String json;
  if ("list".equalsIgnoreCase(action)) {
    json = listPagos(conexion);
  } else if ("save".equalsIgnoreCase(action)) {
    json = savePago(conexion, request);
  } else {
    json = "{\"ok\":false,\"msg\":\"action requerida\"}";
    try{ if(conexion!=null) conexion.close(); }catch(Exception ig){}
  }
  out.print(json);
  return;
%>
