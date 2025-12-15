# Usa l'ultima versione stabile di Dart
FROM dart:stable AS build

# Imposta la cartella di lavoro principale nel container
WORKDIR /app

# -----------------------------------------------------------------
# 1. COPIA DEI FILE PUBSPEC (Layer Caching)
# Copiamo solo i file di definizione delle dipendenze per sfruttare la cache di Docker.
# Se non modifichi le dipendenze, Docker salterà il "pub get".
# -----------------------------------------------------------------

# Copia pubspec di data_models nella cartella data_models del container
COPY data_models/pubspec.* data_models/

# Copia pubspec di backend nella cartella backend del container
COPY backend/pubspec.* backend/

# -----------------------------------------------------------------
# 2. RISOLUZIONE DIPENDENZE
# -----------------------------------------------------------------

# Scarica le dipendenze per data_models
WORKDIR /app/data_models
RUN dart pub get

# Scarica le dipendenze per backend
WORKDIR /app/backend
RUN dart pub get

# -----------------------------------------------------------------
# 3. COPIA DEL CODICE SORGENTE E COMPILAZIONE
# -----------------------------------------------------------------

# Torna alla root /app per copiare le cartelle sorgenti complete
WORKDIR /app

# Copia tutto il codice sorgente di data_models
COPY data_models/ data_models/

# Copia tutto il codice sorgente di backend
COPY backend/ backend/

# Spostati nella cartella backend per compilare
WORKDIR /app/backend

# Assicura che tutto sia linkato correttamente e compila
RUN dart pub get --offline
RUN dart compile exe bin/server.dart -o bin/server

# -----------------------------------------------------------------
# 4. CREAZIONE IMMAGINE FINALE (Minimale)
# -----------------------------------------------------------------
FROM scratch

# Copia il runtime Dart necessario
COPY --from=build /runtime/ /

# Copia l'eseguibile compilato dallo stage precedente
COPY --from=build /app/backend/bin/server /app/bin/

# Esponi la porta e avvia
EXPOSE 8080
CMD ["/app/bin/server"]