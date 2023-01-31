import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import Alpine from 'alpinejs'

export const initKantaUI = () => {
  window.Alpine = Alpine
  Alpine.start()
  
  let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
  let liveSocket = new LiveSocket("/live", Socket, {
      params: {_csrf_token: csrfToken},
      dom: {
        onBeforeElUpdated(from, to) {
          if (from._x_dataStack) {
            window.Alpine.clone(from, to)
          }
        }
      }
    })
  liveSocket.connect()
  
  window.liveSocket = liveSocket
}


