function verificarLogin(){
  var a = document.getElementById('admin').value.trim();
  var p = document.getElementById('password').value;

  const LOGIN_URL = 'http://localhost:8080/Kerone-Events/controllers/loginController.jsp';
  const NEXT_URL  = 'http://localhost:8080/Kerone-Events/eventoReg.jsp';

  fetch(LOGIN_URL, {
    method: 'POST',
    headers: {'Content-Type':'application/x-www-form-urlencoded'},
    body: 'admin=' + encodeURIComponent(a) + '&password=' + encodeURIComponent(p)
  })
  .then(function(r){
    if(!r.ok) throw new Error('HTTP '+r.status);
    return r.json();
  })
  .then(function(d){
    if(d && d.ok){
      M.toast({html:'Bienvenido ' + a, classes:'green'});
      setTimeout(function(){ window.location.href = NEXT_URL; }, 600);
    }else{
      M.toast({html:'Credenciales incorrectas', classes:'red'});
    }
  })
  .catch(function(){
    M.toast({html:'Error de conexion', classes:'red'});
  });
}
