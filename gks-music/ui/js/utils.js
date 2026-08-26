// Derive the resource name from the URL GKSPHONE loaded us from
// (https://cfx-nui-<resource>/ui/index.html) so renaming the folder does not
// silently break every callback.
export const RESOURCE = (() => {
    const host = window.location.hostname || '';
    if (host.startsWith('cfx-nui-')) return host.slice('cfx-nui-'.length);
    if (typeof window.GetParentResourceName === 'function') return window.GetParentResourceName();
    return 'gks-music';
})();

// We run inside an iframe in the phone, and injected globals are not guaranteed
// to reach child frames, so the origin is the reliable tell.
export const isEnvBrowser = () =>
    !(window.location.hostname.startsWith('cfx-nui-') || window.invokeNative);

export const fetchNui = async (event, data = {}, mock = null) => {
    if (isEnvBrowser()) return mock;

    try {
        const response = await fetch(`https://${RESOURCE}/${event}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify(data),
        });
        return await response.json();
    } catch (err) {
        console.error(`[gks-music] ${event} failed`, err);
        return mock;
    }
};

export const clamp = (n, min, max) => Math.min(max, Math.max(min, n));

export const formatTime = (seconds) => {
    if (!Number.isFinite(seconds) || seconds < 0) return '--:--';

    const total = Math.floor(seconds);
    const mins = Math.floor(total / 60);
    const secs = total % 60;

    if (mins >= 60) {
        const hrs = Math.floor(mins / 60);
        return `${hrs}:${String(mins % 60).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
    }

    return `${mins}:${String(secs).padStart(2, '0')}`;
};

// Fallback label when a track has no resolved title yet.
export const prettyUrl = (url) => {
    if (!url) return 'Unknown track';
    try {
        const parsed = new URL(url);
        return parsed.hostname.replace(/^www\./, '') + parsed.pathname;
    } catch {
        return url;
    }
};

export const youtubeId = (url) => {
    if (!url) return null;
    const match =
        url.match(/[?&]v=([\w-]{6,})/) ||
        url.match(/youtu\.be\/([\w-]{6,})/) ||
        url.match(/\/shorts\/([\w-]{6,})/) ||
        url.match(/\/embed\/([\w-]{6,})/) ||
        url.match(/\/live\/([\w-]{6,})/);
    return match ? match[1] : null;
};
