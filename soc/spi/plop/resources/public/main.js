
var sock = new WebSocket("ws://" + location.host + "/ws");

$('input.slider').change(function() {
  sock.send(JSON.stringify({id: Number(this.dataset.id), val: Number(this.value), chan: Number(this.dataset.channel)}));
  console.log(this.value);
});
