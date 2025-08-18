<%@page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@include file="../conexion.jsp"%>
<%
  request.setCharacterEncoding("UTF-8");
  String action = request.getParameter("action"); // null => INSERT

  // ===== LIST =====
  if ("list".equalsIgnoreCase(action)) {
    java.sql.PreparedStatement psQ = null;
    java.sql.ResultSet rsQ = null;
    StringBuilder json = new StringBuilder();
    try{
      psQ = conexion.prepareStatement(
        "SELECT id_cliente, name_user, pa_lastname_user, email_user, phone_user, address, city, state, cp " +
        "FROM cliente ORDER BY id_cliente DESC");
      rsQ = psQ.executeQuery();

      json.append("{\"ok\":true,\"data\":[");
      boolean first=true;
      while(rsQ.next()){
        if(!first) json.append(','); first=false;

        String name     = rsQ.getString("name_user");        if(name==null) name="";
        String lastname = rsQ.getString("pa_lastname_user"); if(lastname==null) lastname="";
        String email    = rsQ.getString("email_user");       if(email==null) email="";
        String phone    = rsQ.getString("phone_user");       if(phone==null) phone="";
        String addr     = rsQ.getString("address");          ifaddr: { if(addr==null) addr=""; }
        String city     = rsQ.getString("city");             if(city==null) city="";
        String state    = rsQ.getString("state");            if(state==null) state="";
        String cp       = rsQ.getString("cp");               if(cp==null) cp="";

        name     = name.replace("\"","\\\"");
        lastname = lastname.replace("\"","\\\"");
        email    = email.replace("\"","\\\"");
        phone    = phone.replace("\"","\\\"");
        addr     = addr.replace("\"","\\\"");
        city     = city.replace("\"","\\\"");
        state    = state.replace("\"","\\\"");
        cp       = cp.replace("\"","\\\"");

        json.append("{")
            .append("\"id\":").append(rsQ.getInt("id_cliente")).append(",")
            .append("\"name\":\"").append(name).append("\",")
            .append("\"lastname\":\"").append(lastname).append("\",")
            .append("\"email\":\"").append(email).append("\",")
            .append("\"phone\":\"").append(phone).append("\",")
            .append("\"address\":\"").append(addr).append("\",")
            .append("\"city\":\"").append(city).append("\",")
            .append("\"state\":\"").append(state).append("\",")
            .append("\"cp\":\"").append(cp).append("\"")
            .append("}");
      }
      json.append("]}");
    }catch(Exception e){
      json = new StringBuilder("{\"ok\":false,\"data\":[]}");
    }finally{
      try{ if(rsQ!=null) rsQ.close(); }catch(Exception ig){}
      try{ if(psQ!=null) psQ.close(); }catch(Exception ig){}
      try{ if(conexion!=null) conexion.close(); }catch(Exception ig){}
    }
    out.print(json.toString());
    return;
  }

  // ===== UPDATE =====
  if ("update".equalsIgnoreCase(action)) {
    String idStr = request.getParameter("id_cliente");
    String name  = request.getParameter("name_user");
    String lastn = request.getParameter("pa_lastname_user");
    String email = request.getParameter("email_user");
    String phone = request.getParameter("phone_user");
    String addr  = request.getParameter("address");
    String city  = request.getParameter("city");
    String state = request.getParameter("state");
    String cpStr = request.getParameter("cp");

    boolean ok=false;
    java.sql.PreparedStatement psU=null;
    try{
      psU = conexion.prepareStatement(
        "UPDATE cliente SET name_user=?, pa_lastname_user=?, email_user=?, phone_user=?, address=?, city=?, state=?, cp=? WHERE id_cliente=?");
      psU.setString(1, name);
      psU.setString(2, lastn);
      psU.setString(3, email);
      psU.setString(4, phone);
      psU.setString(5, addr);
      psU.setString(6, city);
      psU.setString(7, state);
      psU.setString(8, (cpStr==null? "": cpStr.trim()));
      psU.setInt(9, Integer.parseInt(idStr));
      ok = psU.executeUpdate()>0;
    }catch(Exception e){ ok=false; }
    finally{
      try{ if(psU!=null) psU.close(); }catch(Exception ig){}
      try{ if(conexion!=null) conexion.close(); }catch(Exception ig){}
    }
    out.print("{\"ok\":"+(ok?"true":"false")+"}");
    return;
  }

  // ===== DELETE =====
  if ("delete".equalsIgnoreCase(action)) {
    String idStr = request.getParameter("id_cliente");
    boolean ok=false;
    java.sql.PreparedStatement psD=null;
    try{
      psD = conexion.prepareStatement("DELETE FROM cliente WHERE id_cliente=?");
      psD.setInt(1, Integer.parseInt(idStr));
      ok = psD.executeUpdate()>0;
    }catch(Exception e){ ok=false; }
    finally{
      try{ if(psD!=null) psD.close(); }catch(Exception ig){}
      try{ if(conexion!=null) conexion.close(); }catch(Exception ig){}
    }
    out.print("{\"ok\":"+(ok?"true":"false")+"}");
    return;
  }

  // ===== INSERT =====
  String name  = request.getParameter("name_user");
  String lastn = request.getParameter("pa_lastname_user");
  String email = request.getParameter("email_user");
  String phone = request.getParameter("phone_user");
  String addr  = request.getParameter("address");
  String city  = request.getParameter("city");
  String state = request.getParameter("state");
  String cpStr = request.getParameter("cp");

  boolean ok=false;
  java.sql.PreparedStatement psI=null;
  try{
    psI = conexion.prepareStatement(
      "INSERT INTO cliente (name_user, pa_lastname_user, email_user, phone_user, address, city, state, cp) " +
      "VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    psI.setString(1, name);
    psI.setString(2, lastn);
    psI.setString(3, email);
    psI.setString(4, phone);
    psI.setString(5, addr);
    psI.setString(6, city);
    psI.setString(7, state);
    psI.setString(8, (cpStr==null? "": cpStr.trim()));
    ok = psI.executeUpdate()>0;
  }catch(Exception e){ ok=false; }
  finally{
    try{ if(psI!=null) psI.close(); }catch(Exception ig){}
    try{ if(conexion!=null) conexion.close(); }catch(Exception ig){}
  }
  out.print("{\"ok\":"+(ok?"true":"false")+"}");
  return;
%>
