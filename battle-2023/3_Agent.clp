;  ---------------------------------------------
;  --- Definizione del modulo e dei template ---
;  ---------------------------------------------
(defmodule AGENT (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

;------------ TEMPLATE -----------------------------

(deftemplate cell-agent
	(slot x)
	(slot y)	
	(slot status (allowed-values none guess fire unguess))
)

(deftemplate k-per-row-agent
	; (slot step)
	(slot row)
	(slot num)
)

(deftemplate k-per-col-agent
	; (slot step)
	(slot col)
	(slot num)
)


;------------ FATTI -----------------------------


(deffacts initialization
	(first-pass-to-init)
)


;------------ REGOLE -----------------------------

(defrule go-on-init-first (declare (salience 30))
  ?f <- (first-pass-to-init)
=>
  (retract ?f)
  (focus INIT)
)

(defrule go-on-deliberate (declare (salience 20))
(status (step ?s)(currently running))
=>
  (focus DELIBERATION)
)

(defrule go-on-action (declare (salience 10))
  (status (step ?s)(currently running))	
=>
	; (retract (assert-deliberate))
  (focus ACTION)
)

(defrule print-what-i-know-since-the-beginning
	(k-cell (x ?x) (y ?y) (content ?t) )
=>
	(printout t "I know that cell [" ?x ", " ?y "] contains " ?t "." crlf)
)

