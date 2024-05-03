(defmodule ACTION (import AGENT ?ALL) (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

;------------ REGOLE -----------------------------

;  exec della fire
(defrule exec-action-fire (declare (salience 90))
   (status (step ?step) (currently running))
   (exec-agent (step ?step) (action fire) (x ?x) (y ?y))
   =>
   (assert (exec (step ?step) (action fire) (x ?x) (y ?y)))
   (pop-focus)
)
;  exec della guess
(defrule exec-action-guess (declare (salience 90))
   (status (step ?step) (currently running))
   (exec-agent (step ?step) (action guess) (content ?content) (x ?x) (y ?y))
   =>
   (assert (exec (step ?step) (action guess) (x ?x) (y ?y)))
   (pop-focus)
)

; exec della unguess
(defrule exec-action-unguess (declare (salience 90))
    (status (step ?s)(currently running))
    (exec-agent (step ?step) (action unguess) (x ?x) (y ?y))
   =>
   (assert (exec (step ?step) (action unguess) (x ?x) (y ?y)))
   (pop-focus)
)
