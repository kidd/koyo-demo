#lang racket/base

(require koyo/haml
         racket/contract
         forms
         web-server/servlet
         "forms.rkt"
         "../components/template.rkt")

(provide test1-page)

(define/contract (test0-page req)
  (-> request? response?)
  (page (haml (:div (:h1 "hola")))))

(define/contract (test00-page req)
  (-> request? response?)
  (send/suspend
   (lambda (x)
     (page (haml
            (:div
             `(form ([action ,x])
                    "enter a number"
                    (input ([name "number"]))
                    (input ([type "submit"])))))))))

(define/contract (test1-page req)
  (-> request? response?)
  (count-dot-com 0))

(define (count-dot-com i)
  (send/suspend/dispatch
   (lambda (embed/url)
     (response/xexpr
      `(html
        (head (title "Count!"))
        (body
         (h2 (a ([href
                  ,(embed/url
                    (lambda (req)
                      (count-dot-com (sub1 i))))])
                "-"))
         (h1 ,(number->string i))
         (h2 (a ([href
                  ,(embed/url
                    (lambda (req)
                      (count-dot-com (add1 i))))])
                "+"))))))))
