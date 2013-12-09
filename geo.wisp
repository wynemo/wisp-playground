(def http (require "http"))
(def client (.createClient (require "redis")))

(defn get_country [ip cb]
  (def url "http://freegeoip.net/json/")
  (set! url (+ url ip))
  (.get client ip (fn [err, reply]
  (defn from_web []
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
                            (.set client ip (.-country_name data))
                            (.expire client ip (* 24 3600))
                            (cb (.-country_name data))
                            ))
                     )))
    (.on req
       "error"
       (fn [e]
         (.log console (.-message e))
         (cb "")
         ))
    (.end req))
  (if (== err null)
    (if (== reply null)
      (from_web)
      (cb reply)
      )
    (from_web))))
)