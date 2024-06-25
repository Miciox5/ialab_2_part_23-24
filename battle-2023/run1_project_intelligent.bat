(dribble-on result1.txt)
(load 0_Main.clp)
(load 1_Env.clp)
@REM (load mapEnvironment-1.clp)
(load mapEnvironment-0.clp)
(load 3_Agent.clp)
(load 4_Init.clp)
(load 5_Update_KC.clp)
(load 6_Delib_intelligent.clp)
(load 7_Action.clp)
(reset)
@REM Il watch focus è molto utile per capire l'esecuzione dei moduli
@REM nello stack.
@REM (watch focus)
@REM (watch rules)
(set-break game-over)
(run)
(run 2)
@REM Il comando dribble-on serve per mettere il risultato
@REM delle prossime esecuzioni nel file result.txt
(focus ENV)
(run)
(facts)
(exit)
