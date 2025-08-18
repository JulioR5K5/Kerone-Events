<%@page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@include file="../conexion.jsp"%>
<%
  request.setCharacterEncoding("UTF-8");
  String action = request.getParameter("action"); // null => INSERT por compatibilidad

  // ===== LIST =====
  if ("list".equalsIgnoreCase(action)) {
    java.sql.PreparedStatement ps = null;
    java.sql.ResultSet rs2 = null;
    StringBuilder json = new StringBuilder();
    try{
      ps = conexion.prepareStatement(
        "SELECT id_service, name_service, price_service, status_service FROM services ORDER BY id_service DESC");
      rs2 = ps.executeQuery();

      json.append("{\"ok\":true,\"data\":[");
      boolean first = true;
      while(rs2.next()){
        if(!first) json.append(',');
        first = false;
        String name = rs2.getString("name_service");
        if(name==null) name="";
        name = name.replace("\"","\\\"");
        String price = rs2.getBigDecimal("price_service").toPlainString();

        json.append("{")
            .append("\"id\":").append(rs2.getInt("id_service")).append(",")
            .append("\"name\":\"").append(name).append("\",")
            .append("\"price\":").append(price).append(",")
            .append("\"status\":").append(rs2.getInt("status_service"))
            .append("}");
      }
      json.append("]}");
    }catch(Exception e){
      json = new StringBuilder("{\"ok\":false,\"data\":[]}");
    }finally{
      try{ if(rs2!=null) rs2.close(); }catch(Exception ig){}
      try{ if(ps!=null) ps.close(); }catch(Exception ig){}
      try{ if(conexion!=null) conexion.close(); }catch(Exception ig){}
    }
    out.print(json.toString());
    return;
  }

  // ===== UPDATE =====
  if ("update".equalsIgnoreCase(action)) {
    String idStr   = request.getParameter("id_service");
    String name    = request.getParameter("name_service");
    String priceStr= request.getParameter("price_service");
    String stStr   = request.getParameter("status_service");
    int status = (stStr!=null && (stStr.equals("on") || "1".equals(stStr) || "true".equalsIgnoreCase(stStr)))?1:0;

    boolean ok=false;
    java.sql.PreparedStatement ps=null;
    try{
      if(priceStr!=null) priceStr = priceStr.replace(',', '.');
      ps = conexion.prepareStatement(
        "UPDATE services SET name_service=?, price_service=?, status_service=? WHERE id_service=?");
      ps.setString(1, name);
      ps.setBigDecimal(2, new java.math.BigDecimal(priceStr));
      ps.setInt(3, status);
      ps.setInt(4, Integer.parseInt(idStr));
      ok = ps.executeUpdate()>0;
    }catch(Exception e){ ok=false; }
    finally{
      try{ if(ps!=null) ps.close(); }catch(Exception ig){}
      try{ if(conexion!=null) conexion.close(); }catch(Exception ig){}
    }
    out.print("{\"ok\":"+(ok?"true":"false")+"}");
    return;
  }

  // ===== DELETE =====
  if ("delete".equalsIgnoreCase(action)) {
    String idStr = request.getParameter("id_service");
    boolean ok = false;
    java.sql.PreparedStatement ps = null;
    try{
      ps = conexion.prepareStatement("DELETE FROM services WHERE id_service=?");
      ps.setInt(1, Integer.parseInt(idStr));
      ok = ps.executeUpdate() > 0;
    }catch(Exception e){ ok = false; }
    finally{
      try{ if(ps!=null) ps.close(); }catch(Exception ig){}
      try{ if(conexion!=null) conexion.close(); }catch(Exception ig){}
    }
    out.print("{\"ok\":"+(ok?"true":"false")+"}");
    return;
  }

  // ===== INSERT (acción por defecto cuando action es null) =====
  String name = request.getParameter("name_service");
  String priceStr = request.getParameter("price_service");
  String statusStr = request.getParameter("status_service");
  int status = (statusStr!=null && (statusStr.equals("on") || "1".equals(statusStr) || "true".equalsIgnoreCase(statusStr)))?1:0;

  boolean ok=false;
  java.sql.PreparedStatement ps=null;
  try{
    if(priceStr!=null) priceStr = priceStr.replace(',', '.');
    ps = conexion.prepareStatement(
      "INSERT INTO services (name_service, price_service, status_service) VALUES (?, ?, ?)");
    ps.setString(1, name);
    ps.setBigDecimal(2, new java.math.BigDecimal(priceStr));
    ps.setInt(3, status);
    ok = ps.executeUpdate()>0;
  }catch(Exception e){ ok=false; }
  finally{
    try{ if(ps!=null) ps.close(); }catch(Exception ig){}
    try{ if(conexion!=null) conexion.close(); }catch(Exception ig){}
  }
  out.print("{\"ok\":"+(ok?"true":"false")+"}");
  return;
%>
