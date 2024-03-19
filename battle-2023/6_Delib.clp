(defmodule DELIBERATION (import AGENT ?ALL) (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

;------------ TEMPLATE ---------------------------
(deftemplate unguess
	(slot x)
	(slot y)
)

;---------------- REGOLE ------------------------------------------


;---------------conoscenza--------------------------------------



;------------------------- inferenza + azione ---------------------------



;-----------------------------------------------------------------------

;   Se il contenuto di una cella nota è middle, allora la cella sopra sarà top
;   se quella ancora sopra contiene acqua oppure non esiste(bordo)
(defrule find-top-for-middle (declare (salience 80)) 
   ?cell-middle <- (cell-agent (x ?x) (y ?y) (content middle) (status know))
   ?cell-top-on-middle <- (cell-agent (x ?top-x&:(eq ?top-x (- ?x 1))) (y ?y) (content none))
   (not (cell-agent (x ?x) (y ?left-y&:(eq ?left-y (- ?y 1))) (content none)))
   (not (cell-agent (x ?x) (y ?right-y&:(eq ?right-y (+ ?y 1))) (content none)))
   ?row <- (k-per-row-agent (row ?top-x) (num ?nr&:(> ?nr 0)) )
   ?col <- (k-per-col-agent (col ?y) (num ?nc&:(> ?nc 0)) )
   (or
      (not (cell-agent (x ?tt-x&:(eq ?tt-x (- ?top-x 1))) (y ?y)))
      (cell-agent (x ?tt-x&:(eq ?tt-x (- ?top-x 1))) (y ?y) (content water))
      (k-per-col-agent (col ?y) (num ?nc&:(= ?nc 1)) )
   )
   =>
   (assert (action (name guess) (x ?top-x) (y ?y)))  
   (modify ?cell-top-on-middle (content top) (status guess))
   (modify ?row (num (- ?nr 1))) ;decrem row
   (modify ?col (num (- ?nc 1))) ;decrem col
   (assert (update-score-row (row ?top-x) (num (- ?nr 1)) (y-to-upd 0)) )
   (assert (update-score-col (col ?y) (num (- ?nc 1)) (x-to-upd 0)) )
   (pop-focus)
)

;   Se il contenuto di una cella nota è middle, allora la cella sottostante sarà bottom
;   se quella ancora sotto contiene acqua oppure non esiste(bordo)
(defrule find-bot-for-middle (declare (salience 80)) 
   ?cell-middle <- (cell-agent (x ?x) (y ?y) (content middle) (status know))
   ?cell-bot-on-middle <- (cell-agent (x ?bot-x&:(eq ?bot-x (+ ?x 1))) (y ?y) (content none))
   (not (cell-agent (x ?x) (y ?left-y&:(eq ?left-y (- ?y 1))) (content none)))
   (not (cell-agent (x ?x) (y ?right-y&:(eq ?right-y (+ ?y 1))) (content none)))
   ?row <- (k-per-row-agent (row ?bot-x) (num ?nr&:(> ?nr 0)) )
   ?col <- (k-per-col-agent (col ?y) (num ?nc&:(> ?nc 0)) )
   (or
      (not (cell-agent (x ?tt-x&:(eq ?tt-x (+ ?bot-x 1))) (y ?y)))
      (cell-agent (x ?tt-x&:(eq ?tt-x (+ ?bot-x 1))) (y ?y) (content water))
      (k-per-col-agent (col ?y) (num ?nc&:(= ?nc 1)) )
   )
   =>
   (assert (action (name guess) (x ?bot-x) (y ?y)))  
   (modify ?cell-bot-on-middle (content bot) (status guess))
   (modify ?row (num (- ?nr 1))) ;decrem row
   (modify ?col (num (- ?nc 1))) ;decrem col
   (assert (update-score-row (row ?bot-x) (num (- ?nr 1)) (y-to-upd 0)) )
   (assert (update-score-col (col ?y) (num (- ?nc 1)) (x-to-upd 0)) )
   (pop-focus)
)

;---------------------scelta azione---------------------------------

;---------------------FIRE------------------------------------------

(defrule first-step-fire (declare (salience 95))
   (not (k-cell (x ?x) (y ?y)))
   ?cell-to-upd <-(cell-agent (x ?x) (y ?y) (status none) (score ?s))   
   (not (cell-agent (x ?x1) (y ?y2) (status none) (score ?s1&:(> ?s1 ?s))))
   =>
   (assert (action (name fire) (x ?x) (y ?y)))  
   (pop-focus)
)

; (defrule do-fire (declare (salience 95)) 
;    ?a <- (unguess (x ?x) (y ?y))
;    ?cell-to-upd <-(cell-agent (x ?x) (y ?y))   
;    ?row <- (k-per-row-agent (row ?x) (num ?nr) )
;    ?col <- (k-per-col-agent (col ?y) (num ?nc) )
;    =>
;    (retract ?a)
;    (assert (action (name fire) (x ?x) (y ?y)))  
;    (modify ?cell-to-upd (status fire))
;    (modify ?row (num (- ?nr 1))) 
;    (modify ?col (num (- ?nc 1))) 
;    (pop-focus)

; )
;---------------------END-FIRE------------------------------------------


(defrule find-cell-guess (declare (salience 70)) 
   ;(moves (guesses ?ng&:(> ?ng 0)))
   ?cell-to-upd <-(cell-agent (x ?x) (y ?y) (status none) (score ?s))   
   (not (cell-agent (x ?x1) (y ?y2) (status none) (score ?s1&:(> ?s1 ?s))))
   ?row <- (k-per-row-agent (row ?x) (num ?nr&:(> ?nr 0)) )
   ?col <- (k-per-col-agent (col ?y) (num ?nc&:(> ?nc 0)) )
   =>
   (assert (action (name guess) (x ?x) (y ?y)))  
   (modify ?cell-to-upd (status guess))
   (modify ?row (num (- ?nr 1))) ;decrem row
   (modify ?col (num (- ?nc 1))) ;decrem col
   (assert (update-score-row (row ?x) (num (- ?nr 1)) (y-to-upd 0)) )
   (assert (update-score-col (col ?y) (num (- ?nc 1)) (x-to-upd 0)) )
   (pop-focus)
)

;   Faccio l'unguess delle celle con contenuto none per poi fare le fire
; (defrule find-cell-unguess (declare (salience 60)) 
;    ?cell-to-upd <-(cell-agent (x ?x) (y ?y) (status guess) (score ?s))  
;    (not (cell-agent (x ?x1) (y ?y2) (content none) (status guess) (score ?s1&:(> ?s1 ?s))))
;    ?row <- (k-per-row-agent (row ?x) (num ?nr) )
;    ?col <- (k-per-col-agent (col ?y) (num ?nc) )
;    =>
;    (assert (unguess (x ?x) (y ?y) ))
;    (assert (action (name unguess) (x ?x) (y ?y)))  
;    (modify ?cell-to-upd (status unguess))
;    (modify ?row (num (+ ?nr 1))) 
;    (modify ?col (num (+ ?nc 1))) 
;    (pop-focus)
; )







; (defrule find-max-number-row (declare (salience 100)) 
; (moves (guesses ?ng&:(> ?ng 0)))
;    (k-per-row-agent (row ?r1) (num ?n1))
;    (not (k-per-row-agent (row ?r2) (num ?n2&:(> ?n2 ?n1))))
;    =>
;    (printout t "La riga con il numero più grande è: " ?r1 " con " ?n1 crlf)
; )

; (defrule find-max-number-col (declare (salience 90)) 
;    (moves (guesses ?ng&:(> ?ng 0)))
;    (k-per-col-agent (col ?c1) (num ?n3))
;    (not (k-per-col-agent (col ?c2) (num ?n4&:(> ?n4 ?n3))))
;    =>
;    (printout t "La colonna con il numero più grande è: " ?c1 " con " ?n3 crlf)
; )




; (defrule find-other-cell 
; (moves (guesses ?ng&:(> ?ng 0)))
;    (k-per-row-agent (row ?r1) (num ?n1) )
;    (not (k-per-row-agent (row ?r2) (num ?n2&:(> ?n2 ?n1))))
;    ?row <- (k-per-row-agent (row ?r2) (num ?n2) )
;    =>
;    (printout t "La riga con il secondo numero più grande è: " ?r2 " con " ?n2 crlf)

; )


   ; ?row <- (k-per-row-agent (row ?r1) (num ?n1) )
   ; (not (k-per-row-agent (row ?r2) (num ?n2&:(> ?n2 ?n1))))
   ; ?col <- (k-per-col-agent (col ?c1) (num ?n3) )
   ; (not (k-per-col-agent (col ?c2) (num ?n4&:(> ?n4 ?n3))))
   ; ?cell-to-upd <-(cell-agent (x ?r1) (y ?c1) (status none))




; (defrule prova 
;   ?f <- (cell-agent (x 0)(y 0))
; =>
;   (modify ?f (status guess))
;   (pop-focus)
; )