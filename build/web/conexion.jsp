<%@ page import="java.sql.Connection,java.sql.PreparedStatement,java.sql.ResultSet,java.sql.DriverManager" %>
<%-- conexion.jsp --%>
<%
  Connection conexion=null;
  PreparedStatement st=null;
  ResultSet rs=null;

  Class.forName("com.mysql.jdbc.Driver");
  conexion=DriverManager.getConnection("jdbc:mysql://localhost/salones-Kerone","root","");
%>
