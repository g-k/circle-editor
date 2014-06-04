(defproject circle-editor "0.1.0-SNAPSHOT"
  :description "FIXME: write this!"
  :url "http://example.com/FIXME"

  :dependencies [[org.clojure/clojure "1.6.0"]
                 [org.clojure/clojurescript "0.0-2227"]
                 [org.clojure/core.async "0.1.303.0-886421-alpha"]
                 [om "0.6.4"]]

  :plugins [[lein-cljsbuild "1.0.3"]]

  :source-paths ["src"]

  :cljsbuild {
              :builds [{:id "dev"
                        :source-paths ["src"]
                        :compiler {
                                   :output-to "circle_editor.js"
                                   :output-dir "out"
                                   :optimizations :none
                                   :source-map true}}
                       ;; {:id "prod"
                       ;;  :source-paths ["src"]
                       ;;  :compiler {
                       ;;             :output-to "app.min.js"
                       ;;             :optimizations :advanced
                       ;;             :pretty-print false
                       ;;             :preamble ["react/react.min.js"]
                       ;;             :externs ["react/externs/react.js"]}}
                       ]})
