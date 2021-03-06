#lang racket/base

(require (for-syntax racket/base)
         component
         koyo/profiler
         koyo/session
         koyo/url
         net/url
         racket/contract
         racket/match
         racket/string
         threading
         web-server/http
         "user.rkt")

;; auth-manager ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide
 current-user

 make-auth-manager
 auth-manager?
 auth-manager-login!
 auth-manager-logout!
 wrap-auth-required

 exn:fail:auth-manager?
 exn:fail:auth-manager:unverified?)

(define session-key 'uid)

(define/contract current-user
  (parameter/c (or/c false/c user?))
  (make-parameter #f))

(struct exn:fail:auth-manager exn:fail ())
(struct exn:fail:auth-manager:unverified exn:fail:auth-manager ())

(struct auth-manager (sessions users)
  #:methods gen:component [])

(define/contract (make-auth-manager sessions users)
  (-> session-manager? user-manager? auth-manager?)
  (auth-manager sessions users))

(define/contract (auth-manager-login! am username password)
  (-> auth-manager? non-empty-string? non-empty-string? (or/c false/c user?))
  (match (user-manager-login (auth-manager-users am) username password)
    [#f #f]
    [(and (struct* user ([id id] [verified? verified?])) user)
     (unless verified?
       (raise (exn:fail:auth-manager:unverified "this user is not verified" (current-continuation-marks))))

     (begin0 user
       (session-set! session-key (number->string id)))]))

(define/contract (auth-manager-logout! _am)
  (-> auth-manager? void?)
  (session-remove! session-key))

(define/contract (((wrap-auth-required am req-roles) handler) req)
  (-> auth-manager?
      (-> request? (listof symbol?))
      (-> (-> request? response?)
          (-> request? response?)))

  (with-timing 'auth "wrap-auth-required"
    (define roles (req-roles req))
    (cond
      [(null? roles)
       (handler req)]

      ;; NOTE: Roles are not actually checked beyond this point.  If you
      ;; implement roles other than 'user then you're going to want to
      ;; change this.
      [(and~>> (session-ref session-key #f)
               (string->number)
               (user-manager-lookup/id (auth-manager-users am)))
       => (lambda (user)
            (parameterize ([current-user user])
              (handler req)))]

      [else
       (redirect-to (make-application-url "login" #:query `((return . ,(url->string (request-uri req))))))])))
