(defmodule DELIBERATION (import AGENT ?ALL) (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

;------------ TEMPLATE ---------------------------
(deftemplate unguess
	(slot x)
	(slot y)
)

;---------------- REGOLE ------------------------------------------


;---------------conoscenza--------------------------------------



;------------------------- inferenza + azione ---------------------------

; RICERCA CORAZZATA (NAVI DA 4)

; RICERCA INCROCIATORI (NAVI DA 3)

; Mette la guess a destra se ha già trovato un middle ed un left sicuri
(defrule find-guess-after-middle-right (declare (salience 90))
   (moves (guesses ?ng&:(> ?ng 0)))
   ?middle <- (cell-agent (x ?x) (y ?y) (content middle) )
   ?left <- (cell-agent (x ?x) (y ?yl&:(eq ?yl (- ?y 1))) (content left))
   ?cell <- (cell-agent (x ?x) (y ?cupd&:(eq ?cupd (+ ?y 1))) (content none) (status ?s&:(neq ?s guess)))
   ?col <- (k-per-col-agent (col ?cupd) (num ?nc))
   ?row <- (k-per-row-agent (row ?x) (num ?nr))
   =>
   (assert (action (name guess) (x ?x) (y ?cupd)))  
   (modify ?cell (status guess))
   (modify ?row (num (- ?nr 1))) ;decrem row
   (modify ?col (num (- ?nc 1))) ;decrem col
   (assert (update-score-row (row ?x) (num (- ?nr 1)) (y-to-upd 0)) )
   (assert (update-score-col (col ?cupd) (num (- ?nc 1)) (x-to-upd 0)) )
   (pop-focus)
)
; Mette la guess a sinistra se ha già trovato un middle ed un right sicuri
(defrule find-guess-after-middle-left (declare (salience 90))
   (moves (guesses ?ng&:(> ?ng 0)))
   ?middle <- (cell-agent (x ?x) (y ?y) (content middle) )
   ?left <- (cell-agent (x ?x) (y ?yr&:(eq ?yr (+ ?y 1))) (content right))
   ?cell <- (cell-agent (x ?x) (y ?cupd&:(eq ?cupd (- ?y 1))) (content none) (status ?s&:(neq ?s guess)))
   ?col <- (k-per-col-agent (col ?cupd) (num ?nc))
   ?row <- (k-per-row-agent (row ?x) (num ?nr))
   =>
   (assert (action (name guess) (x ?x) (y ?cupd)))  
   (modify ?cell (status guess))
   (modify ?row (num (- ?nr 1))) ;decrem row
   (modify ?col (num (- ?nc 1))) ;decrem col
   (assert (update-score-row (row ?x) (num (- ?nr 1)) (y-to-upd 0)) )
   (assert (update-score-col (col ?cupd) (num (- ?nc 1)) (x-to-upd 0)) )
   (pop-focus)
)
; RICERCA CACCIA (NAVI DA DUE)

; -------BOTTOM------- 
; Qui ci riferiamo al top come contenuto della fire eseguita nel passo precedente
; Esaminiamo la fire sul top con la sicurezza di aver bottom sotto
(defrule find-guess-to-bot-fire-driven(declare (salience 90))
   (moves (guesses ?ng&:(> ?ng 0)))
   ?fire <- (fire (x ?x) (y ?y))
   (k-cell (x ?x) (y ?y) (content top))
   ?cell <- (cell-agent (x ?bot-x&:(eq ?bot-x (+ ?x 1))) (y ?y) (content ?content&:(neq ?content water)) (status none))
   ?col <- (k-per-col-agent (col ?y) (num ?nc))
   ?row <- (k-per-row-agent (row ?bot-x) (num ?nr))
   (or
      ; caso indice colonna
      (k-per-col-agent (col ?y) (num ?nc&:(= ?nc 1)) )
      ; caso indice riga
      (k-per-row-agent (row ?bot-bot-x&:(eq ?bot-bot-x (+ ?bot-x 1))) (num ?bot-bot-nr&:(= ?bot-bot-nr 0)) )
      ; caso bordo 
      (not (k-per-row-agent (row ?bot-bot-x&:(eq ?bot-bot-x (+ ?bot-x 1))) ))
   )
   =>
   (assert (action (name guess) (x ?bot-x) (y ?y)))  
   (modify ?cell (content bot) (status guess))
   (modify ?row (num (- ?nr 1))) ;decrem row
   (modify ?col (num (- ?nc 1))) ;decrem col
   (assert (update-score-row (row ?bot-x) (num (- ?nr 1)) (y-to-upd 0)) )
   (assert (update-score-col (col ?y) (num (- ?nc 1)) (x-to-upd 0)) )
   (retract ?fire)
   (pop-focus)
)
;-----BOTTOM-ELSE-------
; Guess guidata dalla fire con incertezza del contenuto sulla cella inferiore
(defrule find-guess-fire-driven-else-bot(declare (salience 90))
   (moves (guesses ?ng&:(> ?ng 0)))
   ?fire <- (fire (x ?x) (y ?y))
   (k-cell (x ?x) (y ?y) (content top))
   ?cell <- (cell-agent (x ?bot-x&:(eq ?bot-x (+ ?x 1))) (y ?y) (content ?content&:(neq ?content water)) (status none))
   ?col <- (k-per-col-agent (col ?y) (num ?nc))
   ?row <- (k-per-row-agent (row ?bot-x) (num ?nr))
   =>
   (assert (action (name guess) (x ?bot-x) (y ?y)))  
   (modify ?cell (status guess))
   (modify ?row (num (- ?nr 1))) ;decrem row
   (modify ?col (num (- ?nc 1))) ;decrem col
   (assert (update-score-row (row ?bot-x) (num (- ?nr 1)) (y-to-upd 0)) )
   (assert (update-score-col (col ?y) (num (- ?nc 1)) (x-to-upd 0)) )
   (retract ?fire)
   (pop-focus)
)
; -------TOP------- 
(defrule find-guess-to-top-fire-driven(declare (salience 90))
   (moves (guesses ?ng&:(> ?ng 0)))
   ?fire <- (fire (x ?x) (y ?y))
   (k-cell (x ?x) (y ?y) (content bot))
   ?cell <- (cell-agent (x ?top-x&:(eq ?top-x (- ?x 1))) (y ?y) (content ?content&:(neq ?content water)) (status none))
   ?col <- (k-per-col-agent (col ?y) (num ?nc))
   ?row <- (k-per-row-agent (row ?top-x) (num ?nr))
   (or
      ; caso indice colonna
      (k-per-col-agent (col ?y) (num ?nc&:(= ?nc 1)) )
      ; caso indice riga
      (k-per-row-agent (row ?top-top-x&:(eq ?top-top-x (- ?top-x 1))) (num ?top-top-nr&:(= ?top-top-nr 0)) )
      ; caso bordo 
      (not (k-per-row-agent (row ?top-top-x&:(eq ?top-top-x (- ?top-x 1))) ))
   )
   =>
   (assert (action (name guess) (x ?top-x) (y ?y)))  
   (modify ?cell (content top) (status guess))
   (modify ?row (num (- ?nr 1))) ;decrem row
   (modify ?col (num (- ?nc 1))) ;decrem col
   (assert (update-score-row (row ?top-x) (num (- ?nr 1)) (y-to-upd 0)) )
   (assert (update-score-col (col ?y) (num (- ?nc 1)) (x-to-upd 0)) )
   (retract ?fire)
   (pop-focus)
)
;-----TOP-ELSE-------
; Guess guidata dalla fire con incertezza del contenuto sulla cella superior
(defrule find-guess-fire-driven-else-top(declare (salience 90))
   (moves (guesses ?ng&:(> ?ng 0)))
   ?fire <- (fire (x ?x) (y ?y))
   (k-cell (x ?x) (y ?y) (content bot))
   ?cell <- (cell-agent (x ?top-x&:(eq ?top-x (- ?x 1))) (y ?y) (content ?content&:(neq ?content water)) (status none))
   ?col <- (k-per-col-agent (col ?y) (num ?nc))
   ?row <- (k-per-row-agent (row ?top-x) (num ?nr))
   =>
   (assert (action (name guess) (x ?top-x) (y ?y)))  
   (modify ?cell  (status guess))
   (modify ?row (num (- ?nr 1))) ;decrem row
   (assert (update-score-row (row ?top-x) (num (- ?nr 1)) (y-to-upd 0)) )
   (assert (update-score-col (col ?y) (num (- ?nc 1)) (x-to-upd 0)) )
   (retract ?fire)
   (pop-focus)
)

; -------LEFT------- 
(defrule find-guess-to-left-fire-driven(declare (salience 90))
   ?fire <- (fire (x ?x) (y ?y))
   (k-cell (x ?x) (y ?y) (content right))
   ?cell <- (cell-agent (x ?x) (y ?left-y&:(eq ?left-y (- ?y 1))) (content ?content&:(neq ?content water)) (status none))
   ?col <- (k-per-col-agent (col ?left-y) (num ?nc))
   ?row <- (k-per-row-agent (row ?x) (num ?nr))
   (or
      ; caso indice riga
      ( k-per-row-agent (row ?x) (num ?nr&:(= ?nr 1))  )
      ; caso indice colonna
      (k-per-col-agent (col ?left-left-y&:(eq ?left-left-y (- ?left-y 1))) (num ?left-left-nc&:(= ?left-left-nc 0)) )
      ; caso bordo 
      (not (k-per-col-agent (col ?left-left-y&:(eq ?left-left-y (- ?y 2))) ))
   )
   =>
   (assert (action (name guess) (x ?x) (y ?left-y)))  
   (modify ?cell (content left) (status guess))
   (modify ?row (num (- ?nr 1))) ;decrem row
   (modify ?col (num (- ?nc 1))) ;decrem col
   (assert (update-score-row (row ?x) (num (- ?nr 1)) (y-to-upd 0)) )
   (assert (update-score-col (col ?left-y) (num (- ?nc 1)) (x-to-upd 0)) )
   (retract ?fire)
   (pop-focus)
)
;-----LEFT-ELSE-------
; Guess guidata dalla fire con incertezza del contenuto sulla cella superior
(defrule find-guess-fire-driven-else-left(declare (salience 90))
   (moves (guesses ?ng&:(> ?ng 0)))
   ?fire <- (fire (x ?x) (y ?y))
   (k-cell (x ?x) (y ?y) (content right))
   ?cell <- (cell-agent (x ?x) (y ?left-y&:(eq ?left-y (- ?y 1))) (content ?content&:(neq ?content water)) (status none))
   ?col <- (k-per-col-agent (col ?left-y) (num ?nc))
   ?row <- (k-per-row-agent (row ?x) (num ?nr))
   =>
   (assert (action (name guess) (x ?x) (y ?left-y)))  
   (modify ?cell (status guess))
   (modify ?row (num (- ?nr 1))) ;decrem row
   (modify ?col (num (- ?nc 1))) ;decrem col
   (assert (update-score-row (row ?x) (num (- ?nr 1)) (y-to-upd 0)) )
   (assert (update-score-col (col ?left-y) (num (- ?nc 1)) (x-to-upd 0)) )
   (retract ?fire)
   (pop-focus)
)
; -------RIGHT------- 
(defrule find-guess-to-right-fire-driven(declare (salience 90))
   (moves (guesses ?ng&:(> ?ng 0)))
   ?fire <- (fire (x ?x) (y ?y))
   (k-cell (x ?x) (y ?y) (content left))
   ?cell <- (cell-agent (x ?x) (y ?right-y&:(eq ?right-y (+ ?y 1))) (content ?content&:(neq ?content water)) (status none))
   ?col <- (k-per-col-agent (col ?right-y) (num ?nc))
   ?row <- (k-per-row-agent (row ?x) (num ?nr))
   (or
      ; caso indice riga
      (k-per-row-agent (row ?x) (num ?nc&:(= ?nr 1)) )
      ; caso indice colonna
      (k-per-col-agent (col ?right-right-y&:(eq ?right-right-y (- ?right-y 1))) (num ?right-right-nc&:(= ?right-right-nc 0)) )
      ; caso bordo 
      (not (k-per-col-agent (col ?right-right-y&:(eq ?right-right-y (- ?right-y 1))) ))
   )
   =>
   (assert (action (name guess) (x ?x) (y ?right-y)))  
   (modify ?cell (content right) (status guess))
   (modify ?row (num (- ?nr 1))) ;decrem row
   (modify ?col (num (- ?nc 1))) ;decrem col
   (assert (update-score-row (row ?x) (num (- ?nr 1)) (y-to-upd 0)) )
   (assert (update-score-col (col ?right-y) (num (- ?nc 1)) (x-to-upd 0)) )
   (retract ?fire)
   (pop-focus)
)
;-----RIGHT-ELSE-------
; Guess guidata dalla fire con incertezza del contenuto sulla cella superior
(defrule find-guess-fire-driven-else-right(declare (salience 90))
   (moves (guesses ?ng&:(> ?ng 0)))
   ?fire <- (fire (x ?x) (y ?y))
   (k-cell (x ?x) (y ?y) (content left))
   ?cell <- (cell-agent (x ?x) (y ?right-y&:(eq ?right-y (+ ?y 1))) (content ?content&:(neq ?content water)) (status none))
   ?col <- (k-per-col-agent (col ?right-y) (num ?nc))
   ?row <- (k-per-row-agent (row ?x) (num ?nr))
   =>
   (assert (action (name guess) (x ?x) (y ?right-y)))  
   (modify ?cell (status guess))
   (modify ?row (num (- ?nr 1))) ;decrem row
   (modify ?col (num (- ?nc 1))) ;decrem col
   (assert (update-score-row (row ?x) (num (- ?nr 1)) (y-to-upd 0)) )
   (assert (update-score-col (col ?right-y) (num (- ?nc 1)) (x-to-upd 0)) )
   (retract ?fire)
   (pop-focus)
)

; RICERCA SOTTOMARINI (NAVI DA 1)

;-----------------------------------------------------------------------

;   Se il contenuto di una cella nota è middle, allora la cella sopra sarà top
;   se quella ancora sopra contiene acqua oppure non esiste(bordo)
(defrule find-top-for-middle (declare (salience 80)) 
   (moves (guesses ?ng&:(> ?ng 0)))
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
   (moves (guesses ?ng&:(> ?ng 0)))
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

; prima fire se non ho conoscnza
(defrule first-step-fire (declare (salience 95))
   (moves (fires ?nf&:(> ?nf 0)))
   (not (k-cell (x ?x) (y ?y)))
   ?cell-to-upd <-(cell-agent (x ?x) (y ?y) (status none) (score ?s))   
   (not (cell-agent (x ?x1) (y ?y2) (status none) (score ?s1&:(> ?s1 ?s))))
   =>
   (assert (action (name fire) (x ?x) (y ?y)))  
   (pop-focus)
)
; finchè ho fire le faccio
(defrule find-cell-fire (declare (salience 70)) 
   (moves (fires ?ng&:(> ?ng 0)))
   ?cell-to-upd <-(cell-agent (x ?x) (y ?y) (status none) (score ?s))   
   (not (cell-agent (x ?x1) (y ?y2) (status none) (score ?s1&:(> ?s1 ?s))))
   =>
   (assert (action (name fire) (x ?x) (y ?y)))
   (pop-focus)
)


;---------------------END-FIRE------------------------------------------


(defrule find-cell-guess (declare (salience 65)) 
   (moves (guesses ?ng&:(> ?ng 0)))
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

; ( defrule fine (declare (salience 60))
;    (moves (guesses ?ng&:(> ?ng 0)))
; =>
;    (assert (action (name guess) (x 9) (y 9)))  
;    (pop-focus)
; )

; (defrule unguess (declare (salience 55))
;    (moves (guesses ?ng&:(eq ?ng 0)))
;    ?cell-to-upd <-(cell-agent (x ?x) (y ?y) (status guess) (content none) (score ?s&:(neq ?s -1)))   
;    ?row <- (k-per-row-agent (row ?x) (num ?nr) )
;    ?col <- (k-per-col-agent (col ?y) (num ?nc) )
; =>
;    (assert (action (name unguess) (x ?x) (y ?y)))  
;    (modify ?cell-to-upd (status unguess))
;    (modify ?row (num (+ ?nr 1))) 
;    (modify ?col (num (+ ?nc 1))) 
;    (assert (update-score-row (row ?x) (num (+ ?nr 1)) (y-to-upd 0)) )
;    (assert (update-score-col (col ?y) (num (+ ?nc 1)) (x-to-upd 0)) )
;    (pop-focus)
; )














