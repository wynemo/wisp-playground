(def http (require "http"))

(defn get_country [ip cb]
  (def url "http://freegeoip.net/json/")
  (set! url (+ url ip))
  (def s "")
  (def req (.request http
                   url
                   (fn [response]
                     (.on response
                          "data"
                          (fn [chunk] (set! s (+ s chunk))))
                     (.on response
                          "end"
                          (fn []
                            (def data (.parse JSON s))
                            (cb (.-country_name data))
                            ))
                     )))
  (.on req
       "error"
       (fn [e]
         (.log console (.-message e))
         (cb "")
         ))
  (.end req)
)