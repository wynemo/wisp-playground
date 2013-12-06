(defn startswith [str prefix] (if (== 0 (.indexOf str prefix 0)) true false))

(def static_folder "/home/zdb/dot/static/ppp/")

(def http (require "http"))
(def https (require "https"))
(def fs (require "fs"))
(def events (require "events"))
(def url (aget (.-argv process) 2))
(def emitter (new (.-EventEmitter events)))

(defn crawl_image [url]
  (def received 0)
  (def arr (.split url "/"))
  (def name (aget arr (- (.-length arr) 1)))
  (def dst (+ static_folder name))
  (def fd (.openSync fs dst "w"))
  (def net_count 0)
  (def fs_count 0)
  (def finished 0)
  (.on emitter "clean"
       (fn []
         (if (and (== 1 finished) (== net_count fs_count)) 
             (do
               (.closeSync fs fd)
               (.log console "url is" (+ "http://dabin.info/static/ppp/" name)))
             0)))
  (def fucking_http (if (startswith url "https") https http))
  (def req (.request fucking_http
                   url
                   (fn [response]
                     (.on response
                          "data"
                          (fn [chunk]
                            (set! net_count (+ net_count 1))
                            (.write fs fd chunk 0 (.-length chunk) received (fn [err, written, buffer]
                                                                              (set! fs_count (+ fs_count 1))
                                                                              (.emit emitter "clean")
                                                                               
                            ))
                            (set! received (+ received (.-length chunk)))
                            ))
                     (.on response
                          "end"
                          (fn [] 
                            (set! finished 1)
                            (.emit emitter "clean")) )
                     )))
  (.on req
       "error"
       (fn [e]
         (.log console (.-message e))
         ))
  (.end req))

(crawl_image url)
