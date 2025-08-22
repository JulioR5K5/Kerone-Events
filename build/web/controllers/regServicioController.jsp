<%@page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@include file="../conexion.jsp"%>

<%! // Helpers (deben ir en declaración JSP)
  String safePrice(String p){
    if (p == null) return "0";
    p = p.trim();
    if (p.isEmpty()) return "0";
    return p.replace(',', '.');
  }
  String esc(String s){
    if (s == null) return "";
    return s.replace("\"","\\\"");
  }
%>

<%
  // Cabeceras JSON (mantengo las tuyas)
  response.setContentType("application/json; charset=UTF-8");
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  response.setHeader("Pragma", "no-cache");
  response.setDateHeader("Expires", 0);
  response.setHeader("X-Content-Type-Options", "nosniff");

  request.setCharacterEncoding("UTF-8");
  String action = request.getParameter("action"); // null => INSERT por compatibilidad

  java.sql.Connection con = null;
  try {
    con = conexion;  // de conexion.jsp

    // ===== LIST =====
    if ("list".equalsIgnoreCase(action)) {
      java.sql.PreparedStatement ps = null;
      java.sql.ResultSet rs2 = null;
      try {
        ps = con.prepareStatement(
          "SELECT id_service, name_service, price_service, status_service FROM services ORDER BY id_service DESC"
        );
        rs2 = ps.executeQuery();

        StringBuilder json = new StringBuilder();
        json.append("{\"ok\":true,\"data\":[");
        boolean first = true;
        while (rs2.next()) {
          if (!first) json.append(',');
          first = false;

          String name  = esc(rs2.getString("name_service"));
          String price = rs2.getBigDecimal("price_service") != null
                           ? rs2.getBigDecimal("price_service").toPlainString()
                           : "0";

          json.append("{")
              .append("\"id\":").append(rs2.getInt("id_service")).append(",")
              .append("\"name\":\"").append(name).append("\",")
              .append("\"price\":").append(price).append(",")
              .append("\"status\":").append(rs2.getInt("status_service"))
              .append("}");
        }
        json.append("]}");
        out.print(json.toString());
      } catch (Exception e) {
        out.print("{\"ok\":false,\"data\":[],\"msg\":\"list failed\"}");
      } finally {
        try { if (rs2 != null) rs2.close(); } catch (Exception ig) {}
        try { if (ps  != null) ps.close();  } catch (Exception ig) {}
      }
      return;
    }

    // ===== UPDATE =====
    if ("update".equalsIgnoreCase(action)) {
      String idStr    = request.getParameter("id_service");
      String name     = request.getParameter("name_service");
      String priceStr = safePrice(request.getParameter("price_service"));
      String stStr    = request.getParameter("status_service");
      int status = (stStr != null && (stStr.equals("on") || "1".equals(stStr) || "true".equalsIgnoreCase(stStr))) ? 1 : 0;

      boolean ok = false;
      java.sql.PreparedStatement ps = null;
      try {
        int id = Integer.parseInt(idStr);
        ps = con.prepareStatement(
          "UPDATE services SET name_service=?, price_service=?, status_service=? WHERE id_service=?"
        );
        ps.setString(1, name);
        ps.setBigDecimal(2, new java.math.BigDecimal(priceStr));
        ps.setInt(3, status);
        ps.setInt(4, id);
        ok = ps.executeUpdate() > 0;
      } catch (Exception e) {
        ok = false;
      } finally {
        try { if (ps != null) ps.close(); } catch (Exception ig) {}
      }
      out.print("{\"ok\":" + (ok ? "true" : "false") + "}");
      return;
    }

    // ===== DELETE =====
    if ("delete".equalsIgnoreCase(action)) {
      String idStr = request.getParameter("id_service");
      boolean ok = false;
      java.sql.PreparedStatement ps = null;
      try {
        int id = Integer.parseInt(idStr);
        ps = con.prepareStatement("DELETE FROM services WHERE id_service=?");
        ps.setInt(1, id);
        ok = ps.executeUpdate() > 0;
      } catch (Exception e) {
        ok = false;
      } finally {
        try { if (ps != null) ps.close(); } catch (Exception ig) {}
      }
      out.print("{\"ok\":" + (ok ? "true" : "false") + "}");
      return;
    }

    // ===== INSERT (acción por defecto) =====
    String nameIns    = request.getParameter("name_service");
    String priceIns   = safePrice(request.getParameter("price_service"));
    String statusStr  = request.getParameter("status_service");
    int statusIns = (statusStr != null && (statusStr.equals("on") || "1".equals(statusStr) || "true".equalsIgnoreCase(statusStr))) ? 1 : 0;

    boolean ok = false;
    java.sql.PreparedStatement ps = null;
    try {
      ps = con.prepareStatement(
        "INSERT INTO services (name_service, price_service, status_service) VALUES (?, ?, ?)"
      );
      ps.setString(1, nameIns);
      ps.setBigDecimal(2, new java.math.BigDecimal(priceIns));
      ps.setInt(3, statusIns);
      ok = ps.executeUpdate() > 0;
    } catch (Exception e) {
      ok = false;
    } finally {
      try { if (ps != null) ps.close(); } catch (Exception ig) {}
    }
    out.print("{\"ok\":" + (ok ? "true" : "false") + "}");
    return;

  } finally {
    try { if (con != null) con.close(); } catch (Exception ig) {}
  }
%>
