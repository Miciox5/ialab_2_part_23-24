(defmodule ACTION (import AGENT ?ALL) (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

;------------ REGOLE -----------------------------

; Update score di tutte le colonne di una riga
(defrule update-scores-rows (declare (salience 100))
    ?a <- (action(name ?n)(x ?x)(y ?y))
   ?cell-to-upd <- (cell-agent (x ?row) (y ?y) (status none) )
   (k-per-row-agent (row ?row) (num ?nr))
   (k-per-col-agent (col ?y) (num ?nc))
   =>
    (modify ?cell-to-upd (score (* ?nr ?nc)))
)
; Update score di tutte le righe di una colonna
(defrule update-scores-cols (declare (salience 100))
    ?a <- (action(name ?n)(x ?x)(y ?y))
   ?cell-to-upd <- (cell-agent (x ?x) (y ?col) (status none) )
   (k-per-col-agent (col ?col) (num ?nc))
   (k-per-row-agent (row ?x) (num ?nr))
   =>
   (modify ?cell-to-upd (score (* ?nr ?nc)))
)

;  exec della guess
(defrule exec-action-guess (declare (salience 90))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 0)))
    ?a <- (action(name ?n)(x ?x)(y ?y))
   =>
   (assert (exec (step ?s) (action ?n) (x ?x) (y ?y)))
   (retract ?a)
   (pop-focus)
)


















;;emettono azioni di exec casuali (non fanno niente così)
;;fondamentale: ogni volta che viene eseguita una exec, l'importante è garantire che 
;;venga eseguita una (pop-focus) -> quando abbiamo deliberato l'azione in un determinato passo
;;il controllo deve ritornare al MAIN, per poi passare all'ENV e fare un check sull'ambiente
;;l'ambiente si aspetta un'azione per stack
; (defrule inerzia0 (declare (salience 10))
; 	;; step -> passo corrente, marcatore dell'exec (come se fosse il clock globale dell'ambiente)
; 	(status (step ?s)(currently running))
; 	(moves (fires 0) (guesses ?ng&:(> ?ng 0)))
; =>
; 	(assert (exec (step ?s) (action guess) (x 0) (y 0)))
;      (pop-focus)

; )

; (defrule inerzia0-bis (declare (salience 10))
; 	(status (step ?s)(currently running))
; 	(moves (guesses 0))
; =>
; 	(assert (exec (step ?s) (action unguess) (x 0) (y 0)))
;      (pop-focus)

; )



; (defrule inerzia
; 	(status (step ?s)(currently running))
; 	(not (exec  (action fire) (x 2) (y 4)) )
; =>
; 	(assert (exec (step ?s) (action fire) (x 2) (y 4)))
;      (pop-focus)

; )

; (defrule inerzia1
; 	(status (step ?s)(currently running))
; 	(not (exec  (action fire) (x 2) (y 5)))
; =>


; 	(assert (exec (step ?s) (action fire) (x 2) (y 5)))
;      (pop-focus)

; )

; (defrule inerzia2
; 	(status (step ?s)(currently running))
; 	(not (exec  (action fire) (x 2) (y 6)))

; =>

; 	(assert (exec (step ?s) (action fire) (x 2) (y 6)))
;      (pop-focus)

; )

; (defrule inerzia3
; 	(status (step ?s)(currently running))
; 	(not (exec  (action fire) (x 1) (y 2)))

; =>
; 	(assert (exec (step ?s) (action fire) (x 1) (y 2)))
;      (pop-focus)
; )


; (defrule inerzia4
; 	(status (step ?s)(currently running))
; 	(not (exec (action fire) (x 7) (y 5)))
; =>

; 	(assert (exec (step ?s) (action fire) (x 7) (y 5)))
;      (pop-focus)



; )

; (defrule inerzia5
; 	(status (step ?s)(currently running))

; 	(not (exec (action fire) (x 8) (y 3)))
; =>



; 	(assert (exec (step ?s) (action fire) (x 8) (y 3)))
;      (pop-focus)


; )


; (defrule inerzia6
; 	(status (step ?s)(currently running))
; 		(not (exec  (action fire) (x 8) (y 4)))
; =>


; 	(assert (exec (step ?s) (action fire) (x 8) (y 4)))
;      (pop-focus)

; 	)





; (defrule inerzia7
; 	(status (step ?s)(currently running))
; 		(not (exec  (action fire) (x 8) (y 5)))
; =>


; 	(assert (exec (step ?s) (action fire) (x 8) (y 5)))
;      (pop-focus)

; )


; (defrule inerzia8
; 	(status (step ?s)(currently running))
; 		(not (exec  (action fire) (x 6) (y 9)))
; =>


; 	(assert (exec (step ?s) (action fire) (x 6) (y 9)))
;      (pop-focus)
; )


; (defrule inerzia9
; 	(status (step ?s)(currently running))
; 		(not (exec  (action fire) (x 7) (y 9)))
; =>


; 	(assert (exec (step ?s) (action fire) (x 7) (y 9)))
;      (pop-focus)
; )

; (defrule inerzia10 (declare (salience 30))
; 	(status (step ?s)(currently running))
; 		(not (exec  (action fire) (x 6) (y 4)))
; =>


; 	(assert (exec (step ?s) (action fire) (x 6) (y 4)))
;      (pop-focus)
; )

; (defrule inerzia11 (declare (salience 30))
; 	(status (step ?s)(currently running))
; 		(not (exec  (action guess) (x 7) (y 7)))
; =>


; 	(assert (exec (step ?s) (action guess) (x 7) (y 7)))
;      (pop-focus)
; )


; (defrule inerzia20 (declare (salience 30))
; 	(status (step ?s)(currently running))
; 	(not (exec  (action guess) (x 1) (y 3)))
; =>


; 	(assert (exec (step ?s) (action guess) (x 1) (y 3)))
;      (pop-focus)

; )

; (defrule inerzia21  (declare (salience 30))
; 	(status (step ?s)(currently running))
; 	(not (exec  (action guess) (x 1) (y 4)))
; =>


; 	(assert (exec (step ?s) (action guess) (x 1) (y 4)))
;      (pop-focus)

; )
