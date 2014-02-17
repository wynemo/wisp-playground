(defn startswith [str prefix] (if (== 0 (.indexOf str prefix 0)) true false))
(defn endswith [str suffix] (if (== -1 (.indexOf str suffix (- (.-length str) (.-length suffix)))) false true))

(def http (require "http"))
(def https (require "https"))
(def crypto (require "crypto"))

(def client (.createClient (require "redis")))
(def url (aget (.-argv process) 2))
(def citr "/citr/")

(defn crawl_image [url]
  (def received 0)
  (if (and (endswith url "/") (> (.-length url) 1))
    (set! url (.substr url 0 (- (.-length url) 1)))
    0)
  (def name (.digest (.update (.createHash crypto "md5") url) "hex"))
  (def fucking_http (if (startswith url "https") https http))
  (def current 0)
  (def req (.request fucking_http
                   url
                   (fn [response]
                     (.log console "status code is" (.-statusCode response))
                     (if (== 200 (.-statusCode response)) 0 (.exit process -1))
                     (def ct (aget (.-headers response) "content-type"))
                     (if (endswith ct "jpeg") (set! name (+ name ".jpg")) 0)
                     (if (endswith ct "png") (set! name (+ name ".png")) 0)
                     (if (endswith ct "gif") (set! name (+ name ".gif")) 0)
                     (def key (+ citr name))
                     (def bufarr [])
                     (.on response
                          "data"
                          (fn [chunk]
                            (.push bufarr chunk)
                            ))
                     (.on response
                          "end"
                          (fn []
                            (.set client key (.toString (.concat Buffer bufarr) "binary") (fn []
                                                                                            (.expire client key 3600)
                                                                                            (.log console "url is" (+ "https://ssl.dabin.info" key))
                                                                                            (.exit process 0)
                                                                                            ))
                            ))
                     )))
  (.on req
       "error"
       (fn [e]
         (.log console (.-message e))
         (.exit process -1)
         ))
  (.end req))

(crawl_image url)
