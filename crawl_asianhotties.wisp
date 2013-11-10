(def jsdom (require "jsdom"))
(def swig (require "swig"))
(def http (require "http"))
(def fs (require "fs"))
(def client (.createClient (require "redis")))

(def t (.readFileSync fs "sub_reddit.html" {encoding "utf8"}))

(defn endswith [str suffix] (if (== -1 (.indexOf str suffix (- (.-length str) (.-length suffix)))) false true))

(defn render_reddit [contents] (.render swig
                                        t
                                        {locals {contents contents}}))

(defn crawl_reddit [cb]
  (def cookie "over18=1")
  (def headers {Cookie cookie})
  (def hostname "www.reddit.com")
  (def path "/r/AsianHotties")
  (def options {hostname hostname path path headers headers})
  (def s "")
  (def req (.request http
                   options
                   (fn [response]
                     (.on response
                          "data"
                          (fn [chunk] (set! s (+ s chunk))))
                     (.on response
                          "end"
                          (fn []
                            (cb s)))
                     )))
  (.on req
       "error"
       (fn [e]
         (.log console (.-message e))
         (cb s)
         ))
  (.end req)
)


(defn parse_reddit [s cb]
  (def r [])
  (.env jsdom
        s
        ["http://code.jquery.com/jquery.js"]
        (fn [errors window]
          (if (== null errors)
            (do
              (def site_table (.$ window "#siteTable"))
              (def thing (.find (.$ window site_table) "div.thing"))
              (def length (.-length thing))
              (.log console "length is" length)
              (.each thing (fn [i p]
                             (def a (.find (.$ window p) "a.thumbnail"))
                             (def href (.attr a "href"))
                             (.log console href)
                             (def big_img
                                 (if  (or 
                                        (endswith href "jpg")
                                        (endswith href "jpeg")
                                        (endswith href "png")
                                        (endswith href "gif"))
                                   (+ "https://501fun.dabin.info/proxy?url=" href)
                                   undefined
                                  )
                              )
                             (def img_src (.attr (.find (.$ window a) "img") "src"))
                             (def thumb_img (if img_src (+ "https://501fun.dabin.info/proxy?url=" img_src) undefined))
                             (def entry (.find (.$ window p) "div.entry.unvoted"))
                             (def title (.text (.find (.$ window entry) "a.title")))
                             (.push r {href href title title thumb_img thumb_img big_img big_img})
                             (if (== i (- length 1))
                               (cb r)
                               1
                               )
                             )
                     )
              )
            (cb r)
            )))
  )


(crawl_reddit (fn [s]
              (parse_reddit s (fn [result]
                                (def r_r (render_reddit result))
                                (.set client "missingkey" r_r)
                                (.expire client "missingkey" 3600)
                                (.exit process 0) 
                                ))))