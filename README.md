# VTOL Skywalker X8 Simulation Framework

Questo framework fornisce un ambiente di simulazione completo per un drone VTOL (Vertical Take-Off and Landing) basato sul modello **Skywalker X8**. Utilizza **ArduPilot** come autopilota, **Gazebo Harmonic** come motore fisico e **Pixi** per la gestione del workflow e delle dipendenze.

L'intero ambiente è containerizzato in Docker per garantire la massima compatibilità e facilità di installazione.

## 📋 Prerequisiti

-   **Sistema Operativo:** Ubuntu 22.04 LTS (raccomandato).
    
-   **Docker & Docker Compose:** Installati e configurati.
    
-   **Server X11:** Per la visualizzazione dell'interfaccia grafica di Gazebo (già presente di default su Ubuntu).
    

## 🚀 Installazione Rapida

### 1. Clonazione del repository

Bash

```
git clone https://github.com/LucaBricarello/vtol-gazebo-env.git
cd vtol-gazebo-env

```

### 2. Configurazione permessi grafici e avvio

Prima di avviare il container, è necessario permettere a Docker di accedere al server X11 per mostrare la finestra di Gazebo:

Bash

```
xhost +local:docker
docker compose up -d --build

```

### 3. Primo Accesso e Compilazione

Entra nel container per compilare ArduPilot e i plugin necessari:

Bash

```
docker exec -it gazebo_ardupilot_env bash

```

All'interno del container, esegui i seguenti blocchi di comandi:

**Compila ArduPilot:**

Bash

```
pixi install
cd ardupilot
./waf configure --board sitl
./waf plane

```

**Compila il plugin di Gazebo:**

Bash

```
cd ../ardupilot_gazebo
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
make -j4
cd /workspace

```

----------

## ✈️ Come avviare la simulazione

Per far volare il drone sono necessari due terminali separati all'interno del container.

### Terminale 1: Il Mondo (Gazebo)

Avvia il simulatore fisico con il modello dello Skywalker X8:

Bash

```
docker exec -it gazebo_ardupilot_env bash
gz sim -v4 -r skywalker_x8_quad_runway.sdf

```

### Terminale 2: Il Cervello (ArduPilot in SITL)

In un nuovo terminale sul tuo PC host, avvia l'autopilota:

Bash

```
docker exec -it gazebo_ardupilot_env bash

# Sostituisci con l'IP della tua macchina dove gira Mission Planner
export GCS_IP="192.168.1.80" 

# Avvia il SITL (Software In The Loop)
pixi run sitl_x8

```

----------

## 🎮 Interazione con Mission Planner (Windows/Host)

Il simulatore è configurato per inviare i dati di telemetria all'esterno del container. Puoi collegarti usando **Mission Planner** da un PC Windows o dalla stessa macchina host (sconsigliato, Mission Planner non gira nativamente su Ubuntu, bisognerebbe usare MONO per farlo girare):

1.  Apri Mission Planner.
    
2.  In alto a destra, seleziona come tipo di connessione **UDP**.
    
3.  Clicca su **Connect**.
    
4.  Inserisci la porta di default: `14550`.

> **Nota:** su sistema Ubuntu si potrebbe pensare di usare QGroundControl che funziona nativamente (non testato, ma dovrebbe funzionare)
    

### Configurazione per Volo Autonomo

Per eseguire una missione completa (Decollo Verticale -> Volo -> Atterraggio Verticale), segui questi punti chiave su Mission Planner:

-   **Verifica Parametri:** Assicurati che `Q_ENABLE` sia impostato a `1` e `SERVO1_FUNCTION`/`SERVO2_FUNCTION` siano impostati come `ElevonLeft` ed `ElevonRight` (77 e 78).
    
-   **Creazione Missione:** 1. Il primo comando **deve** essere `VTOL_TAKEOFF`. 2. Aggiungi i `WAYPOINT` per la navigazione aerea. 3. Concludi con il comando `VTOL_LAND`.
    
-   **Esecuzione:** Passa in modalità **AUTO** e arma il drone.
