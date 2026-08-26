let progressInterval;
let timer;

window.addEventListener("message", (event) => {
    const bar = document.getElementById("progress-bar");
    const fill = document.getElementById("progress-fill");
    const text = document.getElementById("progress-text");

    if (event.data.action === "show") {
        clearInterval(progressInterval);

        let duration = event.data.duration || 3000;
        let time = 0;
        let step = 10;

        text.innerText = event.data.label || "Processing...";
        fill.style.width = "0%";

        bar.style.display = "block";
        requestAnimationFrame(() => (bar.style.opacity = "1"));

        progressInterval = setInterval(() => {
            time += step;
            let pct = Math.min((time / duration) * 100, 100);
            fill.style.width = pct + "%";
            if (pct >= 100) clearInterval(progressInterval);
        }, step);
    }

    if (event.data.action === "hide") {
        bar.style.opacity = "0";
        setTimeout(() => {
            clearInterval(progressInterval);
            fill.style.width = "0%";
            bar.style.display = "none";
        }, 250);
    }

    if (event.data.action === "captcha") {
        openCaptcha();
    }
});

const ICONS = [
    { key: "gun", char: "🔫", label: "gun" },
    { key: "fire", char: "🔥", label: "fire" },
    { key: "ninja", char: "🥷", label: "ninja" },
    { key: "goat", char: "🐐", label: "goat" },
    { key: "cigar", char: "🚬", label: "cigar" },
    { key: "money", char: "💸", label: "money" },
];

const container = document.getElementById("captcha-container");
const grid = document.getElementById("captcha-grid");
const promptEl = document.getElementById("captcha-prompt");

let target = null;

window.addEventListener("message", (event) => {
    if (event.data.action === "captcha") {
        openCaptcha();
    }
});

function openCaptcha() {
    buildRound();
    container.style.display = "flex";
}

function buildRound() {
    target = ICONS[Math.floor(Math.random() * ICONS.length)];

    const pool = ICONS.filter(i => i.key !== target.key);
    shuffle(pool);
    const options = [target, ...pool.slice(0, 5)];
    shuffle(options);

    promptEl.innerHTML = `Click the <b>${target.char} ${target.label}</b>`;

    grid.innerHTML = "";
    options.forEach(opt => {
        const btn = document.createElement("button");
        btn.className = "captcha-option";
        btn.textContent = opt.char;

        btn.addEventListener("click", () => {
            if (opt.key === target.key) {
                successCaptcha();
            } else {
                failCaptcha();
            }
        });

        grid.appendChild(btn);
    });
}

function successCaptcha() {
    container.style.display = "none";
    fetch(`https://${GetParentResourceName()}/captchaSuccess`, { method: "POST" });
}

function failCaptcha() {
    container.style.display = "none";
    fetch(`https://${GetParentResourceName()}/captchaFail`, { method: "POST" });
}

function shuffle(arr) {
    for (let i = arr.length - 1; i > 0; i--) {
        const j = ~~(Math.random() * (i + 1));
        [arr[i], arr[j]] = [arr[j], arr[i]];
    }
}