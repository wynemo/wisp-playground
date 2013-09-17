(def jsdom (require "jsdom"))
(def swig (require "swig"))
(def http (require "http"))
(def client (.createClient (require "redis")))

(def t "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /><meta content='width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;' name='viewport' /><title>asian hotties</title><style>.container {max-width: 960px;} img {max-width: 100%;}</style></head><body><div class=\"container\">{% for content in contents %}<div><a href=\"{{content.href}}\">{{content.title}}{% if content.thumb_img %}<img src=\"{{content.thumb_img}}\" width=\"70\" height=\"69\" alt=\"\">{% endif %}</a></div>{% if content.big_img %}<img src=\"{{content.big_img}}\" >{% endif %}{% endfor %}</div></body></html>")

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
                             (def thumb_img (+ "https://501fun.dabin.info/proxy?url=" (.attr (.find (.$ window a) "img") "src")))
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
            (r cb)
            )))
  )


(crawl_reddit (fn [s]
              (parse_reddit s (fn [result]
                                (def r_r (render_reddit result))
                                (.set client "missingkey" r_r)
                                (.expire client "missingkey" 3600)
                                (.exit process 0) 
                                ))))