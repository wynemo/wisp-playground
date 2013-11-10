(def http (require "http"))
(def client (.createClient (require "redis")))
(def cp (require "child_process"))
(def fs (require "fs"))
(def url (require "url"))

(def uds "/tmp/reddit_asianhotties.sock")

(defn endswith [str suffix] (if (== -1 (.indexOf str suffix (- (.-length str) (.-length suffix)))) false true))


(defn get_reddit [r context]
  (.get client "missingkey" (fn [err, reply]
                              (if (== err null)
                                (if (== reply null)
                                  (do
                                    (def crawl (.spawn cp "node" ["crawl_asianhotties.js"]))
                                    (.on crawl "close" (fn [code]
                                                         (.log console "code is " code)
                                                         (.get client "missingkey" (fn [err, reply](.end r reply)))))
                                    )
                                  (.end r reply)
                                  )
                                (.end r "error")))))
                                
(defn handle_crawl_image [r context] 
  (def url (aget (.-query context) "url"))
  (.log console "url is" url)
  (def crawl (.spawn cp "node" ["crawl_image.js" url]))
  (.on (.-stdout crawl) "data" (fn [data] (
                                 .write r data)))
  (.on (.-stderr crawl) "data" (fn [data] (
                                 .write r data)))
  (.on crawl "close" (fn [code]
                     (.log console "crawl_image code is " code)
                     (.end r (+ "crawl_image code is " code))
                     ))
  )
                                

(defn handle404 [r context]   
    (.writeHead r 404)
    (.end r "404"))
                                
(def routes {"/AsianHotties" (fn [r c] (get_reddit r  c)) "/crawlimage" (fn [r c] (handle_crawl_image r c))})


(def server 
  (.createServer http
                 (fn [request response]
                   (def parse_obj (.parse url (.-url request) true))
                   (def path (.-pathname parse_obj))
                   (if (endswith path "/") (set! path (.substr path 0 (- (.-length path) 1))) 0)
                   (.log console path)
                   (def handler (aget routes path))
                   (if handler (handler response parse_obj) (handle404 response 0))
                   )))

(.unlinkSync fs uds)                   
(.listen server uds
                (fn []
                  (.chmodSync fs uds 666)))
