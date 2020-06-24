#lang racket/base

(require (for-syntax racket/base)
         koyo/config
         koyo/database-url
         koyo/l10n
         koyo/profiler
         koyo/url
         racket/runtime-path
         web-server/http/id-cookie)

;; locales ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-runtime-path locales-path
  (build-path 'up "resources" "locales"))

(current-locale-specifier 'my-first-web)
(load-locales! locales-path)


;; config values ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(current-option-name-prefix "MY_FIRST_WEB")

(define-option version #:default "dev")
(define-option debug
  (equal? debug "x"))

(define-option profile
  (begin0 profile
    (profiler-enabled? (and profile #t))))

(define-option log-level #:default "info"
  (string->symbol log-level))

(define-option http-host #:default "127.0.0.1")
(define-option http-port #:default (or (getenv "PORT") "8000")
  (string->number http-port))

(define-option url-scheme #:default "http"
  (begin0 url-scheme
    (current-application-url-scheme url-scheme)))

(define-option url-host #:default "127.0.0.1"
  (begin0 url-host
    (current-application-url-host url-host)))

(define-option url-port #:default (or (getenv "PORT") "8000")
  (begin0 url-port
    (current-application-url-port (string->number url-port))))

(define-values (_ default-db-host default-db-port default-db-name default-db-username default-db-password)
  (parse-database-url (or (getenv "DATABASE_URL") "postgres://my_first_web:my_first_web@127.0.0.1:5432/my_first_web")))

(define-option db-name #:default default-db-name)
(define-option db-username #:default default-db-username)
(define-option db-password #:default default-db-password)
(define-option db-host #:default default-db-host)
(define-option db-port #:default (number->string default-db-port)
  (string->number db-port))

(define-option test-db-name #:default "my_first_web_tests")
(define-option test-db-username #:default "my_first_web")
(define-option test-db-password #:default "my_first_web")
(define-option test-db-host #:default "127.0.0.1")
(define-option test-db-port #:default "5432"
  (string->number test-db-port))

(define-option session-cookie-name #:default "_sid")
(define-option session-shelf-life #:default "86400"
  (string->number session-shelf-life))
(define-option session-secret-key-path #:default "/tmp/my-first-web-secret-key")
(define-option session-secret-key
  (or session-secret-key (make-secret-salt/file session-secret-key-path)))

(define-option postmark-token)

(define-option product-name #:default "my-first-web")
(define-option company-name #:default "my-first-web")
(define-option company-address #:default "")
(define-option support-name #:default "Bot Botterson")
(define-option support-email #:default "support@my-first-web.com")

(provide common-mail-variables)
(define common-mail-variables
  (hasheq 'product_url     (make-application-url)
          'product_name    product-name
          'company_name    company-name
          'company_address company-address
          'sender_name     support-name
          'support_email   support-email))