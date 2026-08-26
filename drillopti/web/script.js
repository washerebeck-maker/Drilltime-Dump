$(document).ready(function() {
    $(".card").click(function() {
        const $this = $(this);
        const option = $this.data("option");
        
        $this.toggleClass("active");
        
        const isEnabled = $this.hasClass("active");

        $.post(`https://drillopti/changeOption`, JSON.stringify({ 
            option: option, 
            boolean: isEnabled
        }));
    });

    $("#closeMenu").click(function() {
        closeMenu();
    });

    window.addEventListener('message', function (event) {
        let action = event.data.action;
        if (action == "openMenu") {
            let currentSettings = event.data.settings;
            
            for (const [key, value] of Object.entries(currentSettings)) {
                const $card = $(`.card[data-option="${key}"]`);
                if (value === true) {
                    $card.addClass("active");
                } else {
                    $card.removeClass("active");
                }
            }
            
            $(".container").css("display", "flex").hide().fadeIn(250);
        }
    });

    $(document).keyup(function(e) {
        if (e.keyCode == 27) {
            closeMenu();
        }
    });

    function closeMenu() {
        $(".container").fadeOut(250, function() {
            $(this).css("display", "none");
        });
        $.post(`https://drillopti/exitMenu`);
    }
});