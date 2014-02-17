(def fs (require "fs"))

(defn render_main
  (.readFileSync fs "crawl_imag_main.html" {encoding "utf8"}))