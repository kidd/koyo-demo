#lang racket/base

(require koyo/haml
         racket/contract
         ;; web-server/http
         racket/match
         web-server/servlet
         forms
         "forms.rkt"
         "../components/template.rkt")

(provide
 dashboard-page)

(define shitty-form
  (form* ([name (ensure binding/text (required))]
          [age (ensure binding/number (required))])
         (list name age)))

(define (post-name-age-page req)
  (page
   (haml
    (.container
     (:h1 "yesss")))))

(define (foo req)
  (haml (:div
         (:p "hola from foo")
         (:p "adeu")

         (match (form-run shitty-form req)
           [(list 'passed (list name age) render-widget)
            (with-handlers ([exn:fail
                             (lambda _
                               ;(render render-widget "wroooong")
                               (page
                                (haml
                                 (:h1 "wrong data"))))])
              ;(post-name-age-page (redirect/get/forget))
              (page
               (haml
                (:h1 "ok data")))
              )]
           [(list _ _ render-widget)
            ;(render render-widget)
            (haml
             (:form.form.form--name-age
              ([:action "/foo"]
               [:method "POST"])
              (:h1.form__title "tituloo")

              (render-widget "name" (username-field))
              (render-widget "age" (age-field))

              (:button.button.button--primary
               ([:type "submit"])
               "DO IT")

              ))]
           ))))

(define/contract (dashboard-page _req)
  (-> request? response?)
  (page
   (haml
    (.container
     (:h1 "Hello World!")
     (:div (:p "hola"))
     (foo _req)
     ))))
