Są zrobine 4 dodatkowych zadania

Kod jest przestawiony w pliku Dockerfile

# Polecenie dla dodatkowych zadań 
 docker buildx build --platform linux/amd64,linux/arm64 --push --tag psevdo12/zadanie1  --cache-to=type=registry,ref=psevdo12/zadanie1:cache,max_size=5GB --cache-from=type=registry,ref=psevdo12/zadanie1:cache -f Dockerfile .