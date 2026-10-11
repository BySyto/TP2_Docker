
# Apprentissages

## Exercice 4 - Docker Compose pour le développement

Objectif : mettre en place un environnement Docker local avec l’application Go et Redis, puis garantir un développement fluide avec hot-reload.

### Problème rencontré et pourquoi il est survenu

Le premier problème venait des ports exposés dans le `docker-compose`. L'appli Go écoute sur le port `3000`, mais le conteneur n’était pas correctement exposé et la configuration de port ne correspondait pas à la vraie application. Cela empêchait l’accès au service depuis le navigateur.

Le second problème concernait le `Dockerfile.multistage`. Les fichiers statiques de l’application (`public`) n’étaient pas copiés au bon endroit dans l’image finale. 

Le troisième problème venait de la configuration Redis. L’application attendait une variable d’environnement nommée `REDIS_HOST`, mais dans le compose la variable n’était pas définie avec le bon nom ou la bonne valeur pour le service Redis. Sans cette configuration, l’application ne savait pas où trouver la base Redis.

Le quatrième problème concernait `air`. Il n’était pas correctement installé dans le conteneur, ce qui empêchait le service de redémarrer automatiquement lors des changements de code.

Enfin, il manquait le fichier `.air.toml`, qui est nécessaire pour configurer la surveillance des fichiers et le rebuild automatique de l'appli Go.

### Solution appliquée et pourquoi cette solution fonctionne

J’ai d’abord corrigé la configuration Docker Compose pour exposer correctement le port `3000` vers l’extérieur :

```yaml
ports:
  - "3000:3000"
```

Cela correspond au port utilisé par l'appli Go : `n.Run(":3000")`.

Ensuite, j’ai rétabli la copie des fichiers dans l’image finale du multistage build. Le bon fonctionnement du site web dépend de la présence du dossier `public` dans le conteneur, donc il faut le copier à la bonne étape avant le lancement de l’application sinon le dossier n'existera pas à la fin.

J’ai ensuite configuré correctement l’environnement Redis dans Docker Compose :

```yaml
environment:
  REDIS_HOST: redis
```

Ainsi, le service `guestbook` sait que le serveur Redis est accessible via le nom du service Docker `redis`.

Pour `air`, j’ai ajouté son installation dans le Dockerfile et créé un fichier `.air.toml` avec les bons paramètres pour surveiller les fichiers Go et relancer l’application automatiquement.
### Ce que j'ai appris

J’ai appris que Docker Compose ne fonctionne bien que si les ports, les variables d’environnement et les volumes sont cohérents entre le code et la configuration. Un petit décalage entre le port exposé et celui réellement utilisé par l’application suffit à tout casser.

J’ai aussi compris que le multistage build est très utile pour garder des images légères, mais il faut faire attention à copier tous les fichiers nécessaires dans la dernière étape, notamment les fichiers comme `public`...

Enfin, il faut savoir lire une doc technique, car sans le fichier .air.toml, forcément cela n'allait pas fonctionner.

