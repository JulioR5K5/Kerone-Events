<%@page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@include file="../conexion.jsp"%>
<%
  request.setCharacterEncoding("UTF-8");
  String u = request.getParameter("admin");
  String p = request.getParameter("password");
  boolean ok = false;

  try{
    st = conexion.prepareStatement("SELECT 1 FROM `user` WHERE user_user=? AND pass_user=? LIMIT 1");
    st.setString(1, u);
    st.setString(2, p);
    rs = st.executeQuery();
    ok = rs.next();
  }catch(Exception e){
    ok = false;
  }finally{
    try{ if(rs!=null) rs.close(); }catch(Exception ig){}
    try{ if(st!=null) st.close(); }catch(Exception ig){}
    try{ if(conexion!=null) conexion.close(); }catch(Exception ig){}
  }
  out.print("{\"ok\":" + (ok ? "true" : "false") + "}");
%>
