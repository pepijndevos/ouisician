
var sock = new WebSocket("ws://" + location.host + "/ws");

sock.onmessage = function(e) {

  msg = JSON.parse(e.data);


  console.log(msg.id);
  console.log(msg.display);

  if (msg.id == "recording") {
    $( "#record-info" ).append( "<p>", msg.display, "</p>" );
  }



  if (msg.id == "wav") {
    var audioplayer =
    '<div class="card-text row">' +
        '<div class="col-12">' +
          '<label for="vol">' + msg.display +'</label>' +

    '<p><audio controls="controls">' +
      '<source src="' + msg.display + '" type="audio/wav" /></p>' +
      '</div></div>';
    $( "#record-filelist" ).append( audioplayer );
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
