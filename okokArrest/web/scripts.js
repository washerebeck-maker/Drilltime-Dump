var selectedWindow = "none"
var sourceID = 0
var targetID = 0
var sourceName = ""
var targetName = ""
var date = ""
var reason = ""
var search = ""
var search_type = ""

window.addEventListener('message', function(event) {
	switch (event.data.action) {
		case 'openContractSeller':
			var popup = new Audio('popup.mp3');
			popup.volume = 0.4;
			popup.play();

			$("#source_name").html(event.data.source_playername);
			$("#target_name").html(event.data.target_playername);
			$("#date").html(event.data.date);
			$("#reason").html(event.data.reason);
			$("#search").html(event.data.search);

			sourceID = event.data.sourceID;
			targetID = event.data.targetID;
			sourceName = event.data.source_playername;
			targetName = event.data.target_playername;
			date = event.data.date;
			reason = event.data.reason;
			search = event.data.search;

			$("#signtest").html("");
			$("#signtest2").html("");
			$("#signContract1").attr("disabled", false);

			$("#signContract1").removeClass('d-none');
			$("#signContract2").addClass('d-none');

			$(".contract1").fadeIn();

			selectedWindow = "openContractSeller"
			break
		case 'openContractInfo':
			var popup = new Audio('popup.mp3');
			popup.volume = 0.4;
			popup.play();

			$(".civInformation").fadeIn();

			selectedWindow = "openContractInfo"
			break
		case 'openContractOnBuyer':
			var popup = new Audio('popup.mp3');
			popup.volume = 0.4;
			popup.play();

			$("#source_name").html(event.data.source_playername);
			$("#target_name").html(event.data.target_playername);
			$("#date").html(event.data.date);
			$("#reason").html(event.data.reason);
			$("#search").html(event.data.search);

			sourceNameSeller = event.data.source_playername;
			targetNameSeller = event.data.target_playername;
			targetIDSeller = event.data.targetID;
			sourceIDSeller = event.data.sourceID;
			search = event.data.search;
			reason = event.data.reason;

			$("#signtest").html("");
			$("#signtest2").html("");
			$("#signContract2").attr("disabled", false);

			var sellerSignatureP = new Vara("#signtest","SatisfySL.json", [{
				text: event.data.source_playername,
				fontSize: 18, 
				strokeWidth: 2,
				color: "#000",
				id: "",
				duration: 0,
				textAlign: "center",
				x: 0,
				y: 0, 
				fromCurrentPosition:{ 
					x: true,
					y: true,
				},
				autoAnimation: true,
				queued: true,
				delay: 0,
				letterSpacing: 0
			}]);

			$("#signContract1").addClass('d-none');
			$("#signContract2").removeClass('d-none');

			$(".contract1").fadeIn();

			selectedWindow = "openContractOnBuyer"
			break
	}
});

// Button Actions
$(document).on('click', '#submitContractInfo', function() {
	var pd_reason = $("#pd_reason").val();
	var search_type = $("#search_type").val();

	if(!pd_reason || !search_type) {
		$.post('http://okokArrest/action', JSON.stringify({
			action: "missingInfo",
		}));
	} else {
		$(".civInformation").fadeOut();

		$.post('http://okokArrest/action', JSON.stringify({
			action: "submitContractInfo",
			pd_reason: pd_reason,
			search_type: search_type,
		}));

		setTimeout(function() {
			$("#pd_reason").val("");
			$("#search_type").val("");
		}, 400);
	}
})

$(document).on('click', "#signContract1", function() {
	var accept = new Audio('accept.mp3');
	accept.volume = 0.5;
	accept.play();

	var sellerSignature = new Vara("#signtest","SatisfySL.json", [{
		text: sourceName,
		fontSize: 18, 
		strokeWidth: 2,
		color: "#000",
		id: "",
		duration: 3000,
		textAlign: "center",
		x: 0,
		y: 0, 
		fromCurrentPosition:{ 
			x: true,
			y: true,
		},
		autoAnimation: true,
		queued: true,
		delay: 0,
		letterSpacing: 0
	}]);

	$("#signContract1").attr("disabled", true);

	setTimeout(function(){
		$.post('https://okokArrest/action', JSON.stringify({
			action: "signContract1",
			sourceID: sourceID,
			targetID: targetID,
			sourceName: sourceName,
			targetName: targetName,
			date: date,
			reason: reason,
			search: search,
		}));

		$(".contract1").fadeOut();
	}, 6000);
});

$(document).on('click', "#signContract2", function() {
	var accept = new Audio('accept.mp3');
	accept.volume = 0.5;
	accept.play();

	//$(".mainmenu").fadeOut();

	var buyerSignature = new Vara("#signtest2","SatisfySL.json", [{
		text: targetNameSeller,
		fontSize: 18, 
		strokeWidth: 2,
		color: "#000",
		id: "",
		duration: 3000,
		textAlign: "center",
		x: 0,
		y: 0, 
		fromCurrentPosition:{ 
			x: true,
			y: true,
		},
		autoAnimation: true,
		queued: true,
		delay: 0,
		letterSpacing: 0
	}]);

	$("#signContract2").attr("disabled", true);

	setTimeout(function(){
		$.post('https://okokArrest/action', JSON.stringify({
			action: "signContract2",
			targetIDSeller: targetIDSeller,
			sourceIDSeller: sourceIDSeller,
			sourceNameSeller: sourceNameSeller,
			targetNameSeller: targetNameSeller,
			search: search,
			reason: reason,
		}));
		
		$(".contract1").fadeOut();
	}, 6000);
});

$(document).on('click', "#closeCivInformation", function() {
	var popuprev = new Audio('popupreverse.mp3');
	popuprev.volume = 0.4;
	popuprev.play();

	$(".civInformation").fadeOut();

	setTimeout(function() {
		$("#pd_reason").val("");
		$("#search_type").val("");

		$.post('https://okokArrest/action', JSON.stringify({
			action: "close",
		}));
	}, 400);
});

// Close ESC Key
$(document).ready(function() {
	document.onkeyup = function(data) {
		if (data.which == 27) {
			var popuprev = new Audio('popupreverse.mp3');
			popuprev.volume = 0.4;
			popuprev.play();
			switch (selectedWindow) {
				case 'openContractSeller':
					$(".contract1").fadeOut();

					$.post('https://okokArrest/action', JSON.stringify({
						action: "close",
					}));
					break
				case 'openContractInfo':
					$(".civInformation").fadeOut();

					setTimeout(function() {
						$("#pd_reason").val("");
						$("#search_type").val("");
					}, 400);

					$.post('https://okokArrest/action', JSON.stringify({
						action: "close",
					}));
					break
				case 'openContractOnBuyer':
					$(".contract1").fadeOut();

				    $.post('https://okokArrest/action', JSON.stringify({
				        action: "close1",sourceIDSeller : sourceID, targetIDSeller : targetID, search : search, reason : reason
				    }));
					break
			}
		}
	};
});