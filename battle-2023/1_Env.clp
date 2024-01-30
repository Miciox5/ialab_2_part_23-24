;;template che iniziano per k: andranno a costituire la conoscenza iniziale del nostro agente
;;	cose che agente conosce dal principio
(defmodule ENV (import MAIN ?ALL) (export deftemplate k-cell k-per-row  k-per-col))


;; rappresentazione cella
(deftemplate cell
	(slot x)
	(slot y)
	;; ogni cella può contenere: acqua, pezzo di nave sano, pezzo di nave colpito 
	(slot content (allowed-values water boat hit-boat))
	;; stati cella: 
	;; none-> se agente non ha preso in considerazione cella,
	;; guessed-> se c'è la bandierina sopra
	;; fired-> se ho colpito una nave
	;; missed-> se ho mancato un(a) (pezzo di) nave 
	(slot status (allowed-values none guessed fired missed))
)

;; navi orizzontali
(deftemplate boat-hor
	(slot name)
	(slot x)
	(multislot ys) ;; perché occupa più coordinate y
	(slot size)
	(multislot status (allowed-values safe hit)) ;; stato di ogni singolo pezzo di nave
)
;;nota: non è rilevante sapere quale cella è stata colpita, basta sapere che ne è stata colpita una.
;; uso poi info solo per sapere se la nave è stata affondata o meno.
;; se cella è stata colpita-> recupero info su cell

;;navi verticali
(deftemplate boat-ver
        (slot name)
	(multislot xs)
	(slot y)
	(slot size)
	(multislot status (allowed-values safe hit))
)

;;ambiente esporta come osservazioni (fatti noti dall'inizio/risultato di una fire)
(deftemplate k-cell 
	(slot x)
	(slot y)
	(slot content (allowed-values water left right middle top bot sub))
)
;;nota: fire è un'operazione precisa
;;			-> abbiamo fatto un buco nell'acqua (water)
;;			-> abbiamo colpito un pezzo di nave e ci dice quale (left,right,middle,top,bot)
;;					Se nave in verticale/orizzontale cambia stato.
;;			-> abbiamo colpito una nave singola (sub)

;; numero di celle occupate da una nave (su singola riga)
(deftemplate k-per-row
	(slot row)
	(slot num)
)
;; numero di celle occupate da una nave (su singola colonna)
(deftemplate k-per-col
	(slot col)
	(slot num)
)


(defrule action-fire 
	?us <- (status (step ?s) (currently running))
	(exec (step ?s) (action fire) (x ?x) (y ?y))
	?mvs <- (moves (fires ?nf &:(> ?nf 0)))
=>
	(assert (fire ?x ?y))
	;;modifico fire a disposizione e vado allo stato successivo
	(modify ?us (step (+ ?s 1)) )
	(modify ?mvs (fires (- ?nf 1)))
)



(defrule action-guess
        ?us <- (status (step ?s) (currently running))
	(exec (step ?s) (action guess) (x ?x) (y ?y))
	?mvs <- (moves (guesses ?ng &:(> ?ng 0)))
=>
	(assert (guess ?x ?y))
        (modify ?us (step (+ ?s 1)) )
	(modify ?mvs (guesses (- ?ng 1)))
)

(defrule action-unguess
        ?us <- (status (step ?s) (currently running))
	(exec (step ?s) (action unguess) (x ?x) (y ?y))
	?gu <- (guess ?x ?y)
	?mvs <- (moves (guesses ?ng &:(< ?ng 20)))
=>	
	(retract ?gu)
        (modify ?us (step (+ ?s 1)) )
	(modify ?mvs (guesses (+ ?ng 1)))
)



(defrule action-solve
        ?us <- (status (step ?s) (currently running))
	(exec (step ?s) (action solve))
=>
	(assert (solve))
        (modify ?us (step (+ ?s 1)) (currently stopped) )
)

;;se agente ha centrato la nave
(defrule fire-ok
	(fire ?x ?y)
	;;esiste una cella con una nave e lo stato della cella e none
	?fc <- (cell (x ?x) (y ?y) (content boat) (status none))
	?st <- (statistics (num_fire_ok ?fok))
=>
	(modify ?fc (content hit-boat) (status fired))
	;;serve per le statistiche
	(modify ?st (num_fire_ok (+ ?fok 1)))
)


(defrule fire-ko
	(fire ?x ?y)
	?fc <- (cell (x ?x) (y ?y) (content water) (status none))
	?st <- (statistics (num_fire_ko ?fko))
=>
	(modify ?fc (status missed))
        (modify ?st (num_fire_ko (+ ?fko 1)))
)

(defrule hit-boat-hor-trace

	(cell (x ?x) (y ?y) (content hit-boat))
	?b<- (boat-hor (x ?x) (ys $? ?y $?) (size ?s) (status $?prima safe $?dopo))
        (not (considered ?x ?y))

=>
	(modify ?b (status ?prima hit ?dopo))
        (assert (considered ?x ?y))
)

(defrule hit-boat-ver-trace

	(cell (x ?x) (y ?y) (content hit-boat))
        (not (considered ?x ?y))
	?b <-(boat-ver (xs $? ?x $?) (y ?y) (size ?s) (status $?prima safe $?dopo))
=>
	(modify ?b (status ?prima hit ?dopo))
        (assert (considered ?x ?y))
)

(defrule sink-boat-hor

	(cell (x ?x) (y ?y) (content hit-boat))
	(boat-hor (name ?n) (x ?x) (ys $? ?y $?) (size ?s) (status $?ss))
        
	(or 
		(and (test (eq ?s 1))
		     (test (subsetp $?ss (create$ hit)))
                )

		(and (test (eq ?s 2))
		     (test (subsetp $?ss (create$ hit hit)))
                )

		(and (test (eq ?s 3))
		     (test (subsetp $?ss (create$ hit hit hit)))
                )

		(and (test (eq ?s 4))
		     (test (subsetp $?ss (create$ hit hit hit hit)))
                )


	)
=>

	(assert (sink-boat ?n ))
)

(defrule sink-boat-ver

	(cell (x ?x) (y ?y) (content hit-boat))
	(boat-ver (name ?n) (xs $? ?x $?) (y ?y) (size ?s) (status $?ss))
        
	(or 
		(and (test (eq ?s 1))
		     (test (subsetp $?ss (create$ hit)))
                )

		(and (test (eq ?s 2))
		     (test (subsetp $?ss (create$ hit hit)))
                )

		(and (test (eq ?s 3))
		     (test (subsetp $?ss (create$ hit hit hit)))
                )

		(and (test (eq ?s 4))
		     (test (subsetp $?ss (create$ hit hit hit hit)))
                )
	)
=>
	(assert (sink-boat ?n))
)



(defrule solve-count-guessed-ok
        (solve)
        (guess ?x ?y)
        ?c <- (cell (x ?x) (y ?y) (content boat) (status none))
        ?st <- (statistics (num_guess_ok ?gok))
=>
	(modify ?st (num_guess_ok (+ 1 ?gok)))
	(modify ?c (content hit-boat) (status guessed))
)

(defrule solve-count-guessed-ko 
	(solve)
	(guess ?x ?y)
	?c <- (cell (x ?x) (y ?y) (content water) (status none))
	?st <- (statistics (num_guess_ko ?gko))
=>
	(modify ?st (num_guess_ko (+ 1 ?gko)))
	(modify ?c (status missed))
)

(defrule solve-count-safe 
	(solve)
	?c <-(cell (x ?x) (y ?y) (content boat) (status none))
	(not (guess ?x ?y))
	?st <- (statistics (num_safe ?saf))
=>
	(modify ?st (num_safe(+ 1 ?saf)))
	(modify ?c (status missed))
)

(defrule solve-sink-count
	(solve)
	?s<- (sink-boat ?n)
        (not (sink-checked ?n))
	?st <- (statistics (num_sink ?sink))
=>
	(modify ?st (num_sink (+ 1 ?sink)))
	(retract ?s)
	(assert (sink-checked ?n))
)


(deffunction scoring (?fok ?fko ?gok ?gko ?saf ?sink ?nf ?ng)

	(- (+ (* ?gok 15) (* ?sink 20) )  (+ (* ?gko 10) (* ?saf 10) (* ?nf 20) (* ?ng 20) ))
)

	

(defrule solve-scoring (declare (salience -10))
	(solve)
	(statistics (num_fire_ok ?fok) (num_fire_ko ?fko) (num_guess_ok ?gok) (num_guess_ko ?gko) (num_safe ?saf) (num_sink ?sink))
	(moves (fires ?nf) (guesses ?ng))
=>
	(printout t "Your score is " (scoring ?fok ?fko ?gok ?gko ?saf ?sink ?nf ?ng) crlf)
)
	

(defrule reset-map
	(k-cell (x ?x) (y ?y) (content ?c&:(neq ?c water)))
	?st <- (statistics (num_fire_ok ?fok))
	(not (resetted ?x ?y))
=>
	(assert (fire ?x ?y))
	(modify ?st (num_fire_ok (- ?fok 1))) ;;non contiamo come fire le posizioni note inizialmente
	(assert (resetted ?x ?y))
)
;;vengono compiute inferenze per capire il pezzo di nave colpito
(defrule make-visible-sub (declare (salience 10))
	(fire ?x ?y)
	(cell (x ?x) (y ?y) (content boat))
	(boat-hor (x ?x) (ys ?y $?) (size 1))
	(not (k-cell (x ?x) (y ?y) ) )
=>
	(assert (k-cell (x ?x) (y ?y) (content sub)))
	(assert (resetted ?x ?y))
)


(defrule make-visible-left (declare (salience 5))
	(fire ?x ?y)
	(cell (x ?x) (y ?y) (content boat))
	(boat-hor (x ?x) (ys ?y $?))
	(not (k-cell (x ?x) (y ?y) ))
=>
	(assert (k-cell (x ?x) (y ?y) (content left)))
	(assert (resetted ?x ?y))
)

(defrule make-visible-right (declare (salience 5))
	(fire ?x ?y)
	(cell (x ?x) (y ?y) (content boat))
	(boat-hor (x ?x) (ys $? ?y))
	(not (k-cell (x ?x) (y ?y)) )
=>
	(assert (k-cell (x ?x) (y ?y) (content right)))
	(assert (resetted ?x ?y))
)

(defrule make-visible-top (declare (salience 5))
	(fire ?x ?y)
	(cell (x ?x) (y ?y) (content boat))
	(boat-ver (y ?y) (xs ?x $?))
	(not (k-cell (x ?x) (y ?y) ) )
=>
	(assert (k-cell (x ?x) (y ?y) (content top)))
	(assert (resetted ?x ?y))
)
	

(defrule make-visible-bot (declare (salience 5))
	(fire ?x ?y)
	(cell (x ?x) (y ?y) (content boat))
	(boat-ver (y ?y) (xs $? ?x))
	(not (k-cell (x ?x) (y ?y) ) )
=>
	(assert (k-cell (x ?x) (y ?y) (content bot)))
	(assert (resetted ?x ?y))
)

(defrule make-visible-middle (declare (salience 5))
	(fire ?x ?y)
	(cell (x ?x) (y ?y) (content boat))
	(not (k-cell (x ?x) (y ?y) ) )
=>
	(assert (k-cell (x ?x) (y ?y) (content middle)))
	(assert (resetted ?x ?y))
)


(defrule make-visible-water (declare (salience 5))
	(fire ?x ?y)
	(cell (x ?x) (y ?y) (content water))
	(not (k-cell (x ?x) (y ?y) ) )
=>
	(assert (k-cell (x ?x) (y ?y) (content water)))
	(assert (resetted ?x ?y))
)


