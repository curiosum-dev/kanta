import Alpine from "alpinejs";
import { Select } from "./components/shared/select";
import { Toggle } from "./components/shared/toggle";

let socketPath =
  document.querySelector("html").getAttribute("phx-socket") || "/live";
let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

window.Alpine = Alpine;
Alpine.start();

let Hooks = {};

Hooks.Select = Select;
Hooks.Toggle = Toggle;

let liveSocket = new LiveView.LiveSocket(socketPath, Phoenix.Socket, {
  hooks: Hooks,
  dom: {
    onBeforeElUpdated(from, to) {
      if (from._x_dataStack) {
        window.Alpine.clone(from, to);
      }
    },
  },
  params: () => {
    return {
      _csrf_token: csrfToken,
    };
  },
});

const socket = liveSocket.socket;
const originalOnConnError = socket.onConnError;
let fallbackToLongPoll = true;

socket.onOpen(() => {
  fallbackToLongPoll = false;
});

socket.onConnError = (...args) => {
  if (fallbackToLongPoll) {
    // No longer fallback to longpoll
    fallbackToLongPoll = false;
    // close the socket with an error code
    socket.disconnect(null, 3000);
    // fall back to long poll
    socket.transport = Phoenix.LongPoll;
    // reopen
    socket.connect();
  } else {
    originalOnConnError.apply(socket, args);
  }
};

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket;
