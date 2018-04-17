
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

function send(id) {
	sock.send(JSON.stringify({numid: Number($(id).data("id")), id: $(id).attr('id'), val: Number($(id).val()), chan: Number($(id).data("channel")), platform: 0}));
	console.log("<-- WebSocket TX - id: " + $(id).attr('id') + " | channel: " + $(id).data("channel") + " | value: " + $(id).val());
}

function updateSliderVal(id) {
	var value = $(id).val();
	var id = $(id).attr('id');
	$('#' + id + '-val').text(value);

	//console.log($(id).val());
}

$('.slider').on('input',function() {	
	updateSliderVal('#' + this.id);
});

sock.onopen = function(e) {
	send("#vol-1");
	send("#vol-2");
	send("#vol-3");

	$("#nav-sfx .slider").each(function() {
			$("<span id='"+ this.id + "-val' style='float:right; font-size:0.8em'>"+this.value+"</span>").insertBefore('#' + this.id);
		});
}


sock.onmessage = function(e) {

  msg = JSON.parse(e.data);


  console.log("--> WebSocket RX - id: " + msg.id + " | channel: " + msg.chan + " | value: " + msg.display);


  if (msg.chan > 0) {
    $('#' + msg.id).val(msg.display);
    updateSliderVal('#' + msg.id);
  }

  if (msg.id.indexOf("-check") >= 0) {
    if(msg.display == 1) {
      $("#" + msg.id).prop('checked', true);
    }
	else if(msg.display == 0) {
      $("#" + msg.id).prop('checked', false);

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
	console.log("<-- WebSocket TX - id: " + this.id + " | channel: " + 0 + " | value: " + $('#streamkey').val());
  }
  if ((this.id == "distortion-2-check") || (this.id == "distortion-1-check") || (this.id == "tremolo-1-check") || (this.id == "tremolo-2-check") || (this.id == "wawa-1-check") || (this.id == "wawa-2-check")) {
	sock.send(JSON.stringify({numid: Number(this.dataset.id), id: this.id, val: Number(checked), chan: Number(this.dataset.channel), platform: 0}));
	console.log("<-- WebSocket TX - id: " + this.id + " | channel: " + this.dataset.channel + " | value: " + checked);
  }
  //console.log(this.value);
});

$('input.slider').change(function() {
  sock.send(JSON.stringify({numid: Number(this.dataset.id), id: this.id, val: Number(this.value), chan: Number(this.dataset.channel), platform: 0}));
  console.log("<-- WebSocket TX - id: " + this.id + " | channel: " + this.dataset.channel + " | value: " + this.value);
  //console.log(this.value);
});



// FLANGER PRESETS
$('[id^=flangerpreset-ch]').change(function() {	  

	//NoNE
	if($(this).val() == "1") {

		$(".delay-ch" + this.dataset.channel + " .slider").each(function() {
			$('#' + this.id).val(this.dataset.default);
		});

		$(".trianglewave .slider").each(function() {
			$('#' + this.id).val(this.dataset.default);
		});

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
	
    $('#offset1-'+this.dataset.channel).val("50000");
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
	$('#tw-speed').val("5000");
	$('#tw-width').val("1000");
	$('#blgain-'+this.dataset.channel).val("0");
	
	$('#ffgain1-'+this.dataset.channel).val("255");
    $('#ffgain2-'+this.dataset.channel).val("255");
    $('#ffgain3-'+this.dataset.channel).val("255");
	
	$('#fbgain1-'+this.dataset.channel).val("0");
    $('#fbgain2-'+this.dataset.channel).val("0");
    $('#fbgain3-'+this.dataset.channel).val("0");
  }

	$(".delay-ch" + this.dataset.channel + " .slider").each(function() {
		send('#' + this.id);
		updateSliderVal('#' + this.id);
	});

	$(".trianglewave .slider").each(function() {
		send('#' + this.id);
		updateSliderVal('#' + this.id);
	});
});

$('#reset').click(function() {
	
	$("[id$='-check']").each(function() {
		$('#' + this.id).prop('checked', false);
		sock.send(JSON.stringify({numid: Number(this.dataset.id), id: this.id, val: Number(0), chan: Number(this.dataset.channel), platform: 0}));
	});
	
	$('.slider').each(function() {
		$('#' + this.id).val(this.dataset.default);
		sock.send(JSON.stringify({numid: Number(this.dataset.id), id: this.id, val: Number(this.value), chan: Number(this.dataset.channel), platform: 0}));
		updateSliderVal('#' + this.id);
	});
	
	$("[id^=flangerpreset-ch]").each(function() {
		$('#' + this.id).val("1");
	});
	

	
});
