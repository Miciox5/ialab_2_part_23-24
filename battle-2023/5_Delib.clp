(defmodule DELIBERATION (import AGENT ?ALL) (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

;------------ REGOLE -----------------------------


(defrule find-max-number-row (declare (salience 100)) 
   (k-per-row-agent (row ?r1) (num ?n1))
   (not (k-per-row-agent (row ?r2) (num ?n2&:(> ?n2 ?n1))))
   =>
   (printout t "La riga con il numero più grande è: " ?r1 " con " ?n1 crlf)
)

(defrule find-max-number-col (declare (salience 90)) 
   (k-per-col-agent (col ?c1) (num ?n3))
    (not (k-per-col-agent (col ?c2) (num ?n4&:(> ?n4 ?n3))))
   =>
   (printout t "La colonna con il numero più grande è: " ?c1 " con " ?n3 crlf)
)
(defrule find-max-number-col1 (declare (salience 80)) 
   =>
   (printout t "entro" crlf)
)

(defrule find-cell-guess (declare (salience 70)) 
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 0)))
    (k-per-row-agent (row ?r1) (num ?n1))
    (not (k-per-row-agent (row ?r2) (num ?n2&:(> ?n2 ?n1))))
    (k-per-col-agent (col ?c1) (num ?n3))
    (not (k-per-col-agent (col ?c2) (num ?n4&:(> ?n4 ?n3))))
    ?cell-to-upd <-(cell-agent (x ?r1) (y ?c1) (status none))
    ?row <- (k-per-row-agent (row ?r1) (num ?n1) )
    ?col <- (k-per-col-agent (col ?c1) (num ?n3) )
   =>
   (printout t "La riga con il numero più grande è: " ?r1 " con " ?n1 crlf)
   (printout t "La colonna con il numero più grande è: " ?c1 " con " ?n3 crlf)
   (assert (action(name guess)(x ?r1)(y ?c1)))
   (modify ?cell-to-upd(status guess ))
   (modify ?row(num (- ?n1 1) )) ;decrem row
   (modify ?col(num (- ?n3 1))) ;decrem col 
   (pop-focus)
)



; (defrule prova 
;   ?f <- (cell-agent (x 0)(y 0))
; =>
;   (modify ?f (status guess))
;   (pop-focus)
; )