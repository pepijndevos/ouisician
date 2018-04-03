
var sock = new WebSocket("ws://" + location.host + "/ws");

$('input.slider').change(function() {
  sock.send(JSON.stringify({numid: Number(this.dataset.id), id: this.id, val: Number(this.value), chan: Number(this.dataset.channel)}));
  console.log(this.value);
});
