;  ---------------------------------------------
;  --- Definizione del modulo e dei template ---
;  ---------------------------------------------
(defmodule AGENT (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

;------------ TEMPLATE -----------------------------

(deftemplate cell-agent
	(slot x)
	(slot y)	
	(slot content (allowed-values none water left right middle top bot sub)) ;il contenuto ce lo dice la fire
	(slot status (allowed-values none guess unguess know ))
	(slot score )
	(slot original-score)
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

(deftemplate exec-agent
	(slot step)
	(slot action (allowed-values guess fire unguess solve))
	(slot content (default none) (allowed-values none water left right middle top bot sub))
	(slot state-dfs (default greedy) (allowed-values greedy explore backtracking))
	(slot x)
	(slot y)
)

; (deftemplate boat-agent
; 	(slot id (default-dynamic (gensym*)))
; 	(slot name (allowed-values corazzata incrociatore cacciatorpediniere sottomarino))
; 	(slot qty)
; 	(slot boat-pieces)
; )

(deftemplate boat-agent
	(slot id (default-dynamic (gensym*)))
	(slot name (allowed-values corazzata incrociatore caccia sottomarino))
)

; (deftemplate boat-hor-agent
; 	(slot name)
; 	(slot x)
; 	(multislot ys) 
; 	(slot size)
; 	(multislot status (allowed-values safe hit)) 
; )

; (deftemplate boat-ver-agent
;     (slot name)
; 	(multislot xs)
; 	(slot y)
; 	(slot size)
; 	(multislot status (allowed-values safe hit))
; )

; template per action
(deftemplate update-score-row
    (slot row )
	(slot num )
	(slot y-to-upd )
)
(deftemplate update-score-col
    (slot col )
	(slot num )
	(slot x-to-upd )
)

;------------ FATTI -----------------------------


(deffacts initialization
	(first-pass-to-init)
	(boat-agent (name corazzata))
	(boat-agent (name incrociatore))
	(boat-agent (name incrociatore))
	(boat-agent (name caccia))
	(boat-agent (name caccia)) 
	(boat-agent (name caccia))
	(boat-agent (name sottomarino))
	(boat-agent (name sottomarino))
	(boat-agent (name sottomarino))
	(boat-agent (name sottomarino))
)


;------------ REGOLE -----------------------------

(defrule go-on-init-first (declare (salience 40))
  	?f <- (first-pass-to-init)
=>
  	(retract ?f)
  	(focus INIT)
)

(defrule go-on-update-kc (declare (salience 30))
	(status (step ?s)(currently running))
=>
  	(focus UPDATE_KC)
)


(defrule go-on-deliberate (declare (salience 20))
	(status (step ?s)(currently running))
=>
	(focus DELIBERATION)
)

(defrule go-on-action (declare (salience 10))
	(status (step ?s)(currently running))	
=>
	(focus ACTION)
)
