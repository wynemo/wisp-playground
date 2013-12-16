(def swig (require "swig"))
(def fs (require "fs"))

(def t (.readFileSync fs "index.html" {encoding "utf8"}))

(defn render_index [contents] (.render swig
                                        t
                                        {locals {contents contents}}))
