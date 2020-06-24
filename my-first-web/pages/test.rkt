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
  (page (haml (:div (:h1 "hola")))))
