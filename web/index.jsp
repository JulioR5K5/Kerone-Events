<%-- 
    Document   : index
    Created on : 16/08/2025, 02:36:26 PM
    Author     : Students
--%>

<jsp:include page="includes/header.jsp"/>
<%@include file="conexion.jsp"%>

<div class="container">
  <div class="row">
    <div class="col s12 m6 l4 offset-m3 offset-l4 center-align">

      <img src="img/logPf.png" class="responsive-img" width="400" height="500">

      <div class="input-field">
        <input id="admin" type="text" placeholder="Usuario">
      </div>

      <div class="input-field">
        <input id="password" type="password" placeholder="Password">
      </div>

      <button class="btn waves-effect waves-light blue darken-4" style="border-radius:20px;" onclick="verificarLogin()">Entrar</button>

    </div>
  </div>
</div>

<script src="js/login.js"></script>
