(defmodule DELIBERATION (import AGENT ?ALL) (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

;------------ TEMPLATE ---------------------------
(deftemplate unguess
	(slot x)
	(slot y)
)

;---------------- REGOLE ------------------------------------------

; RICERCA CORAZZATA (NAVI DA 4)
; ---- Conoscenza di 3/4 dei pezzi di una nave da 4 ----
(defrule find-guess-corazzata-last-right (declare (salience 100))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?lx) (y ?y) (content left) (status know) )
   (cell-agent (x ?m1x&:(eq ?m1x (+ ?lx 1))) (y ?y) (content middle) (status know))
   (cell-agent (x ?m2x&:(eq ?m2x (+ ?lx 2))) (y ?y) (content middle) (status know))
   (cell-agent (x ?rx&:(eq ?rx (+ ?lx 3))) (y ?y) (content none) (status none))
   =>
   (assert (exec-agent (step ?step) (action guess) (content right) (x ?rx) (y ?y)))  
   (pop-focus)
)

(defrule find-guess-corazzata-last-left (declare (salience 100))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?rx) (y ?y) (content right) (status know) )
   (cell-agent (x ?m1x&:(eq ?m1x (+ ?rx 1))) (y ?y) (content middle) (status know))
   (cell-agent (x ?m2x&:(eq ?m2x (+ ?rx 2))) (y ?y) (content middle) (status know))
   (cell-agent (x ?lx&:(eq ?lx (+ ?rx 3))) (y ?y) (content none) (status none))
   =>
   (assert (exec-agent (step ?step) (action guess) (content left) (x ?lx) (y ?y)))  
   (pop-focus)
)

(defrule find-guess-corazzata-last-top (declare (salience 100))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?x) (y ?by) (content bot) (status know) )
   (cell-agent (x ?x) (y ?m1y&:(eq ?m1y (- ?by 1))) (content middle) (status know))
   (cell-agent (x ?x) (y ?m2y&:(eq ?m2y (- ?by 2))) (content middle) (status know))
   (cell-agent (x ?x) (y ?ty&:(eq ?ty (- ?by 3))) (content none) (status none))
   =>
   (assert (exec-agent (step ?step) (action guess) (content top) (x ?x) (y ?ty)))  
   (pop-focus)
)

(defrule find-guess-corazzata-last-bot (declare (salience 100))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?x) (y ?ty) (content top) (status know) )
   (cell-agent (x ?x) (y ?m1y&:(eq ?m1y (+ ?ty 1))) (content middle) (status know))
   (cell-agent (x ?x) (y ?m2y&:(eq ?m2y (+ ?ty 2))) (content middle) (status know))
   (cell-agent (x ?x) (y ?by&:(eq ?by (+ ?ty 3))) (content none) (status none))
   =>
   (assert (exec-agent (step ?step) (action guess) (content bot) (x ?x) (y ?by)))  
   (pop-focus)
)
; --------
; ---- Conoscenza di 2/4 dei pezzi di una nave da 4 ----

(defrule find-guess-corazzata-third-right (declare (salience 100))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?m1x) (y ?y) (content middle) (status know))
   (cell-agent (x ?m2x&:(eq ?m2x (+ ?m1x 1))) (y ?y) (content middle) (status know))
   (cell-agent (x ?rx&:(eq ?rx (+ ?m1x 2))) (y ?y) (content none) (status none))
   =>
   (assert (exec-agent (step ?step) (action guess) (content right) (x ?rx) (y ?y)))  
   (pop-focus)
)

(defrule find-guess-corazzata-third-left (declare (salience 100))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?m1x) (y ?y) (content middle) (status know))
   (cell-agent (x ?m2x&:(eq ?m2x (- ?m1x 1))) (y ?y) (content middle) (status know))
   (cell-agent (x ?lx&:(eq ?lx (- ?m1x 2))) (y ?y) (content none) (status none))
   =>
   (assert (exec-agent (step ?step) (action guess) (content left) (x ?lx) (y ?y)))  
   (pop-focus)
)

(defrule find-guess-corazzata-third-top (declare (salience 100))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?x) (y ?m1y) (content middle) (status know))
   (cell-agent (x ?x) (y ?m2y&:(eq ?m2y (- ?m1y 1))) (content middle) (status know))
   (cell-agent (x ?x) (y ?ty&:(eq ?ty (- ?m1y 3))) (content none) (status none))
   =>
   (assert (exec-agent (step ?step) (action guess) (content top) (x ?x) (y ?ty)))  
   (pop-focus)
)

(defrule find-guess-corazzata-third-bot (declare (salience 100))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?x) (y ?m1y) (content middle) (status know))
   (cell-agent (x ?x) (y ?m2y&:(eq ?m2y (+ ?m1y 1))) (content middle) (status know))
   (cell-agent (x ?x) (y ?by&:(eq ?by (+ ?m1y 3))) (content none) (status none))
   =>
   (assert (exec-agent (step ?step) (action guess) (content bot) (x ?x) (y ?by)))  
   (pop-focus)
)

; RICERCA INCROCIATORI (NAVI DA 3)

; Mette la guess a destra se ha già trovato un middle ed un left sicuri
(defrule find-guess-by-left-and-middle-known (declare (salience 95))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?x) (y ?y) (content left) )
   (cell-agent (x ?mx&:(eq ?mx (+ ?x 1))) (y ?y) (content middle))
   (cell-agent (x ?gx&:(eq ?gx (+ ?x 2))) (y ?y) (content none) (status none))
   =>
   (assert (exec-agent (step ?step) (action guess) (x ?gx) (y ?y)))  
   (pop-focus)
)

; Mette la guess a sinistra se ha già trovato un middle ed un right sicuri
(defrule find-guess-by-right-and-middle-known (declare (salience 95))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?x) (y ?y) (content right))
   (cell-agent (x ?mx&:(eq ?mx (- ?x 1))) (y ?y) (content middle))
   (cell-agent (x ?gx&:(eq ?gx (- ?x 2))) (y ?y) (content none) (status none))
   =>
   (assert (exec-agent (step ?step) (action guess) (x ?gx) (y ?y)))  
   (pop-focus)
)

; Mette la guess in basso se ha già trovato un middle ed un top sicuri
(defrule find-guess-by-top-and-middle-known (declare (salience 95))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?x) (y ?y) (content top))
   (cell-agent (x ?x) (y ?my&:(eq ?my (+ ?y 1))) (content middle))
   (cell-agent (x ?x) (y ?gy&:(eq ?gy (+ ?y 2))) (content none) (status none))
   =>
   (assert (exec-agent (step ?step) (action guess) (x ?x) (y ?gy)))  
   (pop-focus)
)

; Mette la guess in alto se ha già trovato un middle ed un bot sicuri
(defrule find-guess-by-bot-and-middle-known (declare (salience 95))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?x) (y ?y) (content bot))
   (cell-agent (x ?x) (y ?my&:(eq ?my (- ?y 1))) (content middle))
   (cell-agent (x ?x) (y ?gy&:(eq ?gy (- ?y 2))) (content none) (status none))
   =>
   (assert (exec-agent (step ?step) (action guess) (x ?x) (y ?gy)))  
   (pop-focus)
)

; RICERCA CACCIA (NAVI DA DUE)

; -------BOTTOM------- 
; Qui ci riferiamo al top come contenuto della fire eseguita nel passo precedente
; Esaminiamo la fire sul top con la sicurezza di aver bottom sotto
(defrule find-guess-to-bot-fire-driven(declare (salience 90))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?x) (y ?y) (content top) (status know))
   ?cell <- (cell-agent (x ?bx&:(eq ?bx (+ ?x 1))) (y ?y) (content ?content&:(neq ?content water)) (status none))
   (or
      ; caso indice colonna (k-per-col si riferisce alla conoscenza di dominio)
      (k-per-col (col ?y) (num ?nc&:(eq ?nc 2)) )
      ; caso acqua sotto
      (cell-agent (x ?b-bx&:(eq ?b-bx (+ ?bx 1))) (y ?y) (content water))
      ; caso bordo sotto 
      (not (cell-agent (x ?b-bx&:(eq ?b-bx (+ ?bx 1))) (y ?y)))
   )
   =>
   (assert (exec-agent (step ?step) (action guess) (content bot) (x ?bx) (y ?y)))  
   (pop-focus)
)
;-----BOTTOM-ELSE-------
; Guess guidata dalla fire con incertezza del contenuto sulla cella inferiore
(defrule find-guess-to-bot-fire-driven-else(declare (salience 90))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?x) (y ?y) (content top) (status know))
   ?cell <- (cell-agent (x ?bx&:(eq ?bx (+ ?x 1))) (y ?y) (content ?content&:(neq ?content water)) (status none))
   =>
   (assert (exec-agent (step ?step) (action guess) (x ?bx) (y ?y)))  
   (pop-focus)
)
; -------TOP------- 
(defrule find-guess-to-top-fire-driven(declare (salience 90))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?x) (y ?y) (content bot) (status know))
   ?cell <- (cell-agent (x ?tx&:(eq ?tx (- ?x 1))) (y ?y) (content ?content&:(neq ?content water)) (status none))
   (or
      ; caso indice colonna (k-per-col si riferisce alla conoscenza di dominio)
      (k-per-col (col ?y) (num ?nc&:(eq ?nc 2)) )
      ; caso acqua sotto
      (cell-agent (x ?t-tx&:(eq ?t-tx (- ?tx 1))) (y ?y) (content water))
      ; caso bordo sotto 
      (not (cell-agent (x ?t-tx&:(eq ?t-tx (- ?tx 1))) (y ?y)))
   )
   =>
   (assert (exec-agent (step ?step) (action guess) (content top) (x ?tx) (y ?y)))  
   (pop-focus)
)
;-----TOP-ELSE-------
; Guess guidata dalla fire con incertezza del contenuto sulla cella superior
(defrule find-guess-to-top-fire-driven-else(declare (salience 90))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?x) (y ?y) (content bot) (status know))
   ?cell <- (cell-agent (x ?tx&:(eq ?tx (- ?x 1))) (y ?y) (content ?content&:(neq ?content water)) (status none))
   =>
   (assert (exec-agent (step ?step) (action guess) (x ?tx) (y ?y)))  
   (pop-focus)
)

; -------LEFT------- 
(defrule find-guess-to-left-fire-driven(declare (salience 90))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?x) (y ?y) (content right) (status know))
   ?cell <- (cell-agent (x ?x) (y ?ly&:(eq ?ly (- ?y 1))) (content ?content&:(neq ?content water)) (status none))
   (or
      ; caso indice colonna (k-per-col si riferisce alla conoscenza di dominio)
      (k-per-row (row ?x) (num ?nr&:(eq ?nr 2)) )
      ; caso acqua sotto
      (cell-agent (x ?x) (y ?l-ly&:(eq ?l-ly (- ?ly 1))) (content water))
      ; caso bordo sotto 
      (not (cell-agent (x ?x) (y ?l-ly&:(eq ?l-ly (- ?ly 1)))))
   )
   =>
   (assert (exec-agent (step ?step) (action guess) (content left) (x ?x) (y ?ly)))  
   (pop-focus)
)
;-----LEFT-ELSE-------
; Guess guidata dalla fire con incertezza del contenuto sulla cella superior
(defrule find-guess-to-left-fire-driven-else(declare (salience 90))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?x) (y ?y) (content right) (status know))
   ?cell <- (cell-agent (x ?x) (y ?ly&:(eq ?ly (- ?y 1))) (content ?content&:(neq ?content water)) (status none))
   =>
   (assert (exec-agent (step ?step) (action guess) (x ?x) (y ?ly)))  
   (pop-focus)
)
; ; -------RIGHT------- 
(defrule find-guess-to-right-fire-driven(declare (salience 90))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?x) (y ?y) (content left) (status know))
   ?cell <- (cell-agent (x ?x) (y ?ry&:(eq ?ry (+ ?y 1))) (content ?content&:(neq ?content water)) (status none))
   (or
      ; caso indice colonna (k-per-col si riferisce alla conoscenza di dominio)
      (k-per-row (row ?x) (num ?nr&:(eq ?nr 2)) )
      ; caso acqua sotto
      (cell-agent (x ?x) (y ?r-ry&:(eq ?r-ry (+ ?ry 1))) (content water))
      ; caso bordo sotto 
      (not (cell-agent (x ?x) (y ?r-ry&:(eq ?r-ry (+ ?ry 1)))))
   )
   =>
   (assert (exec-agent (step ?step) (action guess) (content right) (x ?x) (y ?ry)))  
   (pop-focus)
)
;-----RIGHT-ELSE-------
; Guess guidata dalla fire con incertezza del contenuto sulla cella superior
(defrule find-guess-to-right-fire-driven-else(declare (salience 90))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?x) (y ?y) (content left) (status know))
   ?cell <- (cell-agent (x ?x) (y ?ry&:(eq ?ry (+ ?y 1))) (content ?content&:(neq ?content water)) (status none))
   =>
   (assert (exec-agent (step ?step) (action guess) (x ?x) (y ?ry)))  
   (pop-focus)
)

; RICERCA SOTTOMARINI (NAVI DA 1)

;-----------------------------------------------------------------------

;   Se il contenuto di una cella nota è middle, allora la cella soprastante sarà top/middle
;   se le due laterali contengono acqua oppure non esistono(bordo)
(defrule find-guess-top-for-middle (declare (salience 80)) 
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?x) (y ?y) (content middle) (status know))
   (cell-agent (x ?tx&:(eq ?tx (- ?x 1))) (y ?y) (content none))
   (or 
      (not (cell-agent (x ?x) (y ?ly&:(eq ?ly (- ?y 1))) (content none)))
      (cell-agent (x ?x) (y ?ly&:(eq ?ly (- ?y 1))) (content water))
      (not (cell-agent (x ?x) (y ?ry&:(eq ?ry (+ ?y 1))) (content none)))
      (cell-agent (x ?x) (y ?ry&:(eq ?ry (+ ?y 1))) (content water))
   )
   =>
   (assert (exec-agent (step ?step) (action guess) (x ?tx) (y ?y)))  
   (pop-focus)
)

;   Se il contenuto di una cella nota è middle, allora la cella sottostante sarà bottom/middle
;   se quella ancora sotto contiene acqua oppure non esiste(bordo)
(defrule find-guess-bot-for-middle (declare (salience 80)) 
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?x) (y ?y) (content middle) (status know))
   (cell-agent (x ?bx&:(eq ?bx (+ ?x 1))) (y ?y) (content none))
   (or 
      (not (cell-agent (x ?x) (y ?ly&:(eq ?ly (- ?y 1))) (content none)))
      (cell-agent (x ?x) (y ?ly&:(eq ?ly (- ?y 1))) (content water))
      (not (cell-agent (x ?x) (y ?ry&:(eq ?ry (+ ?y 1))) (content none)))
      (cell-agent (x ?x) (y ?ry&:(eq ?ry (+ ?y 1))) (content water))
   )
   =>
   (assert (exec-agent (step ?step) (action guess) (x ?bx) (y ?y)))  
   (pop-focus)
)

;   Se il contenuto di una cella nota è middle, allora la cella sottostante sarà left/middle
;   se quella ancora sotto contiene acqua oppure non esiste(bordo)
(defrule find-guess-left-for-middle (declare (salience 80)) 
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?x) (y ?y) (content middle) (status know))
   (cell-agent (x ?x) (y ?ly&:(eq ?ly (- ?y 1))) (content none))
   (or 
      (not (cell-agent (x ?tx&:(eq ?tx (- ?x 1))) (y ?y) (content none)))
      (cell-agent (x ?tx&:(eq ?tx (- ?x 1))) (y ?y) (content water))
      (not (cell-agent (x ?bx&:(eq ?bx (+ ?x 1))) (y ?y) (content none)))
      (cell-agent (x ?bx&:(eq ?bx (+ ?x 1))) (y ?y) (content water))
   )
   =>
   (assert (exec-agent (step ?step) (action guess) (x ?x) (y ?ly)))  
   (pop-focus)
)

;   Se il contenuto di una cella nota è middle, allora la cella sottostante sarà bottom/middle
;   se quella ancora sotto contiene acqua oppure non esiste(bordo)
(defrule find-guess-right-for-middle (declare (salience 80)) 
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?x) (y ?y) (content middle) (status know))
   (cell-agent (x ?x) (y ?ry&:(eq ?ry (+ ?y 1))) (content none))
   (or 
      (not (cell-agent (x ?tx&:(eq ?tx (- ?x 1))) (y ?y) (content none)))
      (cell-agent (x ?tx&:(eq ?tx (- ?x 1))) (y ?y) (content water))
      (not (cell-agent (x ?bx&:(eq ?bx (+ ?x 1))) (y ?y) (content none)))
      (cell-agent (x ?bx&:(eq ?bx (+ ?x 1))) (y ?y) (content right))
   )
   =>
   (assert (exec-agent (step ?step) (action guess) (x ?x) (y ?ry)))  
   (pop-focus)
)

;---------------------FIRE------------------------------------------

; prima fire se non ho conoscnza
(defrule find-cell-fire (declare (salience 85))
   (status (step ?step) (currently running))
   ; setting fire
   (moves (fires ?numf&:(> ?numf 0)))
   (cell-agent (x ?x) (y ?y) (status none) (score ?s))   
   (not (k-cell (x ?x) (y ?y)))
   (not (cell-agent (x ?x1) (y ?y2) (status none) (score ?s1&:(> ?s1 ?s))))
   (k-per-row-agent (row ?x) (num ?nr&:(> ?nr 0)) )
   (k-per-col-agent (col ?y) (num ?nc&:(> ?nc 0)) )
   =>
   (assert (exec-agent (step ?step) (action fire) (x ?x) (y ?y)))  
   (pop-focus)
)

;----------------------GUESS--------------------------------------------

(defrule find-cell-guess (declare (salience 85))
   (status (step ?step) (currently running) )
   ; setting guess
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?x) (y ?y) (status none) (score ?s) )
   (not (cell-agent (x ?x1) (y ?y2) (status none) (score ?s1&:(> ?s1 ?s))))
   (k-per-row-agent (row ?x) (num ?nr&:(> ?nr 0)) )
   (k-per-col-agent (col ?y) (num ?nc&:(> ?nc 0)) )
   =>
   (assert (exec-agent (step ?step) (action guess) (x ?x) (y ?y)))  
   (pop-focus)
)
;---------------------END-GUESS-----------------------------------------

;----------------------UNGUESS------------------------------------------

;   Faccio l'unguess delle celle con contenuto none per poi fare le fire
; (defrule find-cell-unguess (declare (salience 60)) 
;    (moves (guesses ?ng&:(eq ?ng 0)))
;    ?cell-to-upd <-(cell-agent (x ?x) (y ?y) (status guess) (score ?s))  
;    (not (cell-agent (x ?x1) (y ?y2) (content none) (status guess) (score ?s1&:(> ?s1 ?s))))
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