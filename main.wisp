(def http (require "http"))
(def client (.createClient (require "redis")))
(def cp (require "child_process"))
(def fs (require "fs"))
(def url (require "url"))
(def geo (require "./geo"))
(def index (require "./index"))

(def uds "/tmp/reddit_asianhotties.sock")

(defn endswith [str suffix] (if (== -1 (.indexOf str suffix (- (.-length str) (.-length suffix)))) false true))

(def world_cdn "<script src=\"//ajax.aspnetcdn.com/ajax/jQuery/jquery-1.9.1.min.js\"></script>")
(def china_cdn "<script src=\"//dn-staticfile.qbox.me/jquery/1.9.1/jquery.min.js\"></script>")

(defn get_reddit [r context]
  (def x-real-ip (aget context "x-real-ip"))
  (.get_country geo x-real-ip (fn [country]
                                (.log console country)
                                (def cdn world_cdn)
                                (if (== country "China")
                                    (set! cdn china_cdn) 0)
                                (.get client "missingkey" (fn [err, reply]
                                  (if (== err null)
                                    (if (== reply null)
                                      (do
                                        (def crawl (.spawn cp "node" ["crawl_asianhotties.js"]))
                                        (.on crawl "close" (fn [code]
                                                             (.log console "code is " code)
                                                             (.get client "missingkey" (fn [err, reply](
                                                                .end r (.replace reply "%s" cdn))))))
                                        )
                                      (.end r (.replace reply "%s" cdn))
                                      )
                                    (.end r "error"))))
                                )))
                                
(defn handle_crawl_image [r context]
  (def parse_obj (aget context "parse_obj"))
  (def url (aget (.-query parse_obj) "url"))
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
    
(defn handle_index [r context]
  (.end r (.render_index index undefined)))
                                
(def routes
  {"/AsianHotties" (fn [r c] (get_reddit r  c))
   "/crawlimage" (fn [r c] (handle_crawl_image r c))
   "/" (fn [r c] (handle_index r c))
   })


(def server 
  (.createServer http
                 (fn [request response]
                   (def parse_obj (.parse url (.-url request) true))
                   (def x-real-ip (aget (.-headers request) "x-real-ip"))
                   (def path (.-pathname parse_obj))
                   (if (and (endswith path "/") (> (.-length path) 1))
                         (set! path (.substr path 0 (- (.-length path) 1)))
                         0)
                   (.log console path)
                   (def handler (aget routes path))
                   (def context {:parse_obj parse_obj :x-real-ip x-real-ip})
                   (if handler (handler response context) (handle404 response 0))
                   )))

(.unlinkSync fs uds)                   
(.listen server uds
                (fn []
                  (.chmodSync fs uds 666)))
