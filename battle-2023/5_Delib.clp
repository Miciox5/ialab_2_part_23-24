(defmodule DELIBERATION (import AGENT ?ALL) (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

;------------ REGOLE -----------------------------


(defrule find-max-number-row (declare (salience 100)) 
   (k-per-row-agent (row ?r1) (num ?n1))
   (not (k-per-row-agent (row ?r2) (num ?n2&:(> ?n2 ?n1))))
   =>
   (printout t "La riga con il numero più grande è: " ?r1 crlf)
)

(defrule find-max-number-col (declare (salience 90)) 
   (k-per-col-agent (col ?c1) (num ?n1))
   (not (k-per-col-agent (col ?c2) (num ?n2&:(> ?n2 ?n1))))
   =>
   (printout t "La colonna con il numero più grande è: " ?c1 crlf)
   (pop-focus)
)



; (defrule prova 
;   ?f <- (cell-agent (x 0)(y 0))
; =>
;   (modify ?f (status guess))
;   (pop-focus)
; )