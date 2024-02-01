(defmodule INIT (import AGENT ?ALL) (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))


;------------ REGOLE -----------------------------

(defrule init-cells (declare (salience 100)) 
	(status (step ?s)(currently running))
	(k-per-row (row ?r) (num ?n))
	(k-per-col (col ?c) (num ?n1))
=> 
	(assert (cell-agent (x ?r) (y ?c) (status none)))
)

(defrule init-rows (declare (salience 100)) 
	(status (step ?s)(currently running))
	(k-per-row (row ?r) (num ?n))
=> 
	(assert (k-per-row-agent (row ?r) (num ?n)))
)

(defrule init-cols (declare (salience 100)) 
	(status (step ?s)(currently running))
	(k-per-col (col ?c) (num ?n1))
=> 
	(assert (k-per-col-agent (col ?c) (num ?n1)))
)

(defrule finish-init(declare (salience 90)) 
    (status (step ?s)(currently running))
    =>
    (pop-focus)
)