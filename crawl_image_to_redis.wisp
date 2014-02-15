(defn startswith [str prefix] (if (== 0 (.indexOf str prefix 0)) true false))
(defn endswith [str suffix] (if (== -1 (.indexOf str suffix (- (.-length str) (.-length suffix)))) false true))

(def http (require "http"))
(def https (require "https"))
(def client (.createClient (require "redis")))
(def url (aget (.-argv process) 2))
(def citr "/citr/")

(defn crawl_image [url]
  (def received 0)
  (if (and (endswith url "/") (> (.-length url) 1))
    (set! url (.substr url 0 (- (.-length url) 1)))
    0)
  (def arr (.split url "/"))
  (def name (aget arr (- (.-length arr) 1)))
  (def fucking_http (if (startswith url "https") https http))
  (def key (+ citr name))
  (def current 0)
  (def req (.request fucking_http
                   url
                   (fn [response]
                     (def bufarr [])
                     (.on response
                          "data"
                          (fn [chunk]
                            (.push bufarr chunk)
                            ))
                     (.on response
                          "end"
                          (fn []
                            (.set client key (.toString (.concat Buffer bufarr) "binary"))
                            (.expire client key 3600)
                            (.log console "url is" (+ "https://ssl.dabin.info" key))
                            ))
                     )))
  (.on req
       "error"
       (fn [e]
         (.log console (.-message e))
         ))
  (.end req))

(crawl_image url)
