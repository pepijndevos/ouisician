
var sock = new WebSocket("ws://" + location.host + "/ws");

sock.onmessage = function(e) {

  msg = JSON.parse(e.data);


  console.log(msg.id);
  console.log(msg.display);

  if (msg.id == "recording") {
    $( "#record-content" ).append( "<p>", msg.display, "</p>" );
  }

}

$('input.form-check-input').change(function() {
  var checked;
  if (this.checked) {
	checked = 1; 
	}
	else {
	checked = 0; 
	}
  sock.send(JSON.stringify({numid: Number(checked), id: this.id, val: $('#streamkey').val(), chan: Number(0), platform: Number($( "#streamplatform option:selected" ).val())}));
  console.log(this.value);
});

$('input.slider').change(function() {
  sock.send(JSON.stringify({numid: Number(this.dataset.id), id: this.id, val: Number(this.value), chan: Number(this.dataset.channel), platform: 0}));
  console.log(this.value);
});
