(defmodule UPDATE_KC (import AGENT ?ALL) (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))


;------------ TEMPLATE ---------------------------


;---------------- REGOLE ------------------------------------------


;---------------UPDATE KNOWLEDGE CONTROL--------------------------------------

;   Se ho top-middle-bot ho trovato un incrociatore -> aggiorno base conoscenza 
;   (setto gli score a 0 cosi la regola non si attiva per tutti gli altri fatti boat-agent(content incrociatore))
(defrule update-kb-incrociatore-ver (declare (salience 90)) 
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


;  Se ho un sub aggiorno la base di conoscenza (aggiunta la condizione sullo score per non farlo attivare sugli altri fatti)
(defrule update-kb-sottomarino (declare (salience 55)) 
   ?cell <- (cell-agent (x ?x) (y ?y) (content sub) (score ?s&:(> ?s 0)) )
   ?sub <- (boat-agent (name sottomarino))
   =>
   (modify ?cell (score 0))
   (retract ?sub)
)