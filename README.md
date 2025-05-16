# GESTION PRODUITS

## Prérequis
Cette application est compatible `PHP8` et a été testée avec une base de données `MySQL 8.4`.

## Installation avec Docker
- Copiez le fichier `.env.example` en `.env` et modifiez les valeurs si nécessaire
- Lancez l'application avec Docker Compose: `docker-compose up -d`
- Lancez les migrations de la base de données: `make dev-migrate` ou `docker-compose up migration`
- Accédez à l'application à l'adresse: `http://localhost:8080` (ou le port défini dans `.env`)
- Accédez à phpMyAdmin à l'adresse: `http://localhost:8081` (ou le port défini dans `.env`)
- Connectez vous à l'application avec les informations suivantes :
    - Login : `admin`
    - Mot de passe : `password`

## Installation manuelle
- Copier les fichiers du dossier `www` dans un dossier accessible par le serveur Web.
- Assurez vous que le dossier `uploads` est accessible en lecture et écriture par le serveur Web : `chmod 777 uploads`
- Importez la base de données test à partir du dump SQL `database/gestion_produits.sql`.
- Connectez vous à l'application avec l'url adaptée avec les informations suivantes :
    - Login : `admin`
    - Mot de passe : `password`

## Configuration
Le fichier `.env` contient les variables d'environnement utilisées par l'application:
- `DB_HOST`: Nom d'hôte de la base de données
- `DB_USER`: Nom d'utilisateur pour la base de données
- `DB_PASSWORD`: Mot de passe pour la base de données
- `DB_NAME`: Nom de la base de données
- `PHP_DISPLAY_ERRORS`: Afficher les erreurs PHP (1 pour oui, 0 pour non)
- Ports: `WEB_PORT`, `DB_PORT`, `PHPMYADMIN_PORT` (optionnels)

## Base de données et migrations
Les scripts SQL se trouvent dans le répertoire `database/`. Pour initialiser ou mettre à jour la base de données:

```bash
make dev-migrate
```

Voir `database/README.md` pour plus d'informations sur les migrations.

## Fonctionnalités
L'application permet de :
- Lister les produits
- Afficher la fiche produit en lecture seule
- Ajouter des produits
- Modifier les produits
- Supprimer les produits
- Pour chaque produit, il est possible d'ajouter autant de photos que nécessaire