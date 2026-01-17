# SAfeGuard - Sistema Integrato per la Gestione delle Emergenze

**Repository Ufficiale:** [https://github.com/SAfeGuard2025/SAfeGuard](https://github.com/SAfeGuard2025/SAfeGuard)

## Indice

1. [Panoramica del Progetto](#panoramica-del-progetto)
2. [Obiettivi e Scopo](#obiettivi-e-scopo)
3. [Architettura del Sistema](#architettura-del-sistema)
4. [Funzionalità e Moduli](#funzionalità-e-moduli)
5. [Stack Tecnologico](#stack-tecnologico)
6. [Guida all'Installazione e Configurazione](#guida-allinstallazione-e-configurazione)
7. [Struttura del Repository](#struttura-del-repository)
8. [Team di Sviluppo](#team-di-sviluppo)

-----

## Panoramica del Progetto

**SAfeGuard** è un ecosistema software mobile-first sviluppato per ottimizzare la gestione delle calamità naturali e delle operazioni di soccorso nella provincia di Salerno. Il progetto nasce come risposta accademica e tecnica alle inefficienze dei sistemi di allerta tradizionali, proponendo una piattaforma unitaria che garantisce un flusso informativo bidirezionale tra la popolazione civile e gli enti di soccorso (Vigili del Fuoco, Protezione Civile).

Il sistema integra tecnologie di geolocalizzazione avanzata, protocolli di comunicazione resilienti (SMS fallback) e moduli di Intelligenza Artificiale per l'analisi predittiva e la gestione del rischio in tempo reale.

## Obiettivi e Scopo

L'obiettivo primario di SAfeGuard è la salvaguardia della vita umana. Il sistema è progettato per:

* **Ridurre i tempi di intervento:** Fornendo ai soccorritori la posizione esatta delle richieste di aiuto.
* **Minimizzare il carico operativo:** Filtrando le segnalazioni non critiche tramite la funzione "Safe Check".
* **Garantire la continuità operativa:** Assicurando la comunicazione anche in assenza di rete dati internet.
* **Analizzare i dati:** Sfruttando l'IA per identificare cluster di rischio e ottimizzare la distribuzione delle risorse sul territorio.

## Architettura del Sistema

Il sistema adotta un'architettura **Client-Server** scalabile, basata su pattern architetturali moderni per garantire manutenibilità e sicurezza.

1.  **Frontend Mobile (Flutter):** Un'applicazione cross-platform che implementa un'interfaccia utente adattiva. Il sistema riconosce il ruolo dell'utente (Cittadino o Soccorritore) in fase di login e adatta dinamicamente le funzionalità e la UX.
2.  **Backend Server (Dart con Shelf):** Un server RESTful che funge da gateway per l'autenticazione, la gestione della logica di business e l'orchestrazione delle notifiche push.
3.  **Data Persistence (Firebase Firestore):** Database NoSQL orientato ai documenti per la sincronizzazione dei dati in tempo reale tra i dispositivi e il centro di controllo.
4.  **AI Microservice (Python):** Un modulo computazionale esterno dedicato all'elaborazione dei dati geospaziali per la generazione di mappe di calore (Hotspots) relative al rischio.

## Funzionalità e Moduli

### Modulo Cittadino (User Side)

* **SOS One-Tap:** Invio immediato di richiesta di soccorso con coordinate GPS ad alta precisione.
* **Safe Check:** Segnalazione rapida dello stato "Sto Bene" per aggiornare la mappa operativa dei soccorritori.
* **Offline Resilience:** In caso di assenza di connessione internet, l'app compone automaticamente un SMS strutturato contenente i dati vitali e la posizione, inviandolo al server centrale.
* **Privacy by Design:** Il tracciamento della posizione si attiva esclusivamente durante una fase di emergenza attiva o all'invio di un SOS.
* **Cartella Clinica Digitale:** Gestione locale di dati sensibili (gruppo sanguigno, allergie, farmaci) condivisi con i soccorritori solo in caso di necessità.

### Modulo Soccorritore (Rescuer Side)

* **Dashboard GIS:** Visualizzazione su mappa interattiva di tutte le richieste attive, con clusterizzazione per densità.
* **Prioritizzazione:** Distinzione visiva immediata tra codici di emergenza (SOS) e segnalazioni di sicurezza (Safe Check).
* **Gestione Log Operativi:** Registrazione automatica degli eventi e generazione di report PDF conformi agli standard legali per l'analisi post-intervento.
* **Analisi AI:** Visualizzazione dei layer di rischio generati dall'intelligenza artificiale per supportare il processo decisionale.

## Stack Tecnologico

| Ambito | Tecnologia | Dettagli |
| :--- | :--- | :--- |
| **Frontend** | Flutter | Framework UI per sviluppo cross-platform. |
| **Language** | Dart | Linguaggio fortemente tipizzato per client e server. |
| **State Mgmt** | Provider | Gestione dello stato applicativo (MVVM). |
| **Workspace** | Melos | Gestione del monorepo e dei pacchetti locali. |
| **Backend** | Shelf | Middleware per server Dart modulare. |
| **Database** | Firestore | Database NoSQL real-time. |
| **Auth** | JWT / OAuth | Gestione sicura delle sessioni (Google, Apple). |
| **Maps** | Flutter Map | Rendering cartografico OpenStreetMap. |

## Guida all'Installazione e Configurazione

Questa sezione descrive come configurare l'ambiente di sviluppo locale. Il progetto utilizza **Melos** per la gestione del workspace.

### Prerequisiti

* Flutter SDK (Versione Stable 3.x)
* Dart SDK
* Melos (`dart pub global activate melos`)
* Account Firebase attivo

### 1\. Clonazione e Inizializzazione

Clonare il repository e inizializzare il workspace con Melos per collegare i pacchetti locali e installare le dipendenze.

```bash
git clone https://github.com/SAfeGuard2025/SAfeGuard.git
cd SAfeGuard

# Inizializzazione del monorepo e linking delle dipendenze
melos bootstrap
```

### 2\. Generazione Risorse (Icone e Splash Screen)

Per rigenerare le icone dell'applicazione e le schermate di avvio (Splash Screen) secondo le configurazioni definite in `pubspec.yaml`, eseguire i seguenti comandi:

```bash
# Generazione della Splash Screen nativa
dart run flutter_native_splash:create

# Generazione delle icone di lancio
dart run flutter_launcher_icons
```

### 3\. Configurazione del Backend

Navigare nella directory del backend e configurare le variabili d'ambiente. Creare un file `.env` nella root di `backend/`:

```env
PORT=8080
FIREBASE_PROJECT_ID=tuo_project_id_firebase
JWT_SECRET=chiave_segreta_per_token
HASH_SECRET=chiave_segreta_per_hashing
RESEND_API_KEY=api_key_resend_email
SMS_SIMULATION_EMAIL=email_debug@example.com
GOOGLE_APPLICATION_CREDENTIALS=path/to/service-account.json
AI_SERVICE_URL=http://localhost:8000/api/v1/analyze
RESCUER_DOMAINS=@vigilfuoco.it,@protezionecivile.it
```

Avviare il server di backend:

```bash
cd backend
dart run bin/server.dart
```

### 4\. Configurazione del Frontend

Assicurarsi di aver posizionato i file di configurazione Firebase nelle directory corrette:

* Android: `frontend/android/app/google-services.json`
* iOS: `frontend/ios/Runner/GoogleService-Info.plist`

Avviare l'applicazione mobile:

```bash
cd frontend
flutter run
```

*Nota: Per test su emulatore Android, il backend locale su `localhost` viene mappato automaticamente su `10.0.2.2`.*

## Struttura del Repository

Il progetto è strutturato come un monorepo gestito da Melos:

* **`/backend`**: Contiene la logica server-side.
    * `bin/`: Entry point del server.
    * `controllers/`: Gestori delle rotte API.
    * `services/`: Logica di business (Auth, SOS, Email).
    * `repositories/`: Layer di accesso ai dati (Firestore).
* **`/frontend`**: Contiene l'applicazione Flutter.
    * `lib/ui/`: Schermate e widget riutilizzabili.
    * `lib/providers/`: ViewModels per la gestione dello stato.
    * `lib/services/`: Integrazione con hardware e API.
    * `lib/repositories/`: Client HTTP per il backend.

## Team di Sviluppo

Progetto realizzato per il corso di **Ingegneria del Software** (Prof.ssa Filomena Ferrucci, Prof. Fabio Palomba) presso l'Università degli Studi di Salerno - A.A. 2024/2025.

**Gruppo C08 - SAfeGuard**

* **Project Management:**

    * Giuseppe Napolitano
    * Pasquale Sorrentino

* **Development Team:**

    * Alessandro Amendola
    * Alessandro Masone
    * Antonello Castelluccio
    * Francesco Carbone
    * Francesco Zambrino
    * Gianpaolo Aquilone
    * Giorgio Zazzerini
    * Giovanni Lamberti
    * Matteo Manganiello
    * Thomas Mercadino
    * Victor Di Gennaro
