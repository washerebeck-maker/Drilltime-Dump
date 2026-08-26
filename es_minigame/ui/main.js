let MAX_SQUARES = 12;
let MIN_SQUARES = 4;
let MaxMissAmount = 2;
let Misses = 0;
let AmountOfSquares = 0;
let CorrectlySelectedSquares = 0;

let CONTAINER = document.querySelector(".memory-wrapper");
let Actives = [];
let CanClick = false;

window.addEventListener("message", function (event) {
    let data = event.data;

    if (data.action === "start") {
        if (data.fails) {
            MaxMissAmount = data.fails;
        }

        if (data.squares) {
            MAX_SQUARES = data.squares;
        }

        Misses = 0;
        SetupMemoryGame(data.rows);
    }
});

function SetupMemoryGame(rows) {
    CanClick = false;
    Actives = [];
    CorrectlySelectedSquares = 0;
    AmountOfSquares = 0;

    $(".memory-wrapper").html("");
    $(".memory-wrapper").css("display", "none");
    $(".memory-container").fadeIn(500);

    [].forEach.call(
        document.querySelectorAll(".box-active"),
        function (element) {
            element.classList.remove("box-active");
        }
    );

    $(".text").html("Preparing...");
    
    const Items = [];
    let SquaresActive = 1;
    for (i = 1; i < rows; i++) {
        for (k = 1; k < rows; k++) {
            if (SquaresActive < MAX_SQUARES) Actives[i] = true;
            let active = false;
            if (SquaresActive < MAX_SQUARES) {
                active = true;
            }
            SquaresActive++;
            Items.push({id: i, active: active});
            
        }
    }

    $(".help-text").fadeIn(100, () => {
        $(".memory-container").fadeIn(1000);
        setTimeout(() => {
            $(".text").html("Breaching...");
            setTimeout(() => {
                $(".help-text").fadeOut(0);
                $(".memory-wrapper").fadeIn(500);

                const ShuffledItems = ShuffleArray(Items);
                BuildWrapper(ShuffledItems, rows);

                setTimeout(() => {
                    CONTAINER.style.opacity = "0";

                    setTimeout(() => {
                        [].forEach.call(
                            document.querySelectorAll(".box-active"),
                            function (element) {
                                element.classList.remove("box-active");
                            }
                        );

                        setTimeout(() => {
                            CONTAINER.style.opacity = "100";
                            CanClick = true;
                        }, 500);
                    }, 500);
                }, 5000);

                $(".memory-wrapper").css("display", "block");
            }, 4500);
        }, 4000);
    });
}

// SetupMemoryGame(6);

function RandomNum(min, max) {
    return Math.floor(Math.random() * (max - min) + min);
}

function ClickSquare(e) {
    if (!CanClick) return;

    let ClickedId = e.target.id;

    let sound = new Audio("sounds/click.mp3");
    sound.volume = 0.8;
    sound.play();

    if (Actives[ClickedId]) {
        CanClick = false;
        CorrectlySelectedSquares++;

        Actives[ClickedId] = false;
        this.style.background = "white";

        if (CorrectlySelectedSquares >= AmountOfSquares) {
            CanClick = false;
            $(".text").html("Hack success");

            $(".memory-wrapper").fadeOut(250, () => {
                $(".help-text").fadeIn(250);
                setTimeout(() => {
                    $.post("http://es_minigame/success");
                    $(".memory-container").fadeOut(500);
                }, 2000);
            });
        } else {
            CanClick = true;
        }
    } else {
        Misses++;

        if (Misses > MaxMissAmount) {
            CanClick = false;
            $(".text").html("Hack failed");

            $(".memory-wrapper").fadeOut(250, () => {
                $(".help-text").fadeIn(250);
                setTimeout(() => {
                    $.post("http://es_minigame/fail");
                    $(".memory-container").fadeOut(500);
                }, 2000);
            });
        } else {
            this.style.background = "red";
        }
    }
}

const BuildWrapper = (array, rows) => {
    let CurrentID = 1;

    for (let i = 1; i < rows; i++) {
        let row = document.createElement("div");
        row.classList.add("row");

        for (let k = 1; k < rows; k++) {
            let square = document.createElement("div");
            square.classList.add("box");
            let id = `${i}-${k}`;
            square.setAttribute("id", id);
            square.classList.add('square-element');
            
            if (array[CurrentID] && array[CurrentID].active) {
                AmountOfSquares++;
                square.classList.add("box-active");
                Actives[id] = true;
            }

            CurrentID++;

            square.addEventListener("click", ClickSquare);

            row.appendChild(square);
        }

        CONTAINER.appendChild(row);
    }
}

const ShuffleArray = (array) => {
    for (var i = array.length - 1; i > 0; i--) {
        var j = Math.floor(Math.random() * (i + 1));
        var temp = array[i];
        array[i] = array[j];
        array[j] = temp;
    }
    return array;
}
