(defmodule UPDATE_KC (import AGENT ?ALL) (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))


;------------ TEMPLATE ---------------------------


;---------------- REGOLE ------------------------------------------

(defrule copy-k-cell (declare (salience 150))
   ?k-cell <- (k-cell (x ?x) (y ?y) (content ?content&:(neq ?content water)))
   (not (cell-agent (x ?x) (y ?y) (status know | fire)))  ;lasciare solo fire??
   ?cell-to-upd <- (cell-agent (x ?x) (y ?y))
    ?row <- (k-per-row-agent (row ?x) (num ?nr) )
    ?col <- (k-per-col-agent (col ?y) (num ?nc) )
=>
   (modify ?cell-to-upd (content ?content) (status fire)) 
   (modify ?row (num (- ?nr 1))) ;decrem row
   (modify ?col (num (- ?nc 1))) ;decrem col
   (assert (update-score-row (row ?x) (num (- ?nr 1)) (y-to-upd 0)) )
   (assert (update-score-col (col ?y) (num (- ?nc 1)) (x-to-upd 0)) )
)

(defrule copy-k-cell-water (declare (salience 150))
   ?k-cell <- (k-cell (x ?x) (y ?y) (content water))
   (not (cell-agent (x ?x) (y ?y) (status fire)))
   ?cell-to-upd <- (cell-agent (x ?x) (y ?y))
=>
   (modify ?cell-to-upd (content water) (status fire) (score 0)) 
)


(defrule update-scores-rows (declare (salience 100))
   ?a <- (update-score-col (col ?col) (num ?nc) (x-to-upd ?x))
   ?cell-to-upd <- (cell-agent (x ?x) (y ?col) )
   (k-per-row-agent (row ?x) (num ?nr))
   =>
    (modify ?cell-to-upd (score (* ?nr ?nc)))
    (retract ?a)
    (assert (update-score-col (col ?col) (num ?nc) (x-to-upd (+ ?x 1))))
)
(defrule update-scores-cols (declare (salience 100))
   ?a <- (update-score-row (row ?row) (num ?nr) (y-to-upd ?y))
   ?cell-to-upd <- (cell-agent (x ?row) (y ?y))
   (k-per-col-agent (col ?y) (num ?nc))
   =>
    (modify ?cell-to-upd (score (* ?nr ?nc)))
    (retract ?a)
    (assert (update-score-row (row ?row) (num ?nr) (y-to-upd (+ ?y 1))))
)

;---------------UPDATE-NEIGHBOR--------------------------------------
; regole per aggiungere l'acqua ai vicini dopo aver fatto una fire(se middle non aggiungiamo)

; top si riferisce alla cella in esame da riempire con l'acqua (non al contenuto della fire)
(defrule add-water-after-fire-top (declare (salience 80))
   ; ?fire <- (fire (x ?x) (y ?y))
   (cell-agent (x ?x) (y ?y) (content top | right | left))
   ?top <- (cell-agent (x ?top-x&:(eq ?top-x (- ?x 1))) (y ?y) (content ?content&:(neq ?content water)))
   =>
   (modify ?top (content water) (status know) (score 0))
)

(defrule add-water-after-fire-bot (declare (salience 80))
   ; ?fire <- (fire (x ?x) (y ?y))
   (cell-agent (x ?x) (y ?y) (content bot | right | left))
   ?bot <- (cell-agent (x ?bot-x&:(eq ?bot-x (+ ?x 1))) (y ?y) (content ?content&:(neq ?content water)))
   =>
   (modify ?bot (content water) (status know) (score 0))
)

(defrule add-water-after-fire-right (declare (salience 80))
   ; ?fire <- (fire (x ?x) (y ?y))
   (cell-agent (x ?x) (y ?y) (content bot | right | top))
   ?right <- (cell-agent (x ?x) (y ?right-y&:(eq ?right-y (+ ?y 1))) (content ?content&:(neq ?content water)))
   =>
   (modify ?right (content water) (status know) (score 0))
)

(defrule add-water-after-fire-left (declare (salience 80))
   ; ?fire <- (fire (x ?x) (y ?y))
   (cell-agent (x ?x) (y ?y) (content bot | left | top))
   ?left <- (cell-agent (x ?x) (y ?left-y&:(eq ?left-y (- ?y 1))) (content ?content&:(neq ?content water)))
   =>
   (modify ?left (content water) (status know) (score 0))
)
;---------------------------------------------------------------
; Se esistono le celle right e left, dopo aver inferito un middle, allora inferiamo l'acqua nella cella sopra
(defrule add-water-after-fire-middle-hor-up (declare (salience 80))
   ?middle<- (cell-agent (x ?x) (y ?y) (content middle) )
   (or
      (cell-agent (x ?x) (y ?right-y&:(eq ?right-y (+ ?y 1))) (content right))
      (cell-agent (x ?x) (y ?left-y&:(eq ?left-y (- ?y 1))) (content left))
   )
   ?sopra<-(cell-agent (x ?xu&:(eq ?xu (- ?x 1))) (y ?y) (content ?c&:(neq ?c water)))
   =>
   (modify ?sopra (content water) (status know) (score 0))
)
; Se esistono le celle right e left, dopo aver inferito un middle, allora inferiamo l'acqua nella cella sotto
(defrule add-water-after-fire-middle-hor-bot (declare (salience 80))
   ?middle<- (cell-agent (x ?x) (y ?y) (content middle) )
   (or
      (cell-agent (x ?x) (y ?right-y&:(eq ?right-y (+ ?y 1))) (content right))
      (cell-agent (x ?x) (y ?left-y&:(eq ?left-y (- ?y 1))) (content left))
   )
   ?sotto<-(cell-agent (x ?xu&:(eq ?xu (+ ?x 1))) (y ?y) (content ?c&:(neq ?c water)))
   =>
   (modify ?sotto (content water) (status know) (score 0))
)
; Se esistono le celle top e bot, dopo aver inferito un middle, allora inferiamo l'acqua nella cella a sinistra
(defrule add-water-after-fire-middle-ver-left (declare (salience 80))
   ?middle<- (cell-agent (x ?x) (y ?y) (content middle) )
   (or
      (cell-agent (x ?top-x&:(eq ?top-x (- ?x 1))) (y ?y) (content top))
      (cell-agent (x ?bot-x&:(eq ?bot-x (+ ?x 1))) (y ?y) (content bot))
   )
   ?sinistra<-(cell-agent (x ?x) (y ?ys&:(eq ?ys (- ?y 1))) (content ?c&:(neq ?c water)))
   =>
   (modify ?sinistra (content water) (status know) (score 0))
)
; Se esistono le celle top e bot, dopo aver inferito un middle, allora inferiamo l'acqua nella cella a destra
(defrule add-water-after-fire-middle-ver-right (declare (salience 80))
   ?middle<- (cell-agent (x ?x) (y ?y) (content middle) )
   (or
      (cell-agent (x ?top-x&:(eq ?top-x (- ?x 1))) (y ?y) (content top))
      (cell-agent (x ?bot-x&:(eq ?bot-x (+ ?x 1))) (y ?y) (content bot))
   )
   ?destra<-(cell-agent (x ?x) (y ?ys&:(eq ?ys (+ ?y 1))) (content ?c&:(neq ?c water)))
   =>
   (modify ?destra (content water) (status know) (score 0))
)
;---------------END-UPDATE-NEIGHBOR--------------------------------------
;-----------------UPDATE-BOAT-----------------------------------------------------------





;-----------------UPDATE-BOAT-----------------------------------------------------------

(defrule update-kb-corazzata-hor (declare (salience 80))
   ?cell-left <- (cell-agent (x ?x) (y ?left-y) (content left) (score ?left-s&:(neq ?left-s -1)))
   ?cell-middle1 <- (cell-agent (x ?x) (y ?m1-y&:(eq ?m1-y (+ ?left-y 1))) (content middle) (score ?m1-s&:(neq ?m1-s -1)) )
   ?cell-middle2 <- (cell-agent (x ?x) (y ?m2-y&:(eq ?m2-y (+ ?m1-y 1))) (content middle) (score ?m2-s&:(neq ?m2-s -1)) )
   ?cell-right <- (cell-agent (x ?x) (y ?right-y&:(eq ?right-y (+ ?m2-y 1))) (content right) (score ?right-s&:(neq ?right-s -1)) )
   ?corazzata <- (boat-agent (name corazzata))
   =>
   (modify ?cell-left (score -1))
   (modify ?cell-middle1 (score -1))
   (modify ?cell-middle2 (score -1))
   (modify ?cell-right (score -1))
   (retract ?corazzata)
)

(defrule update-kb-corazzata-ver (declare (salience 80))
   ?cell-top-on-middle <- (cell-agent (x ?top-x) (y ?y) (content top) (score ?top-s&:(neq ?top-s -1)) )
   ?cell-middle1 <- (cell-agent (x ?m1-x&:(eq ?m1-x (+ ?top-x 1))) (y ?y) (content middle) (score ?m1-s&:(neq ?m1-s -1)) )
   ?cell-middle2 <- (cell-agent (x ?m2-x&:(eq ?m2-x(+ ?m1-x 1))) (y ?y) (content middle) (score ?m2-s&:(neq ?m2-s -1)) )
   ?cell-bot-on-middle <- (cell-agent (x ?bot-x&:(eq ?bot-x(+ ?m2-x 1))) (y ?y) (content left) (score ?bot-s&:(neq ?bot-s -1)))
   ?corazzata <- (boat-agent (name corazzata))
   =>
   (modify ?cell-top-on-middle(score -1))
   (modify ?cell-middle1 (score -1))
   (modify ?cell-middle2 (score -1))
   (modify ?cell-bot-on-middle (score -1))
   (retract ?corazzata)
)


(defrule update-kb-incrociatore-hor (declare (salience 80))
   ?cell-middle <- (cell-agent (x ?x) (y ?y) (content middle) (score ?middle-s&:(neq ?middle-s -1)) )
   ?cell-left-on-middle <- (cell-agent (x ?x) (y ?left-y&:(eq ?left-y (- ?y 1))) (content left) (score ?left-s&:(neq ?left-s -1)))
   ?cell-right-on-middle <- (cell-agent (x ?x) (y ?right-y&:(eq ?right-y (+ ?y 1))) (content right) (score ?right-s&:(neq ?right-s -1)) )
   ?incrociatore <- (boat-agent (name incrociatore))
   =>
   (modify ?cell-middle (score -1))
   (modify ?cell-left-on-middle (score -1))
   (modify ?cell-right-on-middle (score -1))
   (retract ?incrociatore)
)


;   Se ho top-middle-bot ho trovato un incrociatore -> aggiorno base conoscenza 
;   (setto gli score a 0 cosi la regola non si attiva per tutti gli altri fatti boat-agent(content incrociatore))
(defrule update-kb-incrociatore-ver (declare (salience 80)) 
   ?cell-middle <- (cell-agent (x ?x) (y ?y) (content middle) (score ?middle-s&:(neq ?middle-s -1)) )
   ?cell-top-on-middle <- (cell-agent (x ?top-x&:(eq ?top-x (- ?x 1))) (y ?y) (content top) (score ?top-s&:(neq ?top-s -1)) )
   ?cell-bot-on-middle <- (cell-agent (x ?bot-x&:(eq ?bot-x (+ ?x 1))) (y ?y) (content bot) (score ?bot-s&:(neq ?bot-s -1)) )
   ?incrociatore <- (boat-agent (name incrociatore))
   =>
   (modify ?cell-middle (score -1))
   (modify ?cell-top-on-middle (score -1))
   (modify ?cell-bot-on-middle (score -1))
   (retract ?incrociatore)
)

(defrule update-kb-caccia-hor (declare (salience 80))
   ?cell-left <- (cell-agent (x ?x) (y ?left-y) (content left) (score ?left-s&:(neq ?left-s -1)))
   ?cell-right <- (cell-agent (x ?x) (y ?right-y&:(eq ?right-y (+ ?left-y 1))) (content right) (score ?right-s&:(neq ?right-s -1)) )
   ?caccia <- (boat-agent (name caccia))
   =>
   (modify ?cell-left (score -1))
   (modify ?cell-right (score -1))
   (retract ?caccia)
)

(defrule update-kb-caccia-ver (declare (salience 80))
   ?cell-top <- (cell-agent (x ?top-x) (y ?y)(status fire)(content top) (score ?top-s&:(neq ?top-s -1)))
   ?cell-bot <- (cell-agent (x ?bot-x&:(eq ?bot-x (+ ?top-x 1))) (y ?y) (content bot) (score ?bot-s&:(neq ?bot-s -1)))
   ?caccia <- (boat-agent (name caccia))
   =>
   (modify ?cell-top (score -1))
   (modify ?cell-bot (score -1))
   (retract ?caccia)
)


;  Se ho un sub aggiorno la base di conoscenza (aggiunta la condizione sullo score per non farlo attivare sugli altri fatti)
(defrule update-kb-sottomarino (declare (salience 50)) 
   ?cell <- (cell-agent (x ?x) (y ?y) (content sub) (score ?s&:(> ?s 0)) )
   ?sub <- (boat-agent (name sottomarino))
   =>
   (modify ?cell (score 0))
   (retract ?sub)
)
;-----------------END-UPDATE-BOAT-----------------------------------------------------------
