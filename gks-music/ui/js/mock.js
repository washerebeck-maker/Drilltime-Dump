// Browser-only stand-in for the Lua side.
//
// This exists so the app can be demoed in a normal browser with no game
// running. It mirrors the real snapshot shape and the real validation rules, so
// what you see here is what the app does in game.

import { youtubeId, prettyUrl } from './utils.js';

const ALLOWED = /(^|\.)(youtube\.com|youtu\.be|soundcloud\.com)$/i;
const AUDIO_EXT = /\.(mp3|ogg|wav|m4a|aac|flac)$/i;

const raise = (message) => {
    window.postMessage({ event: 'gksmusic:error', message }, '*');
};

export function createMock() {
    const startedAt = performance.now();

    const state = {
        ready: true,
        label: 'DRILLTIME FM',
        me: {
            playing: true,
            paused: false,
            title: 'DRILLTIME RADIO',
            author: 'TRENCHES',
            art: 'img/demo-art.svg',
            url: 'https://youtu.be/demo',
            volume: 0.7,
            range: 30,
            elapsed: 41,
            duration: 214,
        },
        nearby: [
            { owner: 12, name: 'Marcus Webb',   title: 'Block Season',      distance: 9,  range: 30, muted: false, paused: false },
            { owner: 31, name: 'Dre Callahan',  title: 'Nightshift',        distance: 24, range: 30, muted: false, paused: false },
            { owner: 44, name: 'Simone Reyes',  title: 'Trap Radio 24/7',   distance: 41, range: 60, muted: true,  paused: false },
        ],
        settings: { master: 1, muteAll: false },
        limits: { minRange: 5, maxRange: 60 },
    };

    let playHead = state.me.elapsed;
    let lastTick = performance.now();

    const advance = () => {
        const now = performance.now();
        const delta = (now - lastTick) / 1000;
        lastTick = now;

        if (state.me.playing && !state.me.paused) {
            playHead += delta;
            if (state.me.duration > 0 && playHead >= state.me.duration) {
                state.me = { playing: false };
                playHead = 0;
            } else {
                state.me.elapsed = playHead;
            }
        }

        // Drift the neighbours around so the signal bars visibly react.
        const t = (now - startedAt) / 1000;
        state.nearby[0].distance = Math.round(9 + 6 * Math.sin(t / 7));
        state.nearby[1].distance = Math.round(24 + 5 * Math.sin(t / 11 + 1.4));
        state.nearby[2].distance = Math.round(41 + 8 * Math.sin(t / 9 + 2.7));
    };

    const validate = (raw) => {
        const url = String(raw || '').trim();
        if (!url) return { error: 'Paste a link first.' };

        let parsed;
        try {
            parsed = new URL(url.match(/^\w+:\/\//) ? url : `https://${url}`);
        } catch {
            return { error: 'That is not a link.' };
        }

        if (ALLOWED.test(parsed.hostname) || AUDIO_EXT.test(parsed.pathname)) {
            return { url: parsed.href };
        }

        return { error: 'Use a YouTube link, a SoundCloud link, or a direct .mp3.' };
    };

    const startTrack = async (url) => {
        const id = youtubeId(url);

        state.me = {
            playing: true,
            paused: false,
            title: null,
            author: null,
            art: id ? `https://i.ytimg.com/vi/${id}/hqdefault.jpg` : null,
            url,
            volume: state.me.volume ?? 0.7,
            range: state.me.range ?? 30,
            elapsed: 0,
            duration: 0,
        };

        playHead = 0;
        lastTick = performance.now();

        // Same trick the server uses: oEmbed needs no API key.
        try {
            const endpoint = /soundcloud/i.test(url)
                ? `https://soundcloud.com/oembed?format=json&url=${encodeURIComponent(url)}`
                : `https://www.youtube.com/oembed?format=json&url=${encodeURIComponent(url)}`;

            const response = await fetch(endpoint);
            if (response.ok) {
                const data = await response.json();
                if (state.me.url !== url) return;
                state.me.title = data.title || null;
                state.me.author = data.author_name || null;
                if (!state.me.art && data.thumbnail_url) state.me.art = data.thumbnail_url;
            }
        } catch {
            // Offline demo: the title falls back to the link, which is honest.
        }

        if (!state.me.duration) state.me.duration = 213;
    };

    const call = async (event, data = {}) => {
        advance();

        switch (event) {
            case 'getInfo':
            case 'getState':
                return JSON.parse(JSON.stringify(state));

            case 'play': {
                const result = validate(data.url);
                if (result.error) {
                    raise(result.error);
                    return 'ok';
                }
                await startTrack(result.url);
                return 'ok';
            }

            case 'stop':
                state.me = { playing: false };
                playHead = 0;
                return 'ok';

            case 'togglePause':
                if (state.me.playing) state.me.paused = !state.me.paused;
                return 'ok';

            case 'setBroadcastVolume':
                if (state.me.playing) state.me.volume = data.value;
                return 'ok';

            case 'setRange':
                if (state.me.playing) state.me.range = data.value;
                return 'ok';

            case 'setMaster':
                state.settings.master = data.value;
                return 'ok';

            case 'setMuteAll':
                state.settings.muteAll = data.value === true;
                return 'ok';

            case 'setMuted': {
                const entry = state.nearby.find((n) => String(n.owner) === String(data.owner));
                if (entry) entry.muted = data.value === true;
                return 'ok';
            }

            default:
                return 'ok';
        }
    };

    return { call };
}
