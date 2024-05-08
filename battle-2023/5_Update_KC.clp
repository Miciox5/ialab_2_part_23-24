;---------------UPDATE KNOWLEDGE CONTROL--------------------------------------
(defmodule UPDATE_KC (import AGENT ?ALL) (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))


;------------ TEMPLATE ---------------------------

(deftemplate tmp-exec-agent
	(slot step)
	(slot action (allowed-values guess fire unguess))
	(slot content (default none) (allowed-values none water left right middle top bot sub))
	(slot x)
	(slot y)
)

;------------ REGOLE -----------------------------

; a seguito di una fire(non acqua) copio il contenuto nella cell-agent, aggiorno indici, ricalcolo score, aggiungo acqua intorno
(defrule update-kc-fire-cell-agent (declare(salience 100))
   (exec-agent (step ?step) (action fire) (x ?x) (y ?y))
   (status (step ?stepnext&:(eq ?stepnext (+ ?step 1))) (currently running))
   (k-cell (x ?x) (y ?y) (content ?content&:(neq ?content water)))
   ?upd <- (cell-agent (x ?x) (y ?y) (content none))
   (not (update-neighbor-guess))
   (not (update-neighbor-fire))
   ?row <- (k-per-row-agent (row ?x) (num ?nr&:(> ?nr 0)) )
   ?col <- (k-per-col-agent (col ?y) (num ?nc&:(> ?nc 0)) )
   =>
   (modify ?upd (content ?content) (status know) (score 0))
   (modify ?row (num (- ?nr 1)))
   (modify ?col (num (- ?nc 1)))
   (assert (tmp-exec-agent (step ?step) (action fire) (x ?x) (y ?y)))
   (assert (update-neighbor-fire))
   (assert (update-score-row (row ?x) (num (- ?nr 1)) (y-to-upd 0)))
   (assert (update-score-col (col ?y) (num (- ?nc 1)) (x-to-upd 0)))
)
; se fire becca l'acqua copio solo il contenuto
(defrule update-kc-fire-cell-agent-water (declare(salience 100))
   (exec-agent (step ?step) (action fire) (x ?x) (y ?y))
   (status (step ?stepnext&:(eq ?stepnext (+ ?step 1))) (currently running))
   (k-cell (x ?x) (y ?y) (content water))
   ?upd <- (cell-agent (x ?x) (y ?y) (content none))
   (not (update-neighbor-guess))
   (not (update-neighbor-fire))
   =>
   (modify ?upd (content water) (status know) (score 0))
)

; a seguito di una guess senza contenuto aggiorniamo solo lo status a guess della cella
(defrule update-kc-guess-cell-agent (declare(salience 100))
   (exec-agent (step ?step) (action guess) (content none) (x ?x) (y ?y))
   (status (step ?stepnext&:(eq ?stepnext (+ ?step 1))) (currently running))
   ?upd <- (cell-agent (x ?x) (y ?y) (content none))
   (not (update-neighbor-guess))
   (not (update-neighbor-fire))
   ?row <- (k-per-row-agent (row ?x) (num ?nr&:(> ?nr 0)) )
   ?col <- (k-per-col-agent (col ?y) (num ?nc&:(> ?nc 0)) )
   =>
   (modify ?upd (status guess))
   (modify ?row (num (- ?nr 1)))
   (modify ?col (num (- ?nc 1)))
   (assert (tmp-exec-agent (step ?step) (action guess) (x ?x) (y ?y)))
   (assert (update-neighbor-guess))
   (assert (update-score-row (row ?x) (num (- ?nr 1)) (y-to-upd 0)))
   (assert (update-score-col (col ?y) (num (- ?nc 1)) (x-to-upd 0)))
)
; a seguito di una guess con contenuto aggiorniamo contenuto e status "know" (contenuto sicuro/inferito)
(defrule update-kc-guess-cell-agent-else (declare(salience 100))
   (exec-agent (step ?step) (action guess) (content ?c&:(neq ?c none)) (x ?x) (y ?y))
   (status (step ?stepnext&:(eq ?stepnext (+ ?step 1))) (currently running))
   ?upd <- (cell-agent (x ?x) (y ?y) (content none))
   (not (update-neighbor-guess))
   (not (update-neighbor-fire))
   ?row <- (k-per-row-agent (row ?x) (num ?nr&:(> ?nr 0)) )
   ?col <- (k-per-col-agent (col ?y) (num ?nc&:(> ?nc 0)) )
   =>
   (modify ?upd (content ?c) (status know))
   (modify ?row (num (- ?nr 1)))
   (modify ?col (num (- ?nc 1)))
   (assert (tmp-exec-agent (step ?step) (action guess) (content ?c) (x ?x) (y ?y)))
   (assert (update-neighbor-guess))
   (assert (update-score-row (row ?x) (num (- ?nr 1)) (y-to-upd 0)))
   (assert (update-score-col (col ?y) (num (- ?nc 1)) (x-to-upd 0)))
)

; Unguess di una cella in fase di backtracking
; (defrule update-kc-unguess-cell-agent (declare(salience 100))
;    (exec-agent (step ?step) (action unguess) (x ?x) (y ?y))
;    (status (step ?stepnext&:(eq ?stepnext (+ ?step 1))) (currently running))
;    ?upd <- (cell-agent (x ?x) (y ?y) (status guess))
;    (not (update-neighbor-guess))
;    (not (update-neighbor-fire))
;    ?row <- (k-per-row-agent (row ?x) (num ?nr) )
;    ?col <- (k-per-col-agent (col ?y) (num ?nc) )
;    =>
;    (modify ?upd (content none) (status none))
;    (modify ?row (num (+ ?nr 1)))
;    (modify ?col (num (+ ?nc 1)))
;    ; (assert (tmp-exec-agent (step ?step) (action guess) (content ?c) (x ?x) (y ?y)))
;    (assert (update-score-row (row ?x) (num (+ ?nr 1)) (y-to-upd 0)))
;    (assert (update-score-col (col ?y) (num (+ ?nc 1)) (x-to-upd 0)))
; )

;------------ REGOLE-MIGLIORAMENTI ---------------

; Regole per aggiungere l'acqua ai vicini dopo aver fatto una fire(se middle non aggiungiamo)
(defrule update-kc-fire-water-on-right-side (declare (salience 90))
   (or (update-neighbor-fire) (update-neighbor-guess))
   (tmp-exec-agent (step ?step) (action fire | guess) (x ?x) (y ?y))
   (cell-agent (x ?x) (y ?y) (content right | top | bot) (status know))
   ?right <- (cell-agent (x ?x) (y ?ry&:(eq ?ry (+ ?y 1))) (content none))
   =>
   (modify ?right (content water) (status know) (score 0))
)

(defrule update-kc-fire-water-on-left-side (declare (salience 90))
   (or (update-neighbor-fire) (update-neighbor-guess))
   (tmp-exec-agent (step ?step) (action fire | guess) (x ?x) (y ?y))
   (cell-agent (x ?x) (y ?y) (content left | top | bot) (status know))
   ?left <- (cell-agent (x ?x) (y ?ly&:(eq ?ly (- ?y 1))) (content none))
   =>
   (modify ?left (content water) (status know) (score 0))
)

(defrule update-kc-fire-water-on-top-side (declare (salience 90))
   (or (update-neighbor-fire) (update-neighbor-guess))
   (tmp-exec-agent (step ?step) (action fire | guess) (x ?x) (y ?y))
   (cell-agent (x ?x) (y ?y) (content top | right | left) (status know))
   ?top <- (cell-agent (x ?tx&:(eq ?tx (- ?x 1))) (y ?y) (content none))
   =>
   (modify ?top (content water) (status know) (score 0))
)

(defrule update-kc-fire-water-on-bot-side (declare (salience 90))
   (or (update-neighbor-fire) (update-neighbor-guess))
   (tmp-exec-agent (step ?step) (action fire | guess) (x ?x) (y ?y))
   (cell-agent (x ?x) (y ?y) (content bot | right | left) (status know))
   ?bot <- (cell-agent (x ?bx&:(eq ?bx (+ ?x 1))) (y ?y) (content none))
   =>
   (modify ?bot (content water) (status know) (score 0))
)

(defrule update-kc-fire-water-on-topright-side (declare (salience 90))
   (or (update-neighbor-fire) (update-neighbor-guess))
   (tmp-exec-agent (step ?step) (action fire | guess) (x ?x) (y ?y))
   (cell-agent (x ?x) (y ?y) (status know))
   ?topright <- (cell-agent (x ?trx&:(eq ?trx (- ?x 1))) (y ?try&:(eq ?try (+ ?y 1))) (content none))
   =>
   (modify ?topright (content water) (status know) (score 0))
)
(defrule update-kc-fire-water-on-topleft-side (declare (salience 90))
   (or (update-neighbor-fire) (update-neighbor-guess))
   (tmp-exec-agent (step ?step) (action fire | guess) (x ?x) (y ?y))
   (cell-agent (x ?x) (y ?y) (status know))
   ?topleft <- (cell-agent (x ?trx&:(eq ?trx (- ?x 1))) (y ?try&:(eq ?try (- ?y 1))) (content none))
   =>
   (modify ?topleft (content water) (status know) (score 0))
)
(defrule update-kc-fire-water-on-botleft-side (declare (salience 90))
   (or (update-neighbor-fire) (update-neighbor-guess))
   (tmp-exec-agent (step ?step) (action fire | guess) (x ?x) (y ?y))
   (cell-agent (x ?x) (y ?y) (status know))
   ?botleft <- (cell-agent (x ?trx&:(eq ?trx (+ ?x 1))) (y ?try&:(eq ?try (- ?y 1))) (content none))
   =>
   (modify ?botleft (content water) (status know) (score 0))
)
(defrule update-kc-fire-water-on-botright-side (declare (salience 90))
   (or (update-neighbor-fire) (update-neighbor-guess))
   (tmp-exec-agent (step ?step) (action fire | guess) (x ?x) (y ?y))
   (cell-agent (x ?x) (y ?y) (status know))
   ?botright <- (cell-agent (x ?trx&:(eq ?trx (+ ?x 1))) (y ?try&:(eq ?try (+ ?y 1))) (content none))
   =>
   (modify ?botright (content water) (status know) (score 0))
)

;---------------------------------------------------------------
; Se esistono le celle right e left, dopo aver inferito un middle, allora inferiamo l'acqua nella cella sopra
(defrule add-water-after-fire-middle-hor-up (declare (salience 80))
   (update-neighbor-guess)
   (exec-agent (step ?step) (action fire) (x ?x) (y ?y))
   (status (step ?stepnext&:(eq ?stepnext (+ ?step 1))) (currently running))
   ?middle<- (cell-agent (x ?x) (y ?y) (content middle))
   (or
      (cell-agent (x ?x) (y ?right-y&:(eq ?right-y (+ ?y 1))) (content right))
      (cell-agent (x ?x) (y ?left-y&:(eq ?left-y (- ?y 1))) (content left))
   )
   ?up <-(cell-agent (x ?xu&:(eq ?xu (- ?x 1))) (y ?y) (content ?c&:(neq ?c water)))
   =>
   (modify ?up (content water) (status know) (score 0))
)
; ; Se esistono le celle right o left dopo aver inferito un middle, allora inferiamo l'acqua nella cella sotto
(defrule add-water-after-fire-middle-hor-bot (declare (salience 80))
   (update-neighbor-guess)
   (exec-agent (step ?step) (action fire) (x ?x) (y ?y))
   (status (step ?stepnext&:(eq ?stepnext (+ ?step 1))) (currently running))
   ?middle<- (cell-agent (x ?x) (y ?y) (content middle) )
   (or
      (cell-agent (x ?x) (y ?right-y&:(eq ?right-y (+ ?y 1))) (content right))
      (cell-agent (x ?x) (y ?left-y&:(eq ?left-y (- ?y 1))) (content left))
   )
   ?down <-(cell-agent (x ?xu&:(eq ?xu (+ ?x 1))) (y ?y) (content ?c&:(neq ?c water)))
   =>
   (modify ?down (content water) (status know) (score 0))
)
; ; Se esistono le celle top e bot, dopo aver inferito un middle, allora inferiamo l'acqua nella cella a sinistra
(defrule add-water-after-fire-middle-ver-left (declare (salience 80))
   (update-neighbor-guess)
   (exec-agent (step ?step) (action fire) (x ?x) (y ?y))
   (status (step ?stepnext&:(eq ?stepnext (+ ?step 1))) (currently running))
   ?middle<- (cell-agent (x ?x) (y ?y) (content middle) )
   (or
      (cell-agent (x ?top-x&:(eq ?top-x (- ?x 1))) (y ?y) (content top))
      (cell-agent (x ?bot-x&:(eq ?bot-x (+ ?x 1))) (y ?y) (content bot))
   )
   ?left <-(cell-agent (x ?x) (y ?ys&:(eq ?ys (- ?y 1))) (content ?c&:(neq ?c water)))
   =>
   (modify ?left (content water) (status know) (score 0))
)
; ; Se esistono le celle top e bot, dopo aver inferito un middle, allora inferiamo l'acqua nella cella a destra
(defrule add-water-after-fire-middle-ver-right (declare (salience 80))
   (update-neighbor-guess)
   (exec-agent (step ?step) (action fire) (x ?x) (y ?y))
   (status (step ?stepnext&:(eq ?stepnext (+ ?step 1))) (currently running))
   ?middle<- (cell-agent (x ?x) (y ?y) (content middle) )
   (or
      (cell-agent (x ?top-x&:(eq ?top-x (- ?x 1))) (y ?y) (content top))
      (cell-agent (x ?bot-x&:(eq ?bot-x (+ ?x 1))) (y ?y) (content bot))
   )
   ?right <-(cell-agent (x ?x) (y ?ys&:(eq ?ys (+ ?y 1))) (content ?c&:(neq ?c water)))
   =>
   (modify ?right (content water) (status know) (score 0))
)


;-----------------------------------------------------------------------------

(defrule update-kc-corazzata-hor (declare (salience 70))
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

(defrule update-kc-corazzata-ver (declare (salience 70))
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

(defrule update-kc-incrociatore-hor (declare (salience 70))
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


; Se ho top-middle-bot ho trovato un incrociatore -> aggiorno base conoscenza 
; (setto gli score a 0 cosi la regola non si attiva per tutti gli altri fatti boat-agent(content incrociatore))
(defrule update-kc-incrociatore-ver (declare (salience 70)) 
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

(defrule update-kc-caccia-hor (declare (salience 70))
   ?cell-left <- (cell-agent (x ?x) (y ?left-y) (content left) (score ?left-s&:(neq ?left-s -1)))
   ?cell-right <- (cell-agent (x ?x) (y ?right-y&:(eq ?right-y (+ ?left-y 1))) (content right) (score ?right-s&:(neq ?right-s -1)) )
   ?caccia <- (boat-agent (name caccia))
   =>
   (modify ?cell-left (score -1))
   (modify ?cell-right (score -1))
   (retract ?caccia)
)
; (status guess | fire) 
(defrule update-kc-caccia-ver (declare (salience 70))
   ?cell-top <- (cell-agent (x ?top-x) (y ?y) (content top) (score ?top-s&:(neq ?top-s -1)))
   ?cell-bot <- (cell-agent (x ?bot-x&:(eq ?bot-x (+ ?top-x 1))) (y ?y) (content bot) (score ?bot-s&:(neq ?bot-s -1)))
   ?caccia <- (boat-agent (name caccia))
   =>
   (modify ?cell-top (score -1))
   (modify ?cell-bot (score -1))
   (retract ?caccia)
)

; Se ho un sub aggiorno la base di conoscenza (aggiunta la condizione sullo score per non farlo attivare sugli altri fatti)
(defrule update-kc-sottomarino (declare (salience 50)) 
   ?cell <- (cell-agent (x ?x) (y ?y) (content sub) (score ?s&:(neq ?s -1)) )
   ?sub <- (boat-agent (name sottomarino))
   =>
   (modify ?cell (score -1))
   (retract ?sub)
)
;----------------
; Le due regole seguenti aggiornano lo score di una riga ma non quello della cella dove è stata fatta la guess
; (rimane lo score di quando ho fatto la guess)

; Update score di una colonna iterando sulle righe
(defrule update-kc-scores-col (declare (salience 40))
   ?a <- (update-score-col (col ?col) (num ?nc) (x-to-upd ?updx))
   ?cell-to-upd <- (cell-agent (x ?updx) (y ?col) (status none))
   (k-per-row-agent (row ?updx) (num ?nr))
   =>
   (modify ?cell-to-upd (score (* ?nc ?nr)))
   (modify ?a (x-to-upd (+ ?updx 1)))
)
; else 
(defrule update-kc-scores-col-else (declare (salience 35))
   ?a <- (update-score-col (col ?col) (num ?nc) (x-to-upd ?updx))
   ?cell-to-upd <- (cell-agent (x ?updx) (y ?col))
   =>
   (modify ?a (x-to-upd (+ ?updx 1)))
)

; Aggiornamento degli score di una colonna tranne per la cella in cui è stata fatta la guess
; (rimane lo score di quando ho fatto la guess)

; Update score di una riga iterando sulle colonne
(defrule update-kc-scores-row (declare (salience 40))
   ?a <- (update-score-row (row ?row) (num ?nr) (y-to-upd ?updy))
   ?cell-to-upd <- (cell-agent (x ?row) (y ?updy) (status none))
   (k-per-col-agent (col ?updy) (num ?nc))
   =>
   (modify ?cell-to-upd (score (* ?nr ?nc)))
   (modify ?a (y-to-upd (+ ?updy 1)))
)
; else 
(defrule update-kc-scores-row-else (declare (salience 35))
   ?a <- (update-score-row (row ?row) (num ?nr) (y-to-upd ?updy))
   ?cell-to-upd <- (cell-agent (x ?row) (y ?updy))
   =>
   (modify ?a (y-to-upd (+ ?updy 1)))
)

(defrule finish-update-kc-score-row ( declare (salience 30) ) 
   ?factr <- (update-score-row (y-to-upd 10) )
   =>
   (retract ?factr)

)

(defrule finish-update-kc-score-col ( declare (salience 30) ) 
   ?factc <- (update-score-col (x-to-upd 10)) 
   =>
   (retract ?factc)
)
;------------------------------
(defrule update-kc-garbage-tmp-exec (declare (salience -1))
   ?to-del-exec <- (tmp-exec-agent (step ?step) (x ?x) (y ?y))
   =>
   (retract ?to-del-exec)
)

(defrule update-kc-garbage-guess (declare (salience -2))
   ?to-del-guess <- (update-neighbor-guess)
   =>
   (retract ?to-del-guess)
   (pop-focus)
)

(defrule update-kc-garbage-fire (declare (salience -3))
   ?to-del-fire <- (update-neighbor-fire)
   =>
   (retract ?to-del-fire)
   (pop-focus)
)
