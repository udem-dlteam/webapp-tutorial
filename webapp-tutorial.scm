;;-----------------------------------------------------------------------------

(declare (extended-bindings)) ;; to use ##inline-host-XXX

(define (main)
  #f
  ;; To start the Gambit REPL uncomment the following call:
  ;; (##repl-debug-main)
)

(define (alert x)
  (##inline-host-expression "alert(g_scm2host(@1@))" x))

(define (document.getElementById id)
  (##inline-host-expression "g_host2foreign(document.getElementById(g_scm2host(@1@)))" id))

(define (Element.innerText-ref elem)
  (##inline-host-expression "g_host2scm(g_foreign2host(@1@).innerText)" elem))

(define (sourceCodeRun id)
  (let* ((elem (document.getElementById id))
         (code (Element.innerText-ref elem)))
    (let* ((expr (cons '##begin (with-input-from-string code read-all)))
           (result (eval expr)))
      (read-line)))) ;; show the console with output

;; redirect I/O to console

(current-input-port ##console-port)
(current-output-port ##console-port)

;; TODO: print and println should be defined by the univeral library

(define (##print
         #!key (port (##current-output-port))
         #!rest body)
  (##print-aux body port))

(define print ##print)

(define (##println
         #!key (port (##current-output-port))
         #!rest body)
  (##print-aux body port)
  (##newline port))

(define println ##println)

;;-----------------------------------------------------------------------------

;; setup execution of main procedure when webapp is all loaded

(##inline-host-declaration #<<end-of-inline-host-declaration

g_DOMContentLoaded = function () { alert('DOMContentLoaded'); };
g_sourceCodeRun = function () { alert('sourceCodeRun'); };

document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('div.sourceCode').forEach(function (elem) {
        var button = document.createElement('div');
        elem.prepend(button);
        elem.addEventListener('click', function () {
            elem.classList.toggle('show-runable');
        });
        button.addEventListener('click', function () {
            elem.classList.add('show-runable');
            g_sourceCodeRun(elem.id);
        });
    });
  g_DOMContentLoaded();
});

end-of-inline-host-declaration
)

(##inline-host-statement "g_DOMContentLoaded = g_scm2host(@1@);" main)
(##inline-host-statement "g_sourceCodeRun = g_scm2host(@1@);" sourceCodeRun)

;;-----------------------------------------------------------------------------
