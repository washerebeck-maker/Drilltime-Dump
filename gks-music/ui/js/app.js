import { fetchNui, isEnvBrowser, clamp, formatTime, prettyUrl, youtubeId } from './utils.js';
import { createMock } from './mock.js';

const $ = (id) => document.getElementById(id);

const app = document.querySelector('.app');
const el = {
    status: $('status'),
    statusLabel: $('statusLabel'),
    wordmark: $('wordmark'),
    deckArt: $('deckArt'),
    trackTitle: $('trackTitle'),
    trackSub: $('trackSub'),
    progress: $('progress'),
    progressFill: $('progressFill'),
    timeNow: $('timeNow'),
    timeTotal: $('timeTotal'),
    btnPlay: $('btnPlay'),
    btnStop: $('btnStop'),
    linkForm: $('linkForm'),
    linkInput: $('linkInput'),
    nearbyList: $('nearbyList'),
    nearbyEmpty: $('nearbyEmpty'),
    nearbyBadge: $('nearbyBadge'),
    master: $('master'),
    masterVal: $('masterVal'),
    muteAll: $('muteAll'),
    tabs: $('tabs'),
    toast: $('toast'),
};

const mock = isEnvBrowser() ? createMock() : null;

let state = null;
let artUrl = null;
let nearbyNodes = new Map();

// Elapsed is extrapolated between polls so the progress bar moves smoothly
// instead of stepping once a second.
let elapsedBase = 0;
let elapsedStamp = 0;

// A slider the player is actively dragging must not be yanked back by a poll
// that was already in flight.
const holds = new Map();
const holdFor = (id) => holds.set(id, Date.now());
const isHeld = (id) => Date.now() - (holds.get(id) || 0) < 1200;

/* ------------------------------------------------------------ plumbing -- */

const call = (event, data = {}) => {
    if (mock) return mock.call(event, data);
    return fetchNui(event, data);
};

const notify = (message) => {
    if (window.gksphone?.notify) {
        window.gksphone.notify(message, 2600);
        return;
    }

    el.toast.textContent = message;
    el.toast.classList.add('is-shown');
    clearTimeout(notify._timer);
    notify._timer = setTimeout(() => el.toast.classList.remove('is-shown'), 2600);
};

/* -------------------------------------------------------------- render -- */

function setSlider(input, label, value, text) {
    if (isHeld(input.id)) return;
    input.value = value;
    input.style.setProperty('--pct', `${((value - input.min) / (input.max - input.min)) * 100}%`);
    label.textContent = text;
}

function signalLevel(distance, range) {
    const strength = 1 - clamp(distance / Math.max(range, 1), 0, 1);
    if (strength > 0.72) return 4;
    if (strength > 0.46) return 3;
    if (strength > 0.2) return 2;
    return 1;
}

function buildNearRow(entry) {
    const li = document.createElement('li');
    li.className = 'near';

    li.innerHTML = `
        <div class="signal"><i></i><i></i><i></i><i></i></div>
        <div class="near-body">
            <p class="near-name"></p>
            <p class="near-track"></p>
        </div>
        <div class="near-meta">
            <span class="near-dist mono"></span>
            <button class="mute" type="button"></button>
        </div>`;

    li.querySelector('.mute').addEventListener('click', () => {
        const muted = li.dataset.muted !== 'true';
        li.dataset.muted = String(muted);
        li.querySelector('.mute').textContent = muted ? 'Muted' : 'Mute';
        call('setMuted', { owner: entry.owner, value: muted });
    });

    return li;
}

function renderNearby(list) {
    const seen = new Set();

    list.forEach((entry) => {
        const key = String(entry.owner);
        seen.add(key);

        let li = nearbyNodes.get(key);
        if (!li) {
            li = buildNearRow(entry);
            nearbyNodes.set(key, li);
            el.nearbyList.appendChild(li);
        }

        li.dataset.muted = String(entry.muted === true);
        li.querySelector('.signal').dataset.level = entry.muted
            ? '0'
            : String(signalLevel(entry.distance, entry.range));
        li.querySelector('.near-name').textContent = entry.name || 'Unknown';
        li.querySelector('.near-track').textContent = entry.paused
            ? 'Paused'
            : (entry.title || prettyUrl(entry.url));
        li.querySelector('.near-dist').textContent = `${entry.distance}m`;
        li.querySelector('.mute').textContent = entry.muted ? 'Muted' : 'Mute';
    });

    nearbyNodes.forEach((li, key) => {
        if (seen.has(key)) return;
        li.remove();
        nearbyNodes.delete(key);
    });

    el.nearbyEmpty.classList.toggle('is-shown', list.length === 0);
    el.nearbyBadge.hidden = list.length === 0;
    el.nearbyBadge.textContent = String(list.length);
}

function render(next) {
    state = next;
    const me = state.me || {};

    if (state.label) {
        const parts = String(state.label).trim().split(/\s+/);
        const tail = parts.length > 1 ? parts.pop() : '';
        el.wordmark.innerHTML = tail
            ? `${parts.join(' ')}<em>${tail}</em>`
            : `<em>${parts.join(' ')}</em>`;
    }

    const live = me.playing && !me.paused;
    app.dataset.state = !me.playing ? 'idle' : (me.paused ? 'paused' : 'playing');

    el.status.dataset.live = live ? 'true' : 'false';
    el.statusLabel.textContent = !me.playing ? 'Off air' : (me.paused ? 'Paused' : 'On air');

    // Only touch the background image when it actually changes, otherwise the
    // art flashes on every poll.
    const nextArt = me.playing ? (me.art || null) : null;
    if (nextArt !== artUrl) {
        artUrl = nextArt;
        el.deckArt.style.backgroundImage = artUrl ? `url("${artUrl}")` : '';
    }

    el.trackTitle.textContent = me.playing
        ? (me.title || prettyUrl(me.url))
        : 'Nothing playing';
    el.trackSub.textContent = me.playing
        ? (me.author || 'Playing from your phone')
        : 'Paste a link to start';

    el.btnPlay.disabled = !me.playing;
    el.btnStop.disabled = !me.playing;
    el.btnPlay.setAttribute('aria-label', live ? 'Pause' : 'Play');
    el.progress.classList.toggle('is-live', !!me.playing);

    elapsedBase = me.elapsed || 0;
    elapsedStamp = performance.now();
    tickProgress();

    renderNearby(state.nearby || []);

    const settings = state.settings || {};
    const master = Math.round((settings.master ?? 1) * 100);
    setSlider(el.master, el.masterVal, master, `${master}%`);
    el.muteAll.setAttribute('aria-checked', settings.muteAll ? 'true' : 'false');

    if (state.ready === false) {
        notify('Music is not available right now. Tell an admin xsound is not running.');
    }
}

function tickProgress() {
    const me = state?.me;
    if (!me?.playing) {
        el.progressFill.style.width = '0%';
        el.timeNow.textContent = '0:00';
        el.timeTotal.textContent = '--:--';
        return;
    }

    const drift = me.paused ? 0 : (performance.now() - elapsedStamp) / 1000;
    const elapsed = elapsedBase + drift;
    const duration = me.duration || 0;

    el.timeNow.textContent = formatTime(elapsed);
    el.timeTotal.textContent = duration > 0 ? formatTime(duration) : '--:--';
    el.progressFill.style.width = duration > 0
        ? `${clamp((elapsed / duration) * 100, 0, 100)}%`
        : '0%';
}

/* ------------------------------------------------------------- actions -- */

el.linkForm.addEventListener('submit', async (event) => {
    event.preventDefault();

    const url = el.linkInput.value.trim();
    if (!url) {
        notify('Paste a link first.');
        return;
    }

    el.linkInput.value = '';
    el.linkInput.blur();
    await call('play', { url });
    poll();
});

el.btnPlay.addEventListener('click', async () => {
    await call('togglePause');
    poll();
});

el.btnStop.addEventListener('click', async () => {
    await call('stop');
    poll();
});

el.muteAll.addEventListener('click', () => {
    const next = el.muteAll.getAttribute('aria-checked') !== 'true';
    el.muteAll.setAttribute('aria-checked', String(next));
    call('setMuteAll', { value: next });
});

const bindSlider = (input, label, format, event, transform) => {
    input.addEventListener('input', () => {
        holdFor(input.id);
        const value = Number(input.value);
        input.style.setProperty('--pct', `${((value - input.min) / (input.max - input.min)) * 100}%`);
        label.textContent = format(value);
        call(event, { value: transform(value) });
    });
};

bindSlider(el.master, el.masterVal, (v) => `${v}%`, 'setMaster', (v) => v / 100);

// Keep the player from walking off while they are typing.
//
// Handing input control to the text field and never handing it back locks the
// phone open, so this is tracked as explicit state rather than fire-and-forget
// events, and is actively reasserted below.
let typingState = false;

const setTyping = (typing) => {
    if (typing === typingState) return;
    typingState = typing;
    call('inputFocus', { focused: typing });
};

el.linkInput.addEventListener('focus', () => setTyping(true));
el.linkInput.addEventListener('blur', () => setTyping(false));

// Safety net. If the phone is closed while the field still has focus, blur
// never fires and the player would be stuck unable to close it. Anything that
// takes focus away from the input means typing is over, so give control back.
setInterval(() => {
    if (typingState && document.activeElement !== el.linkInput) setTyping(false);
}, 500);

window.addEventListener('pagehide', () => setTyping(false));
window.addEventListener('blur', () => setTyping(false));

el.tabs.addEventListener('click', (event) => {
    const button = event.target.closest('button[data-tab]');
    if (!button) return;

    el.tabs.querySelectorAll('button').forEach((b) => b.classList.toggle('is-active', b === button));
    document.querySelectorAll('.view').forEach((view) => {
        view.classList.toggle('is-active', view.dataset.view === button.dataset.tab);
    });
});

/* --------------------------------------------------------------- loop --- */

async function poll() {
    const next = await call('getState');
    if (next) render(next);
}

window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data) return;
    if (data.event === 'gksmusic:error') notify(data.message);
});

document.addEventListener('DOMContentLoaded', () => {
    setTimeout(() => {
        window.gksphone?.setStatusBarColor?.('#0C0616');
    }, 100);
});

// GKSPHONE calls getInfo on the Lua side every time the app is opened; calling
// it here gives us the first snapshot at the same moment.
call('getInfo').then((snapshot) => {
    if (snapshot) render(snapshot);
    else poll();
});

setInterval(poll, 1000);
setInterval(tickProgress, 250);
