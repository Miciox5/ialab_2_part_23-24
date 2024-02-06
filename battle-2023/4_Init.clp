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

;La regola serve per contrassegnare, all'inizio, tutte le caselle
;   in cui si hanno contenuti sicuri. Questa regola si attiva 
;   nel momento in cui viene effettuata una ricerca con osservazioni.
;   Scatta perciò quando vengono asseriti fatti k-cell, da cui viene preso
;   il contenuto.
(defrule update-cell-for-k-cell (declare (salience 90))
    (status (step ?s)(currently running))
    ?k-cell <- (k-cell (x ?x) (y ?y) (content ?content))
    ?cell-to-upd <- (cell-agent (x ?x) (y ?y) (content none) (status none))
=>
    ;(modify ?cell-to-upd (content ?content) (status fire)) 
    (modify ?cell-to-upd (content ?content) (status know)) 
)

(defrule finish-init(declare (salience 80)) 
    (status (step ?s)(currently running))
    =>
    (pop-focus)
)
