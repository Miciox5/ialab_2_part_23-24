(defmodule INIT (import AGENT ?ALL) (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

;------------ TEMPLATE ---------------------------


;------------ REGOLE -----------------------------

; Inizializzazione strutture di ausilio
(defrule init-cells (declare (salience 100)) 
	(status (step 0)(currently running))
	(k-per-row (row ?r) (num ?n))
	(k-per-col (col ?c) (num ?n1))
=> 
	(assert (cell-agent (x ?r) (y ?c) (status none) (score (* ?n ?n1)) (original-score (* ?n ?n1))))
)

(defrule init-rows (declare (salience 100)) 
	(status (step 0)(currently running))
	(k-per-row (row ?r) (num ?rnum))
=> 
	(assert (k-per-row-agent (row ?r) (num ?rnum)))
)

(defrule init-cols (declare (salience 100)) 
	(status (step 0)(currently running))
	(k-per-col (col ?c) (num ?cnum))
=> 
	(assert (k-per-col-agent (col ?c) (num ?cnum)))
)

;   La regola serve per contrassegnare, tutte le caselle
;   in cui si hanno contenuti sicuri. Questa regola si attiva 
;   nel momento in cui viene effettuata una ricerca con osservazioni.
;   Scatta perciò quando vengono asseriti fatti k-cell, da cui viene preso
;   il contenuto. Viene poi effettuato l'aggiornamento dei valori k-per-row, col e score
; (defrule update-cell-boat (declare (salience 95))
;     (status (step 0)(currently running))
;     ?k-cell <- (k-cell (x ?x) (y ?y) (content ?content&:(neq ?content water)))
;     ?cell-to-upd <- (cell-agent (x ?x) (y ?y) (content none) (status none))
;     ?row <- (k-per-row-agent (row ?x) (num ?nr) )
;     ?col <- (k-per-col-agent (col ?y) (num ?nc) )
; =>
;     (modify ?cell-to-upd (content ?content) (status know)) 
;     (modify ?row(num (- ?nr 1) )) ;decrem row
;     (modify ?col(num (- ?nc 1))) ;decrem col 
;     (assert (update-score-col (col ?y) (num (- ?nc 1)) (x-to-upd 0) ))
;     (assert (update-score-row (row ?y) (num (- ?nr 1)) (y-to-upd 0) ))
; )
;   Questa regola si attiva 
;   nel momento in cui viene effettuata una ricerca con osservazioni.
;   Scatta perciò quando vengono asseriti fatti k-cell, da cui viene preso
;   il contenuto water ma non si aggiornano i valori k-per-row e col
(defrule update-cell-water (declare (salience 95))
    (status (step 0)(currently running))
    ?k-cell <- (k-cell (x ?x) (y ?y) (content ?content&:(eq ?content water)))
    ?cell-to-upd <- (cell-agent (x ?x) (y ?y) (content none) (status none))
=>
    (modify ?cell-to-upd (content ?content) (status know) (score 0)) 
)

;   La regola serve per contrassegnare, all'inizio, tutte le caselle
;   in cui la moltiplicazione tra l'indice di possibili navi nella riga
;   e l'indice nella colonna sia uguale a zero, ossia quando sicuramente
;   non potrà esserci una nave ma solo acqua
(defrule add-water-cell (declare (salience 90))
    (status (step 0)(currently running))
    (k-per-row-agent (row ?r) (num ?rnum))
    (k-per-col-agent (col ?c) (num ?cnum)) 
    ?cell-to-upd <- (cell-agent (x ?r) (y ?c) (content none) (status none))
    (test (eq (* ?rnum ?cnum) 0))
    =>
    (modify ?cell-to-upd (content water) (status know) (score 0)) 
)

;   Regole per aggiungere acqua ai lati dei pezzi di nave

(defrule fill-neighbor-bot(declare (salience 85)) 
    (status (step 0)(currently running))
    (cell-agent (x ?x) (y ?y) (content bot | sub | left | right) (status know))
    ;prendo la cella sotto se il contenuto è diverso da water
    ?cell-bot <- (cell-agent (x ?newx&:(eq ?newx (+ 1 ?x))) (y ?y) (content ?content&:(neq ?content water)) (status ?status))
    =>
    (modify ?cell-bot (content water) (status know) (score 0))
)

(defrule fill-neighbor-top(declare (salience 85)) 
    (status (step 0)(currently running))
    (cell-agent (x ?x) (y ?y) (content top | sub | left | right) (status know))
    ;prendo la cella sopra se il contenuto è diverso da water
    ?cell-top <- (cell-agent (x ?newx&:(eq ?newx (- 1 ?x))) (y ?y) (content ?content&:(neq ?content water)) (status ?status))
    =>
    (modify ?cell-top (content water) (status know) (score 0))
)

(defrule fill-neighbor-right(declare (salience 85)) 
    (status (step 0)(currently running))
    (cell-agent (x ?x) (y ?y) (content top | sub | bot | right) (status know))
    ;prendo la cella a dx se il contenuto è diverso da water
    ?cell-right <- (cell-agent (x ?x ) (y ?newy&:(eq ?newy (+ 1 ?y))) (content ?content&:(neq ?content water)) (status ?status))
    =>
    (modify ?cell-right (content water) (status know) (score 0))
)

(defrule fill-neighbor-left(declare (salience 85)) 
    (status (step 0)(currently running))
    (cell-agent (x ?x) (y ?y) (content top | sub | bot | left) (status know))
    ;prendo la cella a sx se il contenuto è diverso da water
    ?cell-left <- (cell-agent (x ?x ) (y ?newy&:(eq ?newy (- 1 ?y))) (content ?content&:(neq ?content water)) (status ?status))
    =>
    (modify ?cell-left (content water) (status know) (score 0))
)

;  Update score di tutte le colonne di una riga
(defrule update-scores-rows (declare (salience 75))
    ?a <- (update-score-row (row ?row) (num ?nr) (y-to-upd ?y))
   ?cell-to-upd <- (cell-agent (x ?row) (y ?y) (status ?s&:(neq ?s know)))
   (k-per-col-agent (col ?y) (num ?nc))
   =>
   (retract ?a)
   (assert (update-score-row (row ?row) (num ?nr) (y-to-upd (+ ?y 1))))
   (modify ?cell-to-upd (score (* ?nr ?nc)))
)
;  Update score di tutte le righe di una colonna
(defrule update-scores-cols (declare (salience 70))
    ?a <- (update-score-col (col ?y) (num ?nc) (x-to-upd ?x)  )
   ?cell-to-upd <- (cell-agent (x ?x) (y ?y) (status ?s&:(neq ?s know)))
   (k-per-row-agent (row ?x) (num ?nr))
   =>
   (assert (update-score-col (col ?y) (num ?nc) (x-to-upd (+ ?x 1))))
   (retract ?a)
   (modify ?cell-to-upd (score (* ?nr ?nc)))
)

(defrule finish-init-row ( declare (salience 60) ) 
    (status (step 0)(currently running))
    ?factr <- (update-score-row (row ?r) (num ?n) (y-to-upd ?y) )
    =>
    (retract ?factr)
)
(defrule finish-init-col ( declare (salience 60) ) 
    (status (step 0)(currently running))
    ?factc <- (update-score-col (col ?col) (num ?nc) (x-to-upd ?x)) 
    =>
    (retract ?factc)

)
