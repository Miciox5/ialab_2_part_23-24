(defmodule DELIBERATION (import AGENT ?ALL) (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

;------------ TEMPLATE ---------------------------

(deftemplate root-backtracking
   (slot step)
   (slot x)
   (slot y)
)

;---------------- REGOLE ------------------------------------------

;--- GREEDY ---

(defrule enter-in-greedy-state (declare (salience 140))
   (not (state-dfs))
   =>
   (assert (state-dfs greedy))
)

; Regole che mettono guess sicure
(defrule find-guess-with-k-cell (declare (salience 130))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (k-cell (x ?x) (y ?y) (content ?c))
   (cell-agent (x ?x) (y ?y) (status none))
   =>
   (assert (exec-agent (step ?step) (action guess) (content ?c) (x ?x) (y ?y)))  
   (pop-focus)
)

; (defrule find-guess-after-fire (declare (salience 120))
;    (status (step ?step) (currently running))
;    (moves (guesses ?ng&:(> ?ng 0)))
;    (exec-agent (step ?pstep&:(eq ?pstep (- ?step 1))) (action fire) (x ?x) (y ?y))
;    (cell-agent (x ?x) (y ?y) (content none) (status none))
;    (k-cell (x ?x) (y ?y) (content ?c))
;    =>
;    (assert (exec-agent (step ?step) (action guess) (content ?c) (x ?x) (y ?y)))  
;    (pop-focus)
; )

; RICERCA CORAZZATA (NAVI DA 4)
; ---- Conoscenza di 3/4 dei pezzi di una nave da 4 ----
(defrule find-guess-corazzata-last-right (declare (salience 100))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?lx) (y ?y) (content left) (status know) )
   (cell-agent (x ?m1x&:(eq ?m1x (+ ?lx 1))) (y ?y) (content middle) (status know))
   (cell-agent (x ?m2x&:(eq ?m2x (+ ?lx 2))) (y ?y) (content middle) (status know))
   (cell-agent (x ?rx&:(eq ?rx (+ ?lx 3))) (y ?y) (content none) (status none))
   (state-dfs greedy)
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
   (state-dfs greedy)
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
   (state-dfs greedy)
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
   (state-dfs greedy)
   =>
   (assert (exec-agent (step ?step) (action guess) (content bot) (x ?x) (y ?by)))  
   (pop-focus)
)

; ---- Conoscenza di 2/4 dei pezzi di una nave da 4 ----

(defrule find-guess-corazzata-third-right (declare (salience 100))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (cell-agent (x ?m1x) (y ?y) (content middle) (status know))
   (cell-agent (x ?m2x&:(eq ?m2x (+ ?m1x 1))) (y ?y) (content middle) (status know))
   (cell-agent (x ?rx&:(eq ?rx (+ ?m1x 2))) (y ?y) (content none) (status none))
   (state-dfs greedy)
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
   (state-dfs greedy)
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
   (state-dfs greedy)
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
   (state-dfs greedy)
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
   (state-dfs greedy)
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
   (state-dfs greedy)
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
   (state-dfs greedy)
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
   (state-dfs greedy)
   =>
   (assert (exec-agent (step ?step) (action guess) (x ?x) (y ?gy)))  
   (pop-focus)
)
;--
; Mette la guess a destra se viene trovato un middle sul bordo oppure con l'indice in alto/basso a 0
(defrule find-guess-from-middle-boat-hor-right (declare (salience 95))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (state-dfs greedy)

   (cell-agent (x ?x) (y ?y) (content none) (status none))
   (k-per-row-agent (row ?x) (num ?nr&:(> ?nr 0)))
   (k-per-col-agent (col ?y) (num ?nc&:(> ?nc 0)))
   (cell-agent (x ?x) (y ?my&:(eq ?my (- ?y 1))) (content middle) (status know))
   (or
      ; riga superiore con indice a 0
      (k-per-row-agent (row ?r1&:(eq ?r1 (- ?x 1))) (num 0))
      ; riga inferiore con indice a 0
      (k-per-row-agent (row ?r2&:(eq ?r2 (+ ?x 1))) (num 0))
      ; riga superiore non esistente
      (not (cell-agent (x ?r1&:(eq ?r1 (- ?x 1))) (y ?y)))
      ; riga inferiore non esistente
      (not (cell-agent (x ?r2&:(eq ?r2 (+ ?x 1))) (y ?y)))
   )
   =>
   (assert (exec-agent (step ?step) (action guess) (x ?x) (y ?y)))  
   (pop-focus)
)

; Mette la guess a sinistra se viene trovato un middle sul bordo oppure con l'indice in alto/basso a 0
(defrule find-guess-from-middle-boat-hor-left (declare (salience 95))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (state-dfs greedy)
   (k-per-row-agent (row ?x) (num ?nr&:(> ?nr 0)))
   (cell-agent (x ?x) (y ?y) (content none) (status none))
   (k-per-row-agent (row ?x) (num ?nr&:(> ?nr 0)))
   (k-per-col-agent (col ?y) (num ?nc&:(> ?nc 0)))
   (cell-agent (x ?x) (y ?my&:(eq ?my (+ ?y 1))) (content middle) (status know))
   (or
      ; riga superiore con indice a 0
      (k-per-row-agent (row ?r1&:(eq ?r1 (- ?x 1))) (num 0))
      ; riga inferiore con indice a 0
      (k-per-row-agent (row ?r2&:(eq ?r2 (+ ?x 1))) (num 0))
      ; riga superiore non esistente
      (not (cell-agent (x ?r1&:(eq ?r1 (- ?x 1))) (y ?y)))
      ; riga inferiore non esistente
      (not (cell-agent (x ?r2&:(eq ?r2 (+ ?x 1))) (y ?y)))
   )
   =>
   (assert (exec-agent (step ?step) (action guess) (x ?x) (y ?y)))  
   (pop-focus)
)

; Mette la guess in alto se viene trovato un middle sul bordo oppure con l'indice a destra/sinistra a 0
(defrule find-guess-from-middle-boat-ver-top (declare (salience 95))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (state-dfs greedy)

   (cell-agent (x ?x) (y ?y) (content none) (status none))
   (k-per-row-agent (row ?x) (num ?nr&:(> ?nr 0)))
   (k-per-col-agent (col ?y) (num ?nc&:(> ?nc 0)))
   (cell-agent (x ?mx&:(eq ?mx (+ ?x 1))) (y ?y) (content middle) (status know))
   (or
      ; colonna sinistra con indice a 0
      (k-per-col-agent (col ?c1&:(eq ?c1 (- ?y 1))) (num 0))
      ; colonna destra con indice a 0
      (k-per-col-agent (col ?c2&:(eq ?c2 (+ ?y 1))) (num 0))
      ; colonna sinistra non esistente
      (not (cell-agent (x ?x) (y ?c1&:(eq ?c1 (- ?y 1)))))
      ; colonna destra non esistente
      (not (cell-agent (x ?x) (y ?c2&:(eq ?c2 (+ ?y 1)))))
   )
   =>
   (assert (exec-agent (step ?step) (action guess) (x ?x) (y ?y)))  
   (pop-focus)
)

; Mette la guess in basso se viene trovato un middle sul bordo oppure con l'indice a destra/sinistra a 0
(defrule find-guess-from-middle-boat-ver-bot (declare (salience 95))
   (status (step ?step) (currently running))
   (moves (guesses ?ng&:(> ?ng 0)))
   (state-dfs greedy)

   (cell-agent (x ?x) (y ?y) (content none) (status none))
   (k-per-row-agent (row ?x) (num ?nr&:(> ?nr 0)))
   (k-per-col-agent (col ?y) (num ?nc&:(> ?nc 0)))
   (cell-agent (x ?mx&:(eq ?mx (- ?x 1))) (y ?y) (content middle) (status know))
   (or
      ; colonna sinistra con indice a 0
      (k-per-col-agent (col ?c1&:(eq ?c1 (- ?y 1))) (num 0))
      ; colonna destra con indice a 0
      (k-per-col-agent (col ?c2&:(eq ?c2 (+ ?y 1))) (num 0))
      ; colonna sinistra non esistente
      (not (cell-agent (x ?x) (y ?c1&:(eq ?c1 (- ?y 1)))))
      ; colonna destra non esistente
      (not (cell-agent (x ?x) (y ?c2&:(eq ?c2 (+ ?y 1)))))
   )
   =>
   (assert (exec-agent (step ?step) (action guess) (x ?x) (y ?y)))  
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
   (state-dfs greedy)
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
   (state-dfs greedy)
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
   (state-dfs greedy)
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
   (state-dfs greedy)
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
   (state-dfs greedy)
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
   (state-dfs greedy)
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
   (state-dfs greedy)
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
   (state-dfs greedy)
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
   (cell-agent (x ?tx&:(eq ?tx (- ?x 1))) (y ?y) (content none) (status none))
   (or 
      (not (cell-agent (x ?x) (y ?ly&:(eq ?ly (- ?y 1))) (content none)))
      (cell-agent (x ?x) (y ?ly&:(eq ?ly (- ?y 1))) (content water))
      (not (cell-agent (x ?x) (y ?ry&:(eq ?ry (+ ?y 1))) (content none)))
      (cell-agent (x ?x) (y ?ry&:(eq ?ry (+ ?y 1))) (content water))
   )
   (state-dfs greedy)
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
   (cell-agent (x ?bx&:(eq ?bx (+ ?x 1))) (y ?y) (content none) (status none))
   (or 
      (not (cell-agent (x ?x) (y ?ly&:(eq ?ly (- ?y 1))) (content none)))
      (cell-agent (x ?x) (y ?ly&:(eq ?ly (- ?y 1))) (content water))
      (not (cell-agent (x ?x) (y ?ry&:(eq ?ry (+ ?y 1))) (content none)))
      (cell-agent (x ?x) (y ?ry&:(eq ?ry (+ ?y 1))) (content water))
   )
   (state-dfs greedy)
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
   (cell-agent (x ?x) (y ?ly&:(eq ?ly (- ?y 1))) (content none) (status none))
   (or 
      (not (cell-agent (x ?tx&:(eq ?tx (- ?x 1))) (y ?y) (content none)))
      (cell-agent (x ?tx&:(eq ?tx (- ?x 1))) (y ?y) (content water))
      (not (cell-agent (x ?bx&:(eq ?bx (+ ?x 1))) (y ?y) (content none)))
      (cell-agent (x ?bx&:(eq ?bx (+ ?x 1))) (y ?y) (content water))
   )
   (state-dfs greedy)
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
   (cell-agent (x ?x) (y ?ry&:(eq ?ry (+ ?y 1))) (content none) (status none))
   (or 
      (not (cell-agent (x ?tx&:(eq ?tx (- ?x 1))) (y ?y) (content none)))
      (cell-agent (x ?tx&:(eq ?tx (- ?x 1))) (y ?y) (content water))
      (not (cell-agent (x ?bx&:(eq ?bx (+ ?x 1))) (y ?y) (content none)))
      (cell-agent (x ?bx&:(eq ?bx (+ ?x 1))) (y ?y) (content right))
   )
   (state-dfs greedy)
   =>
   (assert (exec-agent (step ?step) (action guess) (x ?x) (y ?ry)))  
   (pop-focus)
)

;---------------------FIRE------------------------------------------

; (defrule find-cell-fire-boat-hor (declare (salience 90))
;    (status (step ?step) (currently running))
;    ; setting fire
;    (moves (fires ?numf&:(> ?numf 0)))
;    (cell-agent (x ?x) (y ?y) (status none) (score ?s))   
;    (not (k-cell (x ?x) (y ?y)))
;    (not (cell-agent (x ?x1) (y ?y2) (status none) (score ?s1&:(> ?s1 ?s))))
;    (k-per-row-agent (row ?x) (num ?nr&:(> ?nr 0)) )
;    (k-per-col-agent (col ?y) (num ?nc&:(> ?nc 0)) )
;    (state-dfs greedy)
;    (cell-agent (x ?x) (y ?my&:(eq ?my (+ ?y 1))) (status guess))
;    =>
;    (assert (exec-agent (step ?step) (action fire) (x ?x) (y ?y)))  
;    (pop-focus)
; )

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
   (state-dfs greedy)
   =>
   (assert (exec-agent (step ?step) (action fire) (x ?x) (y ?y)))  
   (pop-focus)
)

;----------------------GUESS--------------------------------------------

;---EXPLORE---
(defrule enter-in-explore-state (declare (salience 80))
   ?state <- (state-dfs greedy)
   (moves (guesses ?ng))
   =>
   (retract ?state)
   (assert (state-dfs explore))
   (assert (guesses-to-do ?ng))  ; salvato il numero di guess rimanenti dopo lo stato di greedy
   (printout t "Num guesses to do="?ng crlf)
)

(defrule find-cell-guess-after-backtracking (declare (salience 75))
   (status (step ?step) (currently running) )
   ; setting guess
   (moves (guesses ?ng&:(> ?ng 0)))
   ?rb <- (root-backtracking (x ?bkx) (y ?bky))
   (cell-agent (x ?x&:(neq ?x ?bkx)) (y ?y&:(neq ?y ?bky)) (status none) (score ?s) )
   (k-per-row-agent (row ?x) (num ?nr&:(> ?nr 0)) )
   (k-per-col-agent (col ?y) (num ?nc&:(> ?nc 0)) )
   (not (cell-agent (x ?x1&:(neq ?x1 ?bkx)) (y ?y1&:(neq ?y1 ?bky)) (status none) (score ?s1&:(> ?s1 ?s)))) 
   (state-dfs explore)
   =>
   (assert (exec-agent (step ?step) (action guess) (state-dfs explore) (x ?x) (y ?y)))  
   (retract ?rb)
   (printout t "guess after bk step="?step " x=" ?x " y=" ?y crlf)
   (pop-focus)
)

(defrule find-cell-guess (declare (salience 75))
   (status (step ?step) (currently running) )
   ; setting guess
   (moves (guesses ?ng&:(> ?ng 0)))
   (not (root-backtracking (x ?bkx) (y ?bky)))
   (cell-agent (x ?x) (y ?y) (status none) (score ?s) )
   (not (cell-agent (x ?x1) (y ?y1) (status none) (score ?s1&:(> ?s1 ?s))))
   (k-per-row-agent (row ?x) (num ?nr&:(> ?nr 0)) )
   (k-per-col-agent (col ?y) (num ?nc&:(> ?nc 0)) )
   (state-dfs explore)
   =>
   (assert (exec-agent (step ?step) (action guess) (state-dfs explore) (x ?x) (y ?y)))  
   (printout t "guess step="?step " x=" ?x " y=" ?y crlf)
   (pop-focus)
)

(defrule remain-last-path (declare (salience 73))
   (status (step ?step) (currently running) )
   ?state <- (state-dfs explore)
   (guesses-to-do ?ng)
   (maxduration ?maxd)
   (test (>= (+ ?step (* ?ng 2)) ?maxd))
   =>
   (retract ?state)
   (assert (state-dfs solve))
)

;----------------------UNGUESS------------------------------------------

;---BACKTRACKING---
(defrule enter-in-backtracking-state (declare (salience 70))
   ?state <- (state-dfs explore)
   (moves (guesses ?ng&:(> ?ng 0)))
   =>
   (retract ?state)
   (assert (state-dfs backtracking))
)

; Trova la radice(cella con la prima guess in explore) che guida la salita del backtracking
(defrule define-root (declare (salience 65))
   (status (step ?step) (currently running) )
   (moves (guesses ?ng&:(> ?ng 0)))
   (state-dfs backtracking)
   (not (root-backtracking))
   ?eg-to-ungess <- (exec-agent (step ?step1&:(< ?step1 ?step)) (action guess) (state-dfs explore) (x ?x1) (y ?y1))
   (not ( exec-agent (step ?step2&:(< ?step2 ?step1)) (action guess) (state-dfs explore) (x ?x2) (y ?y2)))
   =>
   (assert (root-backtracking (step ?step1) (x ?x1) (y ?y1)))
   (printout t "radice step="?step1 " x=" ?x1 " y=" ?y1 crlf)
)



(defrule find-unguess-backtracking (declare (salience 60))
   (status (step ?step) (currently running) )
   ?state <- (state-dfs backtracking)
   ?r <- (root-backtracking (step ?s) (x ?x) (y ?y))
   ?guess-to-unguess <- (exec-agent (step ?step1&:(>= ?step1  ?s)) (action guess) (state-dfs explore) (x ?x1) (y ?y1)) ; guess da eliminare
   (not (exec-agent (action unguess) (x ?x1) (y ?y1) (step ?s1&:(>= ?s1  ?s))))
   =>
   (assert (exec-agent (step ?step) (action unguess) (state-dfs backtracking) (x ?x1) (y ?y1)))  
   (printout t "unguess step="?step " su x="?x1 " y=" ?y1 crlf)
   (retract ?guess-to-unguess)
   (pop-focus)
)


(defrule enter-in-explore-state-after-bk (declare (salience 45))
   (status (step ?step) (currently running) )
   ?state <- (state-dfs backtracking)
   (moves (guesses ?ng&:(> ?ng 0)))
   =>
   (retract ?state)
   (assert (state-dfs explore))
)

;-----------SOLVE--------------
(defrule enter-in-solve-state (declare (salience -1))
   ?state <- (state-dfs explore)
   (moves (guesses ?ng&:(eq ?ng 0)))
   =>
   (retract ?state)
   (assert (state-dfs solve))
)

(defrule resolution (declare (salience -2))
   (status (step ?step))
   (state-dfs solve)
   =>
   (assert (exec-agent (step ?step) (action solve)))  
   (pop-focus)
)