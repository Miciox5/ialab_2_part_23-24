(defmodule ACTION (import AGENT ?ALL) (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

;------------ REGOLE -----------------------------

; Le due regole seguenti aggiornano lo score di una riga ma non quello della cella dove è stata fatta la guess
; (rimane lo score di quando ho fatto la guess)

; Update score di tutte le colonne di una riga
(defrule update-scores-rows (declare (salience 100))
   ?a <- (update-score-col (col ?col) (num ?nc) (x-to-upd ?x))
   ?cell-to-upd <- (cell-agent (x ?x) (y ?col) (status ?s&:(neq ?s guess)))
   (k-per-row-agent (row ?x) (num ?nr))
   =>
    (modify ?cell-to-upd (score (* ?nr ?nc)))
    (retract ?a)
    (assert (update-score-col (col ?col) (num ?nc) (x-to-upd (+ ?x 1))))
)
; else
(defrule update-scores-rows-index (declare (salience 95))
   ?a <- (update-score-col (col ?col) (num ?nc) (x-to-upd ?x))
   ?cell-to-upd <- (cell-agent (x ?x) (y ?col) (status guess))
   (k-per-row-agent (row ?x) (num ?nr))
   =>
    (retract ?a)
    (assert (update-score-col (col ?col) (num ?nc) (x-to-upd (+ ?x 1))))
)

; Aggiornamento degli score di una colonna tranne per la cella in cui è stata fatta la guess
; (rimane lo score di quando ho fatto la guess)

; Update score di tutte le righe di una colonna
(defrule update-scores-cols (declare (salience 100))
   ?a <- (update-score-row (row ?row) (num ?nr) (y-to-upd ?y))
   ?cell-to-upd <- (cell-agent (x ?row) (y ?y))
   (k-per-col-agent (col ?y) (num ?nc))
   =>
    (modify ?cell-to-upd (score (* ?nr ?nc)))
    (retract ?a)
    (assert (update-score-row (row ?row) (num ?nr) (y-to-upd (+ ?y 1))))
)
; else 
(defrule update-scores-cols-index (declare (salience 95))
   ?a <- (update-score-row (row ?row) (num ?nr) (y-to-upd ?y))
   ?cell-to-upd <- (cell-agent (x ?row) (y ?y))
   (k-per-col-agent (col ?y) (num ?nc))
   =>
    (retract ?a)
    (assert (update-score-row (row ?row) (num ?nr) (y-to-upd (+ ?y 1))))
)


(defrule finish-update-score-row ( declare (salience 90) ) 
    ?factr <- (update-score-row (row ?r) (num ?n) (y-to-upd 10) )
    =>
    (retract ?factr)

)
(defrule finish-update-score-col ( declare (salience 90) ) 
    ?factc <- (update-score-col (col ?col) (num ?nc) (x-to-upd 10)) 
    =>
    (retract ?factc)

)
;  exec della fire
(defrule exec-action-fire (declare (salience 90))
    (status (step ?s)(currently running))
    (moves (fires ?nf&:(> ?nf 1)))
    ?a <- (action (name fire)(x ?x)(y ?y))
   =>
   (assert (exec (step ?s) (action fire) (x ?x) (y ?y)))
   (retract ?a)
   (assert (fire (x ?x) (y ?y)))
   (pop-focus)
)
;  exec della guess
(defrule exec-action-guess (declare (salience 90))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 0)))
    ?a <- (action(name ?guess)(x ?x)(y ?y))
   =>
   (assert (exec (step ?s) (action guess) (x ?x) (y ?y)))
   (retract ?a)
   (pop-focus)
)