
var sock = new WebSocket("ws://" + location.host + "/ws");

function addAudioFile(file) {
    var audioplayer =
    '<div class="card-text row">' +
        '<div class="col-12">' +
          '<label><small>' + file +'</small></label>' +

    '<audio controls="controls" style="width:100%">' +
      '<source src="' + file + '" type="audio/wav" />' +
      '</div></div>';
    $( "#record-filelist" ).append( audioplayer );
}

sock.onmessage = function(e) {

  msg = JSON.parse(e.data);


  console.log(msg.id);
  console.log(msg.chan);
  console.log(msg.display);


  if (msg.chan > 0) {
    $('#' + msg.id).val(msg.display);
  }

  if (msg.id == "tremolo-2-check") {
    if(msg.display == 1) {
      $("#tremolo-2-check").prop('checked', true);
      ;$("#tremolo-2-slide").attr('disabled',false);
    }
	else if(msg.display == 0) {
      $("#tremolo-2-check").prop('checked', false);
      ;$("#tremolo-2-slide").attr('disabled', true);
    }
  }
   if (msg.id == "tremolo-1-check") {
    if(msg.display == 1) {
      $("#tremolo-1-check").prop('checked', true);
      ; $("#tremolo-1-slide").attr('disabled',false);
    }
	else if(msg.display == 0) {
      $("#tremolo-1-check").prop('checked', false);
      ;$("#tremolo-1-slide").attr('disabled', true);
    }
  }


  if (msg.id == "recording") {
    
    if(msg.numid == 1) { //starting recording
      $("#recording").prop('checked', true);
      $( "#record-log" ).append( '<div class="card-text row"><div class="col-12"><small>Recording to ' + msg.display + "</small></div></div>" );
    }
    else if(msg.numid == 0) { //done recording
      $("#recording").prop('checked', false);
      $( "#record-log" ).append( '<div class="card-text row"><div class="col-12"><small>Done recording to ' + msg.display + "</small></div></div>" );
      addAudioFile(msg.display);
    }
  }

  if (msg.id == "wav") {
    addAudioFile(msg.display);
  }

  if (msg.id == "streaming") {
    if(msg.numid == 1) {
      $("#streaming").prop('checked', true);
      $("#streamplatform").attr('disabled',true);
      $("#streamkey").attr('disabled',true);
    }
    else if(msg.numid == 0) {
      $("#streaming").prop('checked', false);
      $("#streamplatform").attr('disabled',false);
      $("#streamkey").attr('disabled',false);
    }
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
  if ((this.id == "streaming") || (this.id == "recording")) {
	sock.send(JSON.stringify({numid: Number(checked), id: this.id, val: $('#streamkey').val(), chan: Number(0), platform: Number($( "#streamplatform option:selected" ).val())}));
  }
  if ((this.id == "distortion-2-check") || (this.id == "distortion-1-check") || (this.id == "tremolo-1-check") || (this.id == "tremolo-2-check") || (this.id == "(wawa-1-check") || (this.id == "wawa-2-check")) {
	sock.send(JSON.stringify({numid: Number(this.dataset.id), id: this.id, val: Number(checked), chan: Number(this.dataset.channel), platform: 0}));
  }
  console.log(this.value);
});

$('input.slider').change(function() {
  sock.send(JSON.stringify({numid: Number(this.dataset.id), id: this.id, val: Number(this.value), chan: Number(this.dataset.channel), platform: 0}));
  console.log(this.value);
});

function send(id) {
	sock.send(JSON.stringify({numid: Number($(id).data("id")), id: $(id).attr('id'), val: Number($(id).val()), chan: Number($(id).data("channel")), platform: 0}));
	console.log($(id).val());
}

// FLANGER PRESETS
$('[id^=flangerpreset-ch]').change(function() {	  

	//NoNE
	if($(this).val() == "1") {
		$('#tw-speed').val("0");
		$('#tw-width').val("0");
		
		$('#offset1-'+this.dataset.channel).val("0");
		$('#offset2-'+this.dataset.channel).val("0");
		$('#offset3-'+this.dataset.channel).val("0");

		$('#blgain-'+this.dataset.channel).val("0");

		$('#ffgain1-'+this.dataset.channel).val("0");
		$('#ffgain2-'+this.dataset.channel).val("0");
		$('#ffgain3-'+this.dataset.channel).val("0");

		$('#fbgain1-'+this.dataset.channel).val("0");
		$('#fbgain2-'+this.dataset.channel).val("0");
		$('#fbgain3-'+this.dataset.channel).val("0");
	  }
//CHORUS
  else if($(this).val() == "2") {
	$('#tw-speed').val("0");
	$('#tw-width').val("0");
	
    $('#offset1-'+this.dataset.channel).val("1");
    $('#offset2-'+this.dataset.channel).val("100");
    $('#offset3-'+this.dataset.channel).val("1000");

    $('#blgain-'+this.dataset.channel).val("64");

    $('#ffgain1-'+this.dataset.channel).val("64");
    $('#ffgain2-'+this.dataset.channel).val("64");
    $('#ffgain3-'+this.dataset.channel).val("64");

    $('#fbgain1-'+this.dataset.channel).val("0");
    $('#fbgain2-'+this.dataset.channel).val("0");
    $('#fbgain3-'+this.dataset.channel).val("0");
  }
  //RESONATOR
  else if($(this).val() == "3") {
	$('#tw-speed').val("0");
	$('#tw-width').val("0");
	
    $('#offset1-'+this.dataset.channel).val("10");
    $('#offset2-'+this.dataset.channel).val("10");
    $('#offset3-'+this.dataset.channel).val("10");
    $('#blgain-'+this.dataset.channel).val("255");

    $('#ffgain1-'+this.dataset.channel).val("0");
    $('#ffgain2-'+this.dataset.channel).val("0");
    $('#ffgain3-'+this.dataset.channel).val("0");
    
    $('#fbgain1-'+this.dataset.channel).val("128");
    $('#fbgain2-'+this.dataset.channel).val("0");
    $('#fbgain3-'+this.dataset.channel).val("0");
  }
  //ECHO
  else if($(this).val() == "4") {
	$('#tw-speed').val("0");
	$('#tw-width').val("0");
	
    $('#offset1-'+this.dataset.channel).val("1000000");
    $('#offset2-'+this.dataset.channel).val("1000000");
    $('#offset3-'+this.dataset.channel).val("1000000");
    $('#blgain-'+this.dataset.channel).val("255");

    $('#ffgain1-'+this.dataset.channel).val("0");
    $('#ffgain2-'+this.dataset.channel).val("0");
    $('#ffgain3-'+this.dataset.channel).val("0");
    
    $('#fbgain1-'+this.dataset.channel).val("128");
    $('#fbgain2-'+this.dataset.channel).val("0");
    $('#fbgain3-'+this.dataset.channel).val("0");
  }
  //SLAPBACK
  else if($(this).val() == "5") {
	$('#tw-speed').val("0");
	$('#tw-width').val("0");
	
    $('#offset1-'+this.dataset.channel).val("0");
    $('#offset2-'+this.dataset.channel).val("0");
    $('#offset3-'+this.dataset.channel).val("0");
    $('#blgain-'+this.dataset.channel).val("255");

    $('#ffgain1-'+this.dataset.channel).val("0");
    $('#ffgain2-'+this.dataset.channel).val("0");
    $('#ffgain3-'+this.dataset.channel).val("0");
    
    $('#fbgain1-'+this.dataset.channel).val("255");
    $('#fbgain2-'+this.dataset.channel).val("0");
    $('#fbgain3-'+this.dataset.channel).val("0");
  }
  //VIBRATO
  else if($(this).val() == "6") {
	$('#tw-speed').val("1000");
	$('#tw-width').val("2000");
	$('#blgain-'+this.dataset.channel).val("0");
	
	$('#ffgain1-'+this.dataset.channel).val("255");
    $('#ffgain2-'+this.dataset.channel).val("255");
    $('#ffgain3-'+this.dataset.channel).val("255");
	
	$('#fbgain1-'+this.dataset.channel).val("0");
    $('#fbgain2-'+this.dataset.channel).val("0");
    $('#fbgain3-'+this.dataset.channel).val("0");
  }

  send("#tw-speed");
  send("#tw-width");
  send('#blgain-'+this.dataset.channel);
  send('#ffgain1-'+this.dataset.channel);
  send('#ffgain2-'+this.dataset.channel);
  send('#ffgain3-'+this.dataset.channel);
  send('#fbgain1-'+this.dataset.channel);
  send('#fbgain2-'+this.dataset.channel);
  send('#fbgain3-'+this.dataset.channel);

});

$('#reset').click(function() {
	
	$('.slider').each(function() {
		$('#' + this.id).val(this.dataset.default);
		sock.send(JSON.stringify({numid: Number(this.dataset.id), id: this.id, val: Number(this.value), chan: Number(this.dataset.channel), platform: 0}));
	});
	
	$("[id$='-check']").each(function() {
		$('#' + this.id).prop('checked', false);
		sock.send(JSON.stringify({numid: Number(this.dataset.id), id: this.id, val: Number(0), chan: Number(this.dataset.channel), platform: 0}));
	});
	
});
