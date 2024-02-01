(defmodule DELIBERATION (import AGENT ?ALL) (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

;------------ FATTI -----------------------------

; (defrule prova 
;   ?f <- (cell-agent (x 0)(y 0))
; =>
;   (modify ?f (status guess))
;   (pop-focus)
; )