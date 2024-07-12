# Intelligenza Artificiale e Laboratorio - Planning e Sistemi a Regole

## Indice:

- [Progetto d'esame: Battaglia Navale singolo giocatore in linguaggio CLIPS](#progetto-desame-battaglia-navale-singolo-giocatore-in-linguaggio-clips)
- [Pre-requisiti](#pre-requisiti)
- [Descrizione del sistema esperto sviluppato](#descrizione-del-sistema-esperto-sviluppato)
  - [Descrizione moduli](#descrizione-moduli)
  - [Descrizione stati](#descrizione-stati)
  - [Salience](#salience)
- [Implementazione](#implementazione)
  - [Agent](#agent)
  - [Init](#init)
  - [Update Knowledge Control](#update-knowledge-control)
  - [Deliberation](#deliberation)
    - [Sistema esperto dump](#sistema-esperto-dump)
    - [Sistema esperto intelligente](#sistema-esperto-intelligente)
  - [Action](#action)
- [Formule del progetto](#formule-del-progetto)
  - [Formula probabilità su singola cella](#formula-probabilità-su-singola-cella)
  - [Formula ultima discesa](#formula-ultima-discesa)
  - [Formula original score (probabilità a priori)](#formula-original-score-probabilità-a-priori)

## Progetto d'esame: Battaglia Navale singolo giocatore in linguaggio CLIPS

(docente: Roberto Micalizio)

L'obiettivo del progetto è quello di sviluppare un sistema esperto che giochi ad una versione semplificata della famigerata *Battaglia Navale*.

Come di consueto le navi da individuare sono le seguenti:

- **1 corazzata** da **4 caselle**
- **2 incrociatori** da **3 caselle** ciascuno
- **3 cacciatorpedienieri** da **2 caselle** ciascuno
- **4 sottomarinieri** da **1 casella** ciascuno

Nel documento [progetto_CLIPS-2022-2023.pdf](progetto%20CLIPS%20-%202022-2023.pdf) è possibile reperire la traccia completa.

## Pre-requisiti

E' necessaria l'installazione di **CLIPS** presso il [sito ufficile](https://www.clipsrules.net/).
Per questo progetto è stata utilizzata la versione **6.4.1**.
> **NOTA**: I risultati potrebbero variare nella versione precedente a causa di implementazioni diverse. Principalmente è dovuta alla gestione della rifrazione.

## Descrizione del sistema esperto sviluppato

> **NOTA**: I link in questa sezione fanno riferimento al [6_Deliberation_dump.cl](./battle-2023/6_Delib_dump.clp) solo come esempio. Il funzionamento rimane invariato anche in [6_Deliberation_intelligent.cl](./battle-2023/6_Delib_intelligent.clp).

### Descrizione Moduli

I sistemi esperti implementati hanno i seguenti MODULI:

- **Moduli di sistema pre-implementati**:

  - [MAIN](./battle-2023/0_Main.clp): gestisce lo **SCHEDULING** tra i moduli dI **AGENT** e i moduli del sistema pre-implementati(**MAIN** e **ENV**);
  - [ENV](./battle-2023/1_Env.clp): gestisce la **CONOSCENZA DI DOMINIO** in caso di eventi provenienti dagli agenti.
- **Moduli degli agenti**:

  - [AGENT](./battle-2023/3_Agent.clp): come il Main per l'ambiente, gestisce lo scheduling tra i moduli all'interno degli agenti
  - [INIT](./battle-2023/4_Init.clp): inizializza la **CONOSCENZA DI CONTROLLO** travasando la **CONOSCENZA DI DOMINIO** all'interno di essa. Viene utilizzato solo al primo avvio dell'agente.
  - [UPDATE KNOWLEDGE CONTROL](./battle-2023/5_Update_KC.clp): ha il compito di aggiornare la CONOSCENZA DI CONTROLLO ogni qualvolta che viene eseguita un'azione sull'ambiente. Gestisce il **FRAME PROBLEM** all'interno di questo dominio.
  - [DELIBERATION (DUMP)](./battle-2023/6_Delib_dump.clp): gestisce la strategia di deliberazione **dump**, ossia senza particolare intelligenza. Quando arriva al fondo di una ricerca senza aver impostato tutte le *guess*, fa backtracking fino all'ultima azione GREEDY e ramifica la ricerca verso un altro ramo.
  - [DELIBERATION (INTELLIGENT)](./battle-2023/6_Delib_intelligent.clp): gestisce la strategia di deliberazione **intelligente**, ossia effettuando il backtracking informato. Questo consiste nella ricerca della casella con il punteggio maggiore iniziale all'interno delle caselle in stato [EXPLORE](./battle-2023/6_Delib_dump.clp#L536).

### Descrizione Stati

I sistemi esperti implementati hanno degli STATI, composti da **fatti ordinati**. Sono stati definiti all'interno dei moduli di [DELIBERATION](./battle-2023/6_Delib_dump.clp) sono stati definiti i seguenti stati:

- [GREEDY](./battle-2023/6_Delib_dump.clp#L13): vengono eseguite le *guess* proveniente da una conoscenza pregressa avuta input, oppure viene effettuata una RICERCA INFORMATA posizionando da subito delle *fire* e restringere lo SPAZIO DI RICERCA MENO INFORMATO;
- [EXPLORE](./battle-2023/6_Delib_dump.clp#L536): entriamo in uno SPAZIO DI RICERCA MENO INFORMATO, in cui posizioniamo le *guess* al meglio che possiamo, sfruttando le regole di risoluzione definite nei MODULI di DELIBERAZIONE;
- **BACKTRACKING**: vengono effettuate le *unguess* sulla base delle scelte prese nella fase di ricerca [EXPLORE](./battle-2023/6_Delib_dump.clp#L536). Le regole di attuazione del backtracking variano nei due moduli di DELIBERAZIONE:
  - [BACKTRACKING INFORMATO](./battle-2023/6_Delib_intelligent.clp#L571): viene trovata, nella regolare una RADICE come limite di backtracking. Viene scelta sulla base della [minore probabilità iniziale](#formula-probabilità-su-singola-cella) che hanno tutte le celle su cui è stata eseguita la *guess* in stato di [EXPLORE](./battle-2023/6_Delib_dump.clp#L536). Verranno di seguito effettuale le *unguess* fino alla radice trovata.
  > **NOTA**: viene mantenuto questo dato in ogni singola cella della *CONOSCENZA DI CONTROLLO*.
  >
  - [BACKTRACKING NON INFORMATO](./battle-2023/6_Delib_dump.clp#L604): viene effettuato il backtracking fino alla radice che corrisponde alla prima *guess* posizionata in fase [EXPLORE](./battle-2023/6_Delib_dump.clp#L536).
- [SOLVE](./battle-2023/6_Delib_dump.clp#L640): ultimo stato in cui viene mandato all'ambiente il comando di *solve* per terminare la ricerca.

### Salience

Non è stato implementato un vero e proprio criterio univoco per tutti i moduli in merito alla scelta delle salience. Si è cercato di rispettare l'offset di 5/10 come punteggio di salience tra parti di esecuzioni eseguite (i.e. [RICERCA CORAZZATA](./battle-2023/6_Delib_dump.clp#L43) con regole di salience 100 e  [RICERCA INCROCIATORI](./battle-2023/6_Delib_dump.clp#L147) con regole di salience 95).
Anche se sono state fissate in un certo ordine numerico, il passaggio di stato nella ricerca è guidato da moduli e fatti ordinati (trattato in [descrizione degli stati](#descrizione-stati)).

## Implementazione

### Agent

Il modulo [AGENT](./battle-2023/3_Agent.clp) è responsabile dello scheduling di esecuzione tra i differenti moduli dell'agente.

**FATTI NON ORDINATI**:

- [cell-agent](./battle-2023/3_Agent.clp#L8): copia del template [cell](./battle-2023/1_Env.clp#L7) del module [ENV](./battle-2023/1_Env.clp) con l'aggiunta dello score (calcolato con la [formula della probabilità](#formula-probabilità-su-singola-cella)) e dell'[original-score](./battle-2023/3_Agent.clp#L14), mantenendo lo score calcolato all'inizio necessario per l'esecuzione del [BACKTRACKING INFORMATO](README.md#descrizione-stati). E' un fatto non ordinato mantenuto nella *CONOSCENZA DI CONTROLLO*.
- [k-per-row-agent](./battle-2023/3_Agent.clp#L17): copia del template [k-per-row](./battle-2023/1_Env.clp#L54) del module [ENV](./battle-2023/1_Env.clp). Rappresenta il numero di celle occupate da una nave su singola riga. E' un fatto non ordinato mantenuto nella *CONOSCENZA DI CONTROLLO*.
- [k-per-col-agent](./battle-2023/3_Agent.clp#L23): copia del template [k-per-col](./battle-2023/1_Env.clp#L59) del module [ENV](./battle-2023/1_Env.clp). Rappresenta il numero di celle occupate da una nave su singola colonna. E' un fatto non ordinato mantenuto nella *CONOSCENZA DI CONTROLLO*.
- [exec-agent](./battle-2023/3_Agent.clp#L29): copia del template [exec](./battle-2023/0_Main.clp#L5) del module [MAIN](./battle-2023/0_Main.clp). Rappresenta la mossa eseguita al passo *?step*. E' un fatto non ordinato mantenuto nella *CONOSCENZA DI CONTROLLO*.
- [boat-agent](./battle-2023/3_Agent.clp#L45): Rappresenta una nave specifica a cui viene assegnato un codice univoco. Sarà necessario per inizializzare le navi nella *CONOSCENZA DI CONTROLLO* e verificare, nei moduli successivi, se sono state affondate o meno facendo pattern matching con le celle. Soluzione blind, non vengono riportate le celle ma solo il tipo di nave.
- [update-score-row](./battle-2023/3_Agent.clp#L67): Serve al modulo [UPDATE_KC](./battle-2023/5_Update_KC.clp) per aggiornare gli score sulla riga in cui è stata effettuata un'azione. Mantiene le celle aggiornate nella *CONOSCENZA DI CONTROLLO*.
- [update-score-col](./battle-2023/3_Agent.clp#L72): Serve al modulo [UPDATE_KC](./battle-2023/5_Update_KC.clp) per aggiornare gli score sulla colonna in cui è stata effettuata un'azione. Mantiene le celle aggiornate nella *CONOSCENZA DI CONTROLLO*.

**FATTI ORDINATI**:

- [first-pass-to-init](./battle-2023/3_Agent.clp#L82): questo fatto ordinato permette di passare l'esecuzione una volta sola al modulo di [INIT](./battle-2023/4_Init.clp), che inizializzerà la CONOSCENZA DI CONTROLLO.

**REGOLE**: le regole permettono di passare l'esecuzione nell'ordine corretto tra i moduli [INIT](./battle-2023/4_Init.clp), [UPDATE_KC](./battle-2023/5_Update_KC.clp), [DELIBERATION](./battle-2023/6_Delib_dump.clp) e [ACTION](./battle-2023/7_Action.clp).

### Init

Il modulo [INIT](./battle-2023/4_Init.clp) è responsabile di create TUTTI i FATTI INIZIALI nella *CONOSCENZA DI CONTROLLO*. Oltre ciò, verifica lo stato delle celle se, all'interno dell'ambiente, dovesse esserci della conoscenza, e riporta la medesima all'interno dei propri fatti inizializzati.

**REGOLE**:

- [init-*](./battle-2023/4_Init.clp#L9): i fatti con radice *init* inizializzano i fatti [cell-agent](./battle-2023/3_Agent.clp#L8), [k-per-row-agent](./battle-2023/3_Agent.clp#L17) e [k-per-col-agent](./battle-2023/3_Agent.clp#L23) nella *CONOSCENZA DI CONTROLLO*.
- [update-cell-water](./battle-2023/4_Init.clp#L53): vado ad aggiornare il contenuto delle cell-agent presente nella *CONOSCENZA DI CONTROLLO* se la k-cell, presente nella *CONOSCENZA DI DOMINIO*, contiene *water*.
- [add-water-cell](./battle-2023/4_Init.clp#L65): contrassegna tutte le caselle in cui la moltiplicazione tra l'indice di possibili navi nella riga e l'indice nella colonna sia uguale a zero, ossia quando sicuramente non potrà esserci una nave ma solo *water*.
- [fill-neighbor-*](./battle-2023/4_Init.clp#L77): le regole con la radice *fill-neighbor* aggiungono *water* ai lati dei pezzi delle navi quando sono sicuro che non potrà esserci altro. Es. se ho un pezzo di nave *top*, sopra di essa ci sarà sicuramente *water*.

### Update Knowledge Control

Questo [modulo](./battle-2023/5_Update_KC.clp) è responsabile di aggiornare la *CONOSCENZA DI CONTROLLO*, riportando le modifiche fatte allo STEP PRECEDENTE, prima di deliberare la prossima azione.

**FATTI NON ORDINATI:**

- [tmp-exec-agent](./battle-2023/5_Update_KC.clp#L7): copia del template [exec-agent](./battle-2023/3_Agent.clp#L29) del module [AGENT](./battle-2023/3_Agent.clp).

**FATTI ORDINATI:**

- [update-neighbor-guess]: fatto asserito nelle prime regole del modulo come *STATO* di aggiornamento dopo aver effettuato un'azione di *guess*.
- [update-neighbor-fire]: fatto asserito nelle prime regole del modulo come *STATO* di aggiornamento dopo aver effettuato un'azione di *fire*.

**REGOLE:**

- [update-kc-fire-cell-agent-water](./battle-2023/5_Update_KC.clp#L37): se l'azione eseguita allo step precedente è una *fire* e la cella su cui è stata effettuata riporta *water* come risultato, allora andrò ad aggiornare la cella nella *CONOSCENZA DI CONTROLLO* (se becco water sulla fire, copio solo il contenuto).
- [update-kc-guess-cell-agent](./battle-2023/5_Update_KC.clp#L49): a seguito di una *guess* **SENZA CONTENUTO** aggiorniamo SOLO lo status a *guess* della cella nella *CONOSCENZA DI CONTROLLO*.
- [update-kc-guess-cell-agent-else](./battle-2023/5_Update_KC.clp#L67): a seguito di una *guess* **CON CONTENUTO**, aggiorniamo il contenuto e lo status a *know* della cella nella *CONOSCENZA DI CONTROLLO*.
- [update-kc-\<nome-nave>](./battle-2023/5_Update_KC.clp#L231): le regole con questa radice si attiveranno quando verranno rilevati dei pezzi di navi che sicuramente formano una nave. Verranno aggiornate le loro celle a score negativo e verrà rimossa dalla *CONOSCENZA DI CONTROLLO* la nave trovata.
- [add-water-after-fire-*](./battle-2023/5_Update_KC.clp#L177): le regole con questa radice si attiveranno a seguito di una *fire* per andare a posizionare *water* nelle celle adiacenti al pezzo di nave trovato. Es. sopra un *top* vi sarà necessariamente *water* in alto, a destra e a sinistra.
- [update-kc-scores-*](./battle-2023/5_Update_KC.clp#L319): verranno aggiornati gli score delle righe/colonne che hanno subito modifiche a seguito di un ritrovamento di un pezzo di nave.
- [finish-update-kc-score-*](./battle-2023/5_Update_KC.clp#L355): una volta finito l'aggiornamento degli score effettuato da *update-kc-scores-\**, ferma l'aggiornamento ritrattando il fatto.
- [update-kc-garbage-*](./battle-2023/5_Update_KC.clp#L368): le regole con questa radice eliminano il *garbage* creato dai fatti ordinati, necessari per aggiornare lo stato ed il contenuto delle celle.

### Deliberation

Tramite le regole di risoluzione sviluppate nel seguente progetto, viene proposta l'implementazione di **due sistemi esperti**:

- [Dump](#sistema-esperto-dump)
- [Intelligent](#sistema-esperto-intelligente)

A livello implementativo, i due sistemi si distinguono SOLO nel modulo di **DELIBERATION**, andando a modificare le due strategie di deliberazione delle azioni intraprese.

**FATTI ORDINATI:**

- [state-dfs](./battle-2023/6_Delib_dump.clp#L18): questo fatto rappresenta lo *STATO* in cui si trova il modulo di *DELIBERATION* in fase di deliberazione dell'azione. Sono tre i possibili valori:
  - [greedy](./battle-2023/6_Delib_dump.clp#L18): stato di ricerca [GREEDY](#descrizione-stati).
  - [explore](./battle-2023/6_Delib_dump.clp#L542): stato di ricerca [EXPLORE](#descrizione-stati)
  - [backtracking](./battle-2023/6_Delib_dump.clp#L599): stato di ricerca [BACKTRACKING](#descrizione-stati)
  - [solve](./battle-2023/6_Delib_dump.clp#L646): stato di ricerca [SOLVE](#descrizione-stati)

**FATTI NON ORDINATI:**

- [root-backtracking](./battle-2023/6_Delib_dump.clp#L5): template definito in fase di [EXPLORE](./battle-2023/6_Delib_dump.clp#L536)

**REGOLE:**

- [enter-in-\<name-state>-state](./battle-2023/6_Delib_dump.clp#L15): permette, secondo determinate precondizioni, di passare da uno stato all'altro quando non ci sono più regole attivabili in agenda per una determinata fase di ricerca;
- [find-guess-with-k-cell](./battle-2023/6_Delib_dump.clp#L22): delibera le guess sicure. (es. dopo aver effettuato la *fire* nello step precedente, si attiverà la seguente regola dal momento che apparirà un fatto *k-cell* su una determinata cella)
- [find-guess-*](./battle-2023/6_Delib_dump.clp#L33): le regole di deliberazione del sistema esperto cercano di completare prima le navi più grandi, usando la salience per dare priorità alle guess che completano le navi con più pezzi, soprattutto quando mancano pochi pezzi per affondarle. Questo approccio aiuta a ridurre il numero di guess casuali e a velocizzare la ricerca delle navi.
- [find-cell-fire](./battle-2023/6_Delib_dump.clp#L519): la regola delibera una fire in fase di GREEDY, creando una base di conoscenza prima passare alla fase di [EXPLORE](./battle-2023/6_Delib_dump.clp#L536).
- [find-cell-guess-after-backtracking](./battle-2023/6_Delib_dump.clp#L547): delibera una guess dopo aver trovato un root-backtracking, ossia la radice da cui proseguire la ricerca nello spazio degli stati.
- [find-cell-guess](./battle-2023/6_Delib_dump.clp#L564): delibera una guess basandosi sul punteggio di scores più alto.
- [find-unguess-backtracking](./battle-2023/6_Delib_dump.clp#605): delibera le unguess in fase di BACKTRACKING finché non arriva alla cella corrispondente alla *root-backtracking*.
- [resolution](./battle-2023/6_Delib_dump.clp#L648): si attiva quando non ci sono più azioni possibili da deliberare o si è passati direttamente alla fase di *SOLVE*.

>**NOTA**: le regole della fase di ricerca *SOLVE* sono state definite con salience **NEGATIVA** per essere eseguite *SOLO* alla fine della ricerca (o, eventualmente quando la ricerca viene indirizzata in questa fase).

#### Sistema esperto dump

Il sistema esperto Dump attua la sua ricerca con una strategia **brute force** finchè ha *guess* da eseguire.
La strategia, dopo aver terminato lo stato GREEDY, esegue i seguenti passi:

1. Si posizionano, nella fase di [EXPLORE](./battle-2023/6_Delib_dump.clp#L536), tutte le *guess* possibili facendosi guidare dalle [probabilità](#formula-probabilità-su-singola-cella) create per singola cella
2. Una volta posizionate tutte le *guess* possibili, si controlla se ce ne siano ancora:

   - se ci sono ancora *guess* a disposizione, si entra nello stato di [BACKTRACKING NON INFORMATO](#descrizione-moduli) effettuando le *unguess* su tutte le mosse eseguite nello stato di [EXPLORE](./battle-2023/6_Delib_dump.clp#L536);
   - altrimenti, se non restano abbastanza mosse, l'agente viene mandato in stato di [SOLVE](./battle-2023/6_Delib_dump.clp#L640).

**REGOLE:**

- [define-root](./battle-2023/6_Delib_dump.clp#580): trova la radice (root-backtracking), ossia la cella con la *prima guess* in  fase di [EXPLORE](./battle-2023/6_Delib_dump.clp#L536). Sarà il lower bound della fase di BACKTRACKING.
- [remain-last-path](./battle-2023/6_Delib_dump.clp#580): si attiva per effettuare il passaggio di stato in *SOLVE* quando il numero di mosse sta per terminare e l'agente non riuscirebbe ad effettuare una risalita ed una discesa completa (formula di riferimento in [formula ultima discesa](#formula-ultima-discesa)).

#### Sistema esperto Intelligente

Nel sistema esperto intelligente è stata proposta una soluzione che integra al suo interno dell'intelligenza, ossia un BACKTRACKING INFORMATO.
La strategia, dopo aver terminato lo stato GREEDY, esegue i seguenti passi:

1. Si posizionano, nella fase di [EXPLORE](./battle-2023/6_Delib_dump.clp#L536), tutte le *guess* possibili facendosi guidare dalle [probabilità](#formula-probabilità-su-singola-cella) create per singola cella
2. Una volta posizionate tutte le *guess* possibili, si controlla se ce ne siano ancora:

   - se ci sono ancora *guess* a disposizione, si entra nello stato di [BACKTRACKING INFORMATO](#descrizione-moduli), risalendo fino alla radice con la minore probabilità iniziale trovata;
   - altrimenti, se non restano abbastanza mosse da eseguire viene fatta scattare la regola di [remain-last-path](./battle-2023/6_Delib_intelligent.clp#L628) e l'agente viene mandato in stato di [SOLVE](./battle-2023/6_Delib_intelligent.clp#L639).

**REGOLE:**

- [define-min-guess-to-unguess](./battle-2023/6_Delib_intelligent.clp#L572): trova la radice (root-backtracking), ossia la cella con la [probabilità a priori più alta](#formula-original-score-probabilità-a-priori) in  fase di *EXPLORE*. Sarà il lower bound della fase di BACKTRACKING.
- [check-solve-root-backtracking](./battle-2023/6_Delib_intelligent.clp#L594): condizione di uscita quando la radice è l'ultimo nodo su cui eseguire il backtracking.

### Action

Il modulo [ACTION](./battle-2023/7_Action.clp) ha il compito di controllare se nella *CONOSCENZA DI CONTROLLO* è stata deliberata un'azione di exec (tramite il template *exec-agent*) e di che tipologia di azione si tratta. Fatto ciò, manderà l'azione di *exec* al modulo di [AGENT](./battle-2023/3_Agent.clp). Una volta fatto ciò, verrà eseguita l'azione sull'ambiente.
Questo modulo ha con sè delle regole che si attivano in base alla tipologia di *action* (*fire*, *guess*, *unguess* e *solve*).

**REGOLE**:

- [exec-action-\<name-action>](./battle-2023/7_Action.clp#L5): il modulo è responsabile di modificare l'azione, attuandola nella *CONOSCENZA DI DOMINIO*.

## Formule del progetto

### Formula Probabilità su singola cella

I sistemi esperti sviluppati sono guidati durante la loro ricerca dalla **PROBABILITA'** sulle singole celle. Di seguito, il calcolo della formula:

$Prob.Cella = (NPRiga) * (NPColonna)$

con:

$Prob.Cella$ = Probabilità di un pezzo di nave per singola cella

$NPRiga$ = Numero di pezzi di navi possibili in quella riga

$NPColonna$ = Numero di pezzi di navi possibili in quella colonna

### Formula ultima discesa

Nei due sistemi esperti viene calcolata la seguente formula:

$MaxDuration >= StepAttuale + 2 * NGuessRimanenti$

con:

$MaxDuration$ = Numero massimo di azioni che l'agente può eseguire

$StepAttuale$ = Step attuale di ricerca

$NGuessRimanenti$ = Numero di *guess* rimanenti

Questa formula è necessaria per evitare lo stato di BACKTRACKING nel momento in cui l'agente non ha a disposizione almeno $2 * NGuessRimanenti$ da poter eseguire per effettuare una risalita (stato BACKTRACKING) e una nuova discesa (stato [EXPLORE](#descrizione-stati)).

### Formula original score (probabilità a priori)

All'interno di [cell-agent](./battle-2023/3_Agent.clp#L8) possiamo trovare il valore di **original-score**. Questo viene calcolato come la [formula della probabilità su una singola cella](#formula-probabilità-su-singola-cella) ma, essendo una **PROBABILITÀ A PRIORI**, viene calcolata solo la prima volta e poi persiste fino alla fine dell'esecuzione.
