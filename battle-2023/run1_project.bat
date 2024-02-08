(load 0_Main.clp)
(load 1_Env.clp)
(load mapEnvironment.clp)
(load 3_Agent.clp)
(load 4_Init.clp)
(load 5_Delib.clp)
(load 6_Action.clp)
(reset)
@REM Il watch focus è molto utile per capire l'esecuzione dei moduli
@REM nello stack.
(watch focus)
(watch rules)
(set-break game-over)
(run)
(run 2)
@REM Il comando dribble-on serve per mettere il risultato
@REM delle prossime esecuzioni nel file result.txt
(dribble-on result1.txt)
(focus ENV)
(run)
(facts)
(exit)
