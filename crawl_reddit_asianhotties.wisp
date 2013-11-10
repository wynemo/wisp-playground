(def http (require "http"))
(def client (.createClient (require "redis")))
(def cp (require "child_process"))
(def fs (require "fs"))
(def url (require "url"))

(def uds "/tmp/reddit_asianhotties.sock")

(defn endswith [str suffix] (if (== -1 (.indexOf str suffix (- (.-length str) (.-length suffix)))) false true))


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

(defn handle404 [r]   
    (.writeHead r 404)
    (.end r "404"))
                                
(def routes {"/AsianHotties" (fn [r] (get_reddit r))})


(def server 
  (.createServer http
                 (fn [request response]
                   (def parse_obj (.parse url (.-url request)))
                   (def path (.-pathname parse_obj))
                   (if (endswith path "/") (set! path (.substr path 0 (- (.-length path) 1))) 0)
                   (.log console path)
                   (def handler (aget routes path))
                   (if handler (handler response) (handle404 response))
                   )))

(.listen server uds
                (fn []
                  (.chmodSync fs uds 666)))
