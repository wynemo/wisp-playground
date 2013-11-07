(def http (require "http"))
(def client (.createClient (require "redis")))
(def cp (require "child_process"))
(def fs (require "fs"))

(def uds "/tmp/reddit_asianhotties.sock")


(defn get_reddit [r]
  (.get client "missingkey" (fn [err, reply]
                              (if (== err null)
                                (if (== reply null)
                                  (do
                                    (def crawl (.spawn cp "wisp" ["crawl.wisp"]))
                                    (.on crawl "close" (fn [code]
                                                         (.log console "code is " code)
                                                         (.get client "missingkey" (fn [err, reply](.end r reply)))))
                                    )
                                  (.end r reply)
                                  )
                                (.end r "error")))))



(def server 
  (.createServer http
                 (fn [request response]
                   (get_reddit response))))

(.listen server uds)
(.chmodSync fs uds 666)
