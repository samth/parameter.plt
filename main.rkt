#lang scheme/base

(require (for-syntax scheme/base)
         (for-syntax syntax/struct)
         scheme/contract)

(provide pseudo-parameter? make-pseudo-parameter pseudo-parameter/c define-parameter-set)

(define-struct pseudo-parameter (getter setter)
  #:property prop:procedure (case-lambda
                              [(pp) ((pseudo-parameter-getter pp))]
                              [(pp x) ((pseudo-parameter-setter pp) x)]))

(define (pseudo-parameter?/first-order x)
  (and (pseudo-parameter? x)
       (let ([getter (pseudo-parameter-getter x)]
             [setter (pseudo-parameter-setter x)])
         (and (procedure? getter)
              (procedure-arity-includes? getter 0)
              (procedure? setter)
              (procedure-arity-includes? setter 1)))))


(define (pseudo-parameter/c c0)
  (define c (coerce-contract pseudo-parameter/c c0))
  (make-contract
   #:name `(pseudo-parameter/c ,(contract-name c))
   #:first-order pseudo-parameter?/first-order
   #:projection
   (lambda (blame)
     (let* ([c-proj (contract-projection c)]
            [pos-proj (c-proj blame)]
            [neg-proj (c-proj (blame-swap blame))])
       (lambda (p)
         (let ([getter (pseudo-parameter-getter p)]
               [setter (pseudo-parameter-setter p)])
           (make-pseudo-parameter
            (lambda ()
              (pos-proj (getter)))
            (lambda (x)
              (setter (neg-proj x))))))))))

(define-syntax (define-parameter-set stx)
  (syntax-case stx ()
    [(define-parameter-set struct current (param default . maybe-guard) ...)
     (with-syntax ([(struct:pset make-pset pset? get-field ...)
                    (build-struct-names #'struct (syntax->list #'(param ...)) #f #t stx)])
       #'(begin
           (define param (make-parameter default . maybe-guard)) ...
           (define-struct struct (param ...) #:prefab)
           (define current
             (make-pseudo-parameter
              (lambda ()
                (make-pset (param) ...))
              (lambda (x)
                (unless (pset? x)
                  (error 'current "expected a parameter set of type ~a, received: ~v" 'struct x))
                (param (get-field x)) ...
                x)))))]))
