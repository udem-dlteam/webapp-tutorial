---
title: Gambit Scheme Web App Tutorial
author: Marc Feeley
date: July 29, 2020
---

-------------------------------------------------------------------------------

## Introduction

- Gambit Scheme is an R7RS compliant Scheme system with an optimizing
compiler supporting multiple target languages

- Its JS backend allows writing web apps in Scheme

- This slide deck has been prepared with Gambit's JS backend,
`pandoc`{.plain} and `reveal.js`{.plain}

- Click on any code example to run it in your browser

- Slide deck sources:

    <https://github.com/udem-dlteam/webapp-tutorial>

-------------------------------------------------------------------------------

## Hello world

~~~{.scm runable=}
(alert "Hello world!")

(alert (string-append
         "Hello "
         (prompt "What's your name?")
         "!"))
~~~

- When this code is run, the browser's `alert` and `prompt` JS functions
are called to do basic I/O through dialog boxes

- More elaborate interfacing to JS code is explained later in this
presentation

-------------------------------------------------------------------------------

## Access the power of Scheme

~~~{.scheme runable= small=}
(define (fact n) (if (< n 2) 1 (* n (fact (- n 1)))))

(define-macro (show . body)
  `(alert (with-output-to-string (lambda () ,@body))))

(show
  (pretty-print (with-input-from-file "default.css" read-line))
  (pretty-print (map (lambda (n) `((fact ,n) = ,(fact n)))
                     (iota 6 5 5))))
~~~

- Use `lambda`, lists, bignums, macros, files, pretty-printing, ...

- Files are read from the web server relative to the document's root

-------------------------------------------------------------------------------

## Tail-calls and `call/cc`{.plain} too!

~~~{.scm runable=}
(define (sum n x)
  (if (> n 0) (sum (- n 1) (+ n x)) x))

(define (map-inverse lst)
  (call/cc
    (lambda (return)
      (map (lambda (x)
             (if (= x 0)
                 (return 'divide-by-zero)
                 (/ 1 x)))
           lst))))

(alert (list (sum 100000 0)
             (map-inverse '(1 2 3 4 5))
             (map-inverse '(1 2 0 4 5))))
~~~

-------------------------------------------------------------------------------

## Debugging with the REPL

~~~{.scm runable=}
(define (fibs a b)
  (if (< b 2)
      (cons a (fibs b (+ a b)))
      nil))  ;; exception "Unbound variable: nil"

(alert (fibs 0 1))
~~~

- Uncaught Scheme exceptions will start a REPL

- Type `,e` for the variable bindings, `,b` for a backtrace or `,be`
for a backtrace with variable bindings

- Type `,q` or `(exit)` or **ESC** twice to leave the REPL

- Type `,(c '())` to continue execution with `'()` result

-------------------------------------------------------------------------------

## Simple Interfacing to JS

~~~{.scm runable=}
(host-exec "alert('location='+window.location);")
~~~

- The `host-exec` special form allows executing JS statements, here
a call to the `alert` function

- The `host-exec` special form returns the void object

- The similar `host-eval` special form allows executing JS
expressions (that have a result), as shown in the next slide

-------------------------------------------------------------------------------

## Passing Values from JS to Scheme

~~~{.scm runable=}
(define (Date)
  (host-eval "g_host2scm(Date().toString())"))

(alert (Date))
~~~

- The date as a JS string is converted to a Scheme string by the call
`g_host2scm(<js_value>)`

- `g_host2scm` converts simple values including JS booleans,
numbers, strings, arrays and functions

-------------------------------------------------------------------------------

## Passing Values from Scheme to JS

~~~{.scm runable=}
(define (clz32 n)  ;; "Count leading zeroes"
  (host-eval
    "g_host2scm(Math.clz32(g_scm2host(@1@)))"
    n))

(alert (map clz32 '(0 1 2 3 4 5 6 7)))
~~~

- `g_scm2host(<scm_value>)` converts simple Scheme values to their
JS representation

- `@1@` is replaced by the second `host-eval` parameter, `@2@` by the third,
etc

-------------------------------------------------------------------------------

## Exporting Scheme Procedures to JS

~~~{.scm runable= tiny=}
(define (background-set! id color)
  (host-exec
   "var c = g_scm2host(@2@);  // convert Scheme string to JS
    document.querySelector(g_scm2host(@1@)).style.background = c;"
   id
   color))

(define (addEventListener type thunk)
  (host-exec
   "var t = g_scm2host(@2@);  // convert Scheme procedure to JS
    document.addEventListener(g_scm2host(@1@),function () { t(); });"
   type
   thunk))

(addEventListener "dblclick"
                  (let ((white-bg #t))
                    (lambda ()
                      (set! white-bg (not white-bg))
                      (background-set!
                       "#exporting-scheme-procedures-to-js"
                       (if white-bg "white" "lightgreen")))))
~~~

- After running this code, double click events will toggle the
background color of this slide

-------------------------------------------------------------------------------

## Your Turn!

~~~{.scm runable= contenteditable="true" style="height: 500px"}
;; enter Scheme code here, then click run button
 
 
 
 
 
 
 
 
  
;; if you'd rather use the Gambit REPL directly,
;; uncomment the next line and click run button
;; (##repl-debug-main)
~~~
