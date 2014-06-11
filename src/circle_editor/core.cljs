(ns circle-editor.core
  (:require
   [cljs.core.async :as async :refer [>! <! put! chan timeout]]
   [goog.events :as events]
   [om.core :as om :include-macros true]
   [om.dom :as dom :include-macros true])
  (:require-macros [cljs.core.async.macros :refer [go]])
  (:import [goog.events EventType]))

(enable-console-print!)

;; data related

(def orbiter-linear-velocity 100) ; pixels?

(def app-state (atom {:text "Hello world!"
                      :height (.-innerHeight js/window)
                      :width (.-innerWidth js/window)
                      :active-brush :orbit ;; unused - maybe a route instead?
                      :start-time (js/Date.)
                      :now (js/Date.)
                      :orbits []
                      :brush-state {}
                      }))

(defn crow-distance [[x1 y1] [x2 y2]]
  (let [pow #(. js/Math pow %1 %2)
        round #(. js/Math round %)
        diff-squared #(pow (- %1 %2) 2)]
    (round (pow (+ (diff-squared x1 x2) (diff-squared y1 y2))
                0.5))))

;; event handling

(def event-type-map
  {EventType/MOUSEMOVE :mouse-move
   EventType/MOUSEDOWN :mouse-down
   EventType/MOUSEUP :mouse-up
   EventType/RESIZE :resize
   EventType/KEYUP :key-up
   EventType/KEYDOWN :key-down
   EventType/KEYPRESS :key-press})

(defn listen [el type]
  (let [out (chan)]
    (events/listen el type #(put! out [(get event-type-map type) %]))
    out))

(defn update-svg-size [e]
  (let [window (.-target e)]
    (swap! app-state assoc :height (.-innerHeight window))
    (swap! app-state assoc :width (.-innerWidth window))))

(defn coords [e] [(.-clientX e) (.-clientY e)])

(defn start-orbit [app e]
  (om/update! app [:brush-state :origin] (coords e)))

(defn update-radius [app e]
  "track the orbit radius if we have an origin from a mousedown"
  (when-let [origin (get-in @app [:brush-state :origin])]
    (let [radius (crow-distance origin (coords e))]
      (om/update! app [:brush-state :radius] radius))))

(defn save-orbit [app]
  (om/transact! app [:orbits] #(conj % (:brush-state @app)))
  (om/update! app [:brush-state] {}))

(defn handle-mouse [app [type e]]
  ;; (. js/console log type)
  ;; TODO: filter to events on the SVG element by scoping listener
  (case type
    :mouse-down (start-orbit app e)
    :mouse-move (update-radius app e)
    :mouse-up (save-orbit app)))

(defn handle-key [app [type e]]
  (case type
    :key-up (println type e)
    :key-down (println type e)
    :key-press (println type e)))

;; Views

(defn orbit-view [{:keys [origin radius t start-time] :as orbit} owner]
  (reify om/IRender
    (render [_]
      (let [[x y] origin
            t  (/ (- (.valueOf t) (.valueOf start-time)) 1000)
            cos #(. js/Math cos %)
            sin #(. js/Math sin %)
            round #(. js/Math round %)
            tmp (/ orbiter-linear-velocity (* radius t))
            cx (round (+ x (* radius (cos tmp))))
            cy (round (+ y (* radius (sin tmp))))
            _ (println "t" t "cx" cx "cy" cy)
            ]
        (dom/g nil
               (dom/circle #js {:r radius :cx x :cy y})
               (dom/circle #js {:className "orbiter" :r 3 :cx cx :cy cy}))
        ))))

(defn app-view
  [{:keys [height width] :as app} owner]
  (reify
    om/IWillMount
    (will-mount [_]
      (let [resizes (listen js/window EventType/RESIZE)

            mouse-downs (listen js/window EventType/MOUSEDOWN)
            mouse-moves (listen js/window EventType/MOUSEMOVE)
            mouse-ups (listen js/window EventType/MOUSEUP)

            mouse-events (async/merge [mouse-downs mouse-moves mouse-ups])

            key-presses (listen js/window EventType/KEYPRESS)
            key-downs (listen js/window EventType/KEYDOWN)
            key-ups (listen js/window EventType/KEYUP)

            key-events (async/merge [key-presses key-downs key-ups])
            ]
        (go (while true
              (update-svg-size (<! resizes))))

        (go (while true
              (handle-mouse app (<! mouse-events))))

        (go (while true
              (handle-key app (<! key-events))))
        )

      (go (while true
            (<! (timeout 1))
            ;; (om/update! app [:last-render] (:now @app))
            (om/update! app [:now] (js/Date.))))
      )
    om/IDidMount
    (did-mount [this] (let [svg (om/get-node owner "svg")]))
    ;; om/IShouldUpdate
    ;; (should-update [_ _ _] true)
    om/IRenderState
    (render-state [this state]
      (let [{:keys [orbits start-time now]} app
            {:keys [radius origin] :as brush} (-> app :brush-state)
             orbit-preview-edge-props #js {:className "orbit-preview edge"
                                           :r radius
                                           :cx (first origin)
                                           :cy (second origin)}
             orbit-preview-center-props #js {:className "orbit-preview center"
                                             :r 2
                                             :cx (first origin)
                                             :cy (second origin)}
             ]
        (dom/svg #js {:height height
                      :width width
                      :viewBox (apply str (interpose " " [0 0 width height]))
                      :preserveAspectRatio "xMinYMinb"
                      :ref "svg"}
                 (when (and radius origin)
                   (dom/circle orbit-preview-edge-props))
                 (when (and radius origin)
                   (dom/circle orbit-preview-center-props))

                 (apply dom/g nil (om/build-all orbit-view (map #(-> %
                                                                     (assoc :t now)
                                                                     (assoc :start-time start-time)) orbits)))

                 ))
      )))


(om/root app-view app-state
  {:target (. js/document (getElementById "app"))})
