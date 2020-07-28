---
title: Gambit Scheme Web App Tutorial
author: Marc Feeley
date: July 27, 2020
---

-------------------------------------------------------------------------------

## Introduction

- Gambit Scheme is an R7RS compliant Scheme system with an optimizing
compiler supporting multiple target languages

- Its JS backend allows writing web apps in Scheme

- This slide deck has been prepared with Gambit's JS backend,
`pandoc`{.plain} and `reveal.js`{.plain}

- Click on any code example to run it in your browser

-------------------------------------------------------------------------------

## Hello world at the REPL

~~~{.scm runable=}
(println "Hello world")
~~~

- When this code is run, the browser will display the output in a
dialog box that acts as the REPL... simply press **ESC**, or **RETURN**, or
click **OK** to dismiss the dialog

-------------------------------------------------------------------------------

## Access the power of Scheme

- Use `lambda`, lists, bignums, pretty-printing, ...

~~~{.scm runable=}
(define (fact n)
  (if (< n 2)
      1
      (* n (fact (- n 1)))))

(pp (map (lambda (n) (list n (fact n))) (iota 6 5 5)))
~~~

-------------------------------------------------------------------------------

## Tail-calls and first-class continuations too!

~~~{.scm runable=}
(define (sum n x) (if (> n 0) (sum (- n 1) (+ n x)) x))

(define (map-inverse lst)
  (call/cc
    (lambda (return)
      (map (lambda (x) (if (= x 0) (return 'error) (/ 1 x))) lst))))

(pp (sum 100000 0))

(pp (map-inverse '(1 2 3 4 5)))

(pp (map-inverse '(1 2 0 4 5)))
~~~

-------------------------------------------------------------------------------

## Debugging with the REPL

~~~{.scm runable=}
(define (fibs n a b)
  (if (= n 0)
      nil  ;; exception "Unbound variable: nil"
      (cons a (fibs (- n 1) b (+ a b)))))

(pp (fibs 4 0 1))
~~~

- Uncaught Scheme exceptions will start a REPL

- Type `,e` for the variable bindings

- Type `,b` for a backtrace or `,be` for a backtrace with variable bindings

- Type `,q` or `(exit)` or **ESC** twice to leave the REPL

-------------------------------------------------------------------------------

## Simple Interfacing to JS

~~~{.scm runable=}
(host-exec "alert('hello from JS');")
~~~

- The `host-exec` special form allows executing JS statements, here
a call to the `alert` function

- The `host-exec` special form returns the void object

- The similar `host-eval` special form allows executing JS
expressions (that have a result), as shown in the next example

-------------------------------------------------------------------------------

## Passing Values from JS to Scheme

~~~{.scm runable=}
(define (Date) (host-eval "g_host2scm(Date().toString())"))

(pp (Date))
~~~

- The date as a JS string is converted to a Scheme string by the call
`g_host2scm(<js_value>)`

- `g_host2scm` converts simple values including JS booleans,
numbers, strings, arrays and functions

-------------------------------------------------------------------------------

## Passing Values from Scheme to JS

~~~{.scm runable=}
(define (clz32 n)  ;; "Count leading zeroes"
  (host-eval "g_host2scm(Math.clz32(g_scm2host(@1@)))"
             n))

(pp (map clz32 '(0 1 2 3 4 5 6 7)))
~~~

- `g_scm2host(<scm_value>)` converts simple Scheme values to their
JS representation

- `@1@` is replaced by the second `host-eval` parameter, `@2@` by the third,
etc

-------------------------------------------------------------------------------

## Exporting Scheme Procedures to JS

~~~{.scm runable= small=}
(define (background-set! id color)
  (host-exec
   "var c = g_scm2host(@2@);
    document.getElementById(g_scm2host(@1@)).style.background = c;"
   id
   color))

(define (addEventListener type thunk)
  (host-exec
   "var f = g_scm2host(@2@);
    document.addEventListener(g_scm2host(@1@),function () { f(); });"
   type
   thunk))

(addEventListener "dblclick"
                  (let ((state #f))
                    (lambda ()
                      (set! state (not state))
                      (background-set!
                       "exporting-scheme-procedures-to-js"
                       (if state "lightgreen" "white")))))
~~~

- After running this code, double click events will toggle the
background color of this slide
