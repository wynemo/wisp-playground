(def static_folder "/home/zdb/dot/static/ppp/")

(def http (require "http"))
(def fs (require "fs"))
(def url "http://cdn.v2ex.com/avatar/9960/7461/5706_large.png")

(defn crawl_image [url]
  (def received 0)
  (def arr (.split url "/"))
  (def name (aget arr (- (.-length arr) 1)))
  (def dst (+ static_folder name))
  (def fd (.openSync fs dst "w"))
  (def req (.request http
                   url
                   (fn [response]
                     (.on response
                          "data"
                          (fn [chunk]
                            (.write fs fd chunk 0 (.-length chunk) received (fn [err, written, buffer]
                            ))
                            (set! received (+ received (.-length chunk)))
                            ))
                     (.on response
                          "end"
                          (fn []
                            (.closeSync fs fd)))
                     )))
  (.on req
       "error"
       (fn [e]
         (.log console (.-message e))
         ))
  (.end req)
)

(crawl_image url)