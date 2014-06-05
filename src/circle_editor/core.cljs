(ns circle-editor.core
  (:require
   [goog.events :as events]
   [om.core :as om :include-macros true]
   [om.dom :as dom :include-macros true])
  (:import [goog.events EventType]))

(enable-console-print!)

(def app-state (atom {:text "Hello world!"
                      :height (.-innerHeight js/window)
                      :width (.-innerWidth js/window)
                      }))

(defn update-svg-size [_]
  (swap! app-state assoc :height (.-innerHeight js/window))
  (swap! app-state assoc :width (.-innerWidth js/window)))

(events/listen js/window EventType/RESIZE update-svg-size)


(om/root
 (fn [{:keys [height width] :as app} owner]
    (let []
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
