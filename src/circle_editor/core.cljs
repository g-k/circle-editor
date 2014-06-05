(ns circle-editor.core
  (:require [om.core :as om :include-macros true]
            [om.dom :as dom :include-macros true]))

(enable-console-print!)

(def app-state (atom {:text "Hello world!"}))

(om/root
  (fn [app owner]
    (let [height (.-innerHeight js/window)
          width (.-innerWidth js/window)
          ]
      (dom/div nil
               (dom/svg #js {:height height
                             :width width
                             :viewBox (apply str (interpose " " [0 0 width height]))
                             :preserveAspectRatio "xMinYMinb"
                             })
               ))
    )
  app-state
  {:target (. js/document (getElementById "app"))})
