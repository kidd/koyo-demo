#lang racket/base

(require koyo/haml
         racket/contract
         forms
         web-server/servlet
         "forms.rkt"
         "../components/template.rkt")

(provide test1-page)

(define/contract (test1-page req)
  (-> request? response?)
  (send/suspend
   (lambda (x)
     (page (haml
            (:div
             `(form ([action ,x])
                    "enter a number"
                    (input ([name "number"]))
                    (input ([type "submit"])))))))))
