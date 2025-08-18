<%@page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@include file="../conexion.jsp"%>

<%!
  /* ===== Utils ===== */
  private static String j(String s){
    return (s == null) ? "" : s.replace("\"","\\\"");
  }

  /* ===== ACTION: clients ===== */
  private static String listClients(java.sql.Connection conexion){
    java.sql.PreparedStatement ps = null;
    java.sql.ResultSet rs = null;
    StringBuilder sb = new StringBuilder();
    try{
      ps = conexion.prepareStatement(
        "SELECT id_cliente, COALESCE(name_user,'') AS n, COALESCE(pa_lastname_user,'') AS a " +
        "FROM cliente ORDER BY id_cliente DESC"
      );
      rs = ps.executeQuery();

      sb.append("{\"ok\":true,\"data\":[");
      boolean first = true;
      while(rs.next()){
        if(!first) sb.append(',');
        first=false;
        int id = rs.getInt("id_cliente");
        String full = (rs.getString("n")+" "+rs.getString("a")).trim();
        sb.append("{\"id\":").append(id)
          .append(",\"name\":\"").append(j(full)).append("\"}");
      }
      sb.append("]}");
    }catch(Exception e){
      sb = new StringBuilder("{\"ok\":false,\"data\":[],\"msg\":\"error clients\"}");
    }finally{
      try{ if(rs!=null) rs.close(); }catch(Exception ig){}
      try{ if(ps!=null) ps.close(); }catch(Exception ig){}
      try{ if(conexion!=null) conexion.close(); }catch(Exception ig){}
    }
    return sb.toString();
  }

  /* ===== ACTION: admins ===== */
  private static String listAdmins(java.sql.Connection conexion){
    java.sql.PreparedStatement ps = null;
    java.sql.ResultSet rs = null;
    StringBuilder sb = new StringBuilder();
    try{
      ps = conexion.prepareStatement(
        "SELECT id_user, COALESCE(user_user,'') AS username FROM `user` ORDER BY id_user DESC"
      );
      rs = ps.executeQuery();

      sb.append("{\"ok\":true,\"data\":[");
      boolean first = true;
      while(rs.next()){
        if(!first) sb.append(',');
        first=false;
        int id = rs.getInt("id_user");
        String name = rs.getString("username");
        sb.append("{\"id\":").append(id)
          .append(",\"name\":\"").append(j(name)).append("\"}");
      }
      sb.append("]}");
    }catch(Exception e){
      sb = new StringBuilder("{\"ok\":false,\"data\":[],\"msg\":\"error admins\"}");
    }finally{
      try{ if(rs!=null) rs.close(); }catch(Exception ig){}
      try{ if(ps!=null) ps.close(); }catch(Exception ig){}
      try{ if(conexion!=null) conexion.close(); }catch(Exception ig){}
    }
    return sb.toString();
  }

  /* ===== ACTION: services (solo activos) ===== */
  private static String listServices(java.sql.Connection conexion){
    java.sql.PreparedStatement ps = null;
    java.sql.ResultSet rs = null;
    StringBuilder sb = new StringBuilder();
    try{
      ps = conexion.prepareStatement(
        "SELECT id_service, COALESCE(name_service,'') AS n, price_service " +
        "FROM services WHERE status_service=1 ORDER BY n ASC"
      );
      rs = ps.executeQuery();

      sb.append("{\"ok\":true,\"data\":[");
      boolean first = true;
      while(rs.next()){
        if(!first) sb.append(',');
        first=false;
        int id = rs.getInt("id_service");
        String name = rs.getString("n");
        java.math.BigDecimal priceBD = rs.getBigDecimal("price_service");
        String price = (priceBD==null ? "0" : priceBD.toPlainString());
        sb.append("{\"id\":").append(id)
          .append(",\"name\":\"").append(j(name)).append("\"")
          .append(",\"price\":").append(price)
          .append("}");
      }
      sb.append("]}");
    }catch(Exception e){
      sb = new StringBuilder("{\"ok\":false,\"data\":[],\"msg\":\"error services\"}");
    }finally{
      try{ if(rs!=null) rs.close(); }catch(Exception ig){}
      try{ if(ps!=null) ps.close(); }catch(Exception ig){}
      try{ if(conexion!=null) conexion.close(); }catch(Exception ig){}
    }
    return sb.toString();
  }

  /* ===== ACTION: save (transacción completa) ===== */
  private static String saveReservation(java.sql.Connection conexion,
                                        javax.servlet.http.HttpServletRequest request){
    java.sql.PreparedStatement ps1 = null, ps2 = null, ps3 = null, ps4 = null;
    java.sql.ResultSet gk = null;
    try{
      conexion.setAutoCommit(false);

      // ---- datos del form ----
      String evento   = request.getParameter("evento");
      String color    = request.getParameter("color_evento");
      String start    = request.getParameter("date_reservation_start");
      String end      = request.getParameter("date_reservation_end");
      String status   = request.getParameter("status_reservation");
      int idCliente   = Integer.parseInt(request.getParameter("id_cliente"));
      int idUser      = Integer.parseInt(request.getParameter("id_user"));

      if (start != null) start = start.replace('T',' ');
      if (end   != null) end   = end.replace('T',' ');

      String idsCsv   = request.getParameter("services_id");   // ej: "1,3,6"
      String qtyCsv   = request.getParameter("services_qty");  // ej: "2,1,4"
      String unitCsv  = request.getParameter("services_unit"); // ej: "50,100,14"

      String[] ids  = (idsCsv  == null || idsCsv.isEmpty())  ? new String[0] : idsCsv.split(",");
      String[] qtys = (qtyCsv  == null || qtyCsv.isEmpty())  ? new String[0] : qtyCsv.split(",");
      String[] unis = (unitCsv == null || unitCsv.isEmpty()) ? new String[0] : unitCsv.split(",");

      // 1) eventoscalendar
      ps1 = conexion.prepareStatement(
        "INSERT INTO eventoscalendar (evento, color_evento, fecha_inicio, fecha_fin, id_cliente) " +
        "VALUES (?,?,?,?,?)",
        java.sql.Statement.RETURN_GENERATED_KEYS
      );
      ps1.setString(1, evento);
      ps1.setString(2, color);
      ps1.setString(3, start);
      ps1.setString(4, end);
      ps1.setInt   (5, idCliente);
      ps1.executeUpdate();
      gk = ps1.getGeneratedKeys();
      int idEvento = 0; if (gk.next()) idEvento = gk.getInt(1);
      try{ if(gk!=null) gk.close(); }catch(Exception ig){}

      // 2) folioservices (acumula total $)
      double totalServicios = 0.0;
      int N = Math.min(ids.length, Math.min(qtys.length, unis.length));
      for(int i=0;i<N;i++){
        int q=0; double u=0;
        try{ q = Integer.parseInt(qtys[i]); }catch(Exception e){}
        try{ u = Double.parseDouble(unis[i]); }catch(Exception e){}
        if(q<0) q=0;
        totalServicios += q*u;
      }
      ps2 = conexion.prepareStatement(
        "INSERT INTO folioservices (total_services) VALUES (?)",
        java.sql.Statement.RETURN_GENERATED_KEYS
      );
      ps2.setBigDecimal(1, new java.math.BigDecimal(totalServicios));
      ps2.executeUpdate();
      gk = ps2.getGeneratedKeys();
      int idFolio = 0; if (gk.next()) idFolio = gk.getInt(1);
      try{ if(gk!=null) gk.close(); }catch(Exception ig){}

      // 3) selectedservices (detalle)
      ps3 = conexion.prepareStatement(
        "INSERT INTO selectedservices (id_service, id_folio_services, amount_service, total_service) " +
        "VALUES (?,?,?,?)"
      );
      for(int i=0;i<N;i++){
        int idS=0,cant=0; double unit=0;
        try{ idS  = Integer.parseInt(ids[i]); }catch(Exception e){}
        try{ cant = Integer.parseInt(qtys[i]); }catch(Exception e){}
        try{ unit = Double.parseDouble(unis[i]); }catch(Exception e){}
        double tot = cant * unit;

        ps3.setInt(1, idS);
        ps3.setInt(2, idFolio);
        ps3.setInt(3, cant);
        ps3.setBigDecimal(4, new java.math.BigDecimal(tot));
        ps3.addBatch();
      }
      if (N>0) ps3.executeBatch();

      // 4) reservations
      ps4 = conexion.prepareStatement(
        "INSERT INTO reservations " +
        "(id_evento, status_reservation, price_total, date_reservation_start, date_reservation_end, " +
        " id_user, id_folio_services, id_room, id_cliente) " +
        "VALUES (?,?,?,?,?,?,?,?,?)"
      );
      ps4.setInt(1, idEvento);
      ps4.setString(2, status);
      ps4.setBigDecimal(3, new java.math.BigDecimal(totalServicios));
      ps4.setString(4, start);
      ps4.setString(5, end);
      ps4.setInt(6, idUser);
      ps4.setInt(7, idFolio);
      ps4.setInt(8, 1);         // id_room por defecto
      ps4.setInt(9, idCliente);
      ps4.executeUpdate();

      conexion.commit();
      return "{\"ok\":true,"+
             "\"id_evento\":"+idEvento+","+
             "\"id_folio\":"+idFolio+","+
             "\"price_total\":"+new java.math.BigDecimal(totalServicios).toPlainString()+
             "}";
    }catch(Exception e){
      try{ if(conexion!=null) conexion.rollback(); }catch(Exception ig){}
      return "{\"ok\":false}";
    }finally{
      try{ if(ps1!=null) ps1.close(); }catch(Exception ig){}
      try{ if(ps2!=null) ps2.close(); }catch(Exception ig){}
      try{ if(ps3!=null) ps3.close(); }catch(Exception ig){}
      try{ if(ps4!=null) ps4.close(); }catch(Exception ig){}
      try{ if(conexion!=null) conexion.close(); }catch(Exception ig){}
    }
  }
%>

<%
  request.setCharacterEncoding("UTF-8");
  String action = request.getParameter("action");
  if (action == null) action = "";

  String json;
  if ("clients".equalsIgnoreCase(action)) {
    json = listClients(conexion);
  } else if ("admins".equalsIgnoreCase(action)) {
    json = listAdmins(conexion);
  } else if ("services".equalsIgnoreCase(action)) {
    json = listServices(conexion);
  } else if ("save".equalsIgnoreCase(action)) {
    json = saveReservation(conexion, request);
  } else {
    json = "{\"ok\":false,\"msg\":\"action requerida\"}";
    try{ if(conexion!=null) conexion.close(); }catch(Exception ig){}
  }
  out.print(json);
  return;
%>
