(defn startswith [str prefix] (if (== 0 (.indexOf str prefix 0)) true false))

(def http (require "http"))
(def https (require "https"))
(def client (.createClient (require "redis")))
(def url (aget (.-argv process) 2))
(def citr "citr/")

(defn crawl_image [url]
  (def received 0)
  (def arr (.split url "/"))
  (def name (aget arr (- (.-length arr) 1)))
  (def fucking_http (if (startswith url "https") https http))
  (def s "")
  (def req (.request fucking_http
                   url
                   (fn [response]
                     (.on response
                          "data"
                          (fn [chunk] (set! s (+ s chunk))))
                     (.on response
                          "end"
                          (fn []
                            (def key (+ citr name))
                            (.set client key s)
                            (.expire client key 3600)
                            (.log console "url is" (+ "https://ssl.dabin.info/" key))
                            (.exit process 0)))
                     )))
  (.on req
       "error"
       (fn [e]
         (.log console (.-message e))
         (.exit process -1)
         ))
  (.end req))

(crawl_image url)
