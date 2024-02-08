(defmodule INIT (import AGENT ?ALL) (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))


;------------ REGOLE -----------------------------

; Inizializzazione strutture di ausilio
(defrule init-cells (declare (salience 100)) 
	(status (step ?s)(currently running))
	(k-per-row (row ?r) (num ?n))
	(k-per-col (col ?c) (num ?n1))
=> 
	(assert (cell-agent (x ?r) (y ?c) (status none)))
)

(defrule init-rows (declare (salience 100)) 
	(status (step ?s)(currently running))
	(k-per-row (row ?r) (num ?rnum))
=> 
	(assert (k-per-row-agent (row ?r) (num ?rnum)))
)

(defrule init-cols (declare (salience 100)) 
	(status (step ?s)(currently running))
	(k-per-col (col ?c) (num ?cnum))
=> 
	(assert (k-per-col-agent (col ?c) (num ?cnum)))
)

;La regola serve per contrassegnare, all'inizio, tutte le caselle
;   in cui si hanno contenuti sicuri. Questa regola si attiva 
;   nel momento in cui viene effettuata una ricerca con osservazioni.
;   Scatta perciò quando vengono asseriti fatti k-cell, da cui viene preso
;   il contenuto. Viene poi effettuato l'aggiornamento dei valori k-per-row e col
(defrule update-cell-boat (declare (salience 95))
    (status (step ?s)(currently running))
    ?k-cell <- (k-cell (x ?x) (y ?y) (content ?content&:(neq ?content water)))
    ?cell-to-upd <- (cell-agent (x ?x) (y ?y) (content none) (status none))
    ?row <- (k-per-row-agent (row ?x) (num ?nr) )
    ?col <- (k-per-col-agent (col ?y) (num ?nc) )
=>
    ;(modify ?cell-to-upd (content ?content) (status fire)) 
    (modify ?cell-to-upd (content ?content) (status know)) 
    (modify ?row(num (- ?nr 1) )) ;decrem row
    (modify ?col(num (- ?nc 1))) ;decrem col 
)
(defrule update-cell-water (declare (salience 95))
    (status (step ?s)(currently running))
    ?k-cell <- (k-cell (x ?x) (y ?y) (content ?content&:(eq ?content water)))
    ?cell-to-upd <- (cell-agent (x ?x) (y ?y) (content none) (status none))

=>
    ;(modify ?cell-to-upd (content ?content) (status fire)) 
    (modify ?cell-to-upd (content ?content) (status know)) 
)

;La regola serve per contrassegnare, all'inizio, tutte le caselle
;   in cui la moltiplicazione tra l'indice di possibili navi nella riga
;   e l'indice nella colonna sia uguale a zero, ossia quando sicuramente
;   non potrà esserci una nave ma solo acqua
(defrule add-water-cell (declare (salience 90))
    (status (step ?s)(currently running))
    (k-per-row-agent (row ?r) (num ?rnum))
    (k-per-col-agent (col ?c) (num ?cnum)) 
    ?cell-to-upd <- (cell-agent (x ?r) (y ?c) (content none) (status none))
    (test (eq (* ?rnum ?cnum) 0))
    =>
    ; NOTA: ad ora, è stato messo come status fire. 
    ;       Potrebbe essere modificarto in base ai ragionamenti.
    ; (modify ?cell-to-upd (content water) (status fire)) 
    (modify ?cell-to-upd (content water) (status exclusion))  
 
)

; (defrule fill-sub-neighbors-top(declare (salience 85)) 
;     (status (step ?s)(currently running))
;     (k-cell (x ?x) (y ?y) (content sub))
;     (cell-agent (x ?x) (y ?y) (content sub) (status know))
;     (not (cell-agent (x ?x) (y (+ ?y 1)) (content water) (status ?status)))
;     ?cell-top <- (cell-agent (x ?x) (y (+ ?y 1)) (content ?content) (status ?status))
;     =>
;     (modify ?cell-top (content water) (status know) )
; )

; (defrule fill-sub-neighbors-bot(declare (salience 85)) 
;     (status (step ?s)(currently running))
;     (k-cell (x ?x) (y ?y) (content sub))
;     (cell-agent (x ?x) (y ?y) (content sub) (status know))
;     (not (cell-agent (x ?x) (y (- ?y 1)) (content water) (status ?status)))
;     ?cell-bot <- (cell-agent (x ?x) (y (- ?y 1)) (content ?content) (status ?status))
;     =>
;     (modify ?cell-bot (content water) (status know) )
; )

; (defrule fill-sub-neighbors-left(declare (salience 85)) 
;     (status (step ?s)(currently running))
;     (k-cell (x ?x) (y ?y) (content sub))
;     (cell-agent (x ?x) (y ?y) (content sub) (status know))
;     (not (cell-agent (x (- ?x 1)) (y ?y) (content water) (status ?status)))
;     ?cell-left <- (cell-agent (x (- ?x 1)) (y ?y) (content ?content) (status ?status))
;     =>
;     (modify ?cell-left (content water) (status know) )
; )

(defrule fill-neighbor-bot(declare (salience 85)) 
    (status (step ?s)(currently running))
    (cell-agent (x ?x) (y ?y) (content bot | sub | left | right) (status know))
    ;prendo la cella sotto se il contenuto è diverso da water
    ?cell-bot <- (cell-agent (x ?newx&:(eq ?newx (+ 1 ?x))) (y ?y) (content ?content&:(neq ?content water)) (status ?status))
    =>
    (modify ?cell-bot (content water) (status know) )
)

(defrule fill-neighbor-top(declare (salience 85)) 
    (status (step ?s)(currently running))
    (cell-agent (x ?x) (y ?y) (content top | sub | left | right) (status know))
    ;prendo la cella sopra se il contenuto è diverso da water
    ?cell-top <- (cell-agent (x ?newx&:(eq ?newx (- 1 ?x))) (y ?y) (content ?content&:(neq ?content water)) (status ?status))
    =>
    (modify ?cell-top (content water) (status know) )
)

(defrule fill-neighbor-right(declare (salience 85)) 
    (status (step ?s)(currently running))
    (cell-agent (x ?x) (y ?y) (content top | sub | bot | right) (status know))
    ;prendo la cella a dx se il contenuto è diverso da water
    ?cell-right <- (cell-agent (x ?x ) (y ?newy&:(eq ?newy (+ 1 ?y))) (content ?content&:(neq ?content water)) (status ?status))
    =>
    (modify ?cell-right (content water) (status know) )
)

(defrule fill-neighbor-left(declare (salience 85)) 
    (status (step ?s)(currently running))
    (cell-agent (x ?x) (y ?y) (content top | sub | bot | left) (status know))
    ;prendo la cella a sx se il contenuto è diverso da water
    ?cell-left <- (cell-agent (x ?x ) (y ?newy&:(eq ?newy (- 1 ?y))) (content ?content&:(neq ?content water)) (status ?status))
    =>
    (modify ?cell-left (content water) (status know) )
)



(defrule finish-init(declare (salience 80)) 
    (status (step ?s)(currently running))
    =>
    (pop-focus)
)




