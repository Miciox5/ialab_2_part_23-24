(dribble-on result.txt)
(load 0_Main.clp)
(load 1_Env.clp)
REM (load mapEnvironment-0.clp)
(load mapEnvironment-1.clp)
(load 3_Agent.clp)
(load 4_Init.clp)
(load 5_Update_KC.clp)
(load 6_Delib.clp)
(load 7_Action.clp)
(reset)
@REM Il watch focus è molto utile per capire l'esecuzione dei moduli
@REM nello stack.
(watch focus)
(watch rules)
@REM Il comando dribble-on serve per mettere il risultato
@REM delle prossime esecuzioni nel file result.txt
(run)
@REM (facts MAIN)
(facts AGENT)
(exit)

