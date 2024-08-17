# Static Website 

## INTRODUCTION

Ce projet est une application Node.js qui implémente un système d'authentification basé sur des sessions utilisant une base de données MySQL pour le stockage des données utilisateur. L'application utilise également Redis pour la gestion des sessions et l'envoi de codes de vérification par e-mail pour la réinitialisation de mot de passe.

## Fonctionnalités de l'authentification

* **Stockage des données utilisateur**: Les informations des utilisateurs sont stockées dans une base de données MySQL.
* **Authentification par sessions**: Les sessions utilisateur sont gérées à l'aide de Redis plutôt que de les stocker en mémoire. Chaque session a une durée de validité de 30 minutes, correspondant à la durée de l'authentification.
* **Accès à la landing page**: Une fois authentifié, l'utilisateur peut accéder à la landing page sans passer par l'écran de login pendant la durée de sa session. Après expiration de cette période, une nouvelle authentification est requise.
* **Déconnexion sécurisée**: Lorsque l'utilisateur se déconnecte via la landing page, sa session est définitivement coupée, même si elle n'a pas encore expiré. Une nouvelle authentification est requise pour accéder à la landing page par la suite.

## Réinitialisation de mot de passe

* **Envoi de code par e-mail**: Pour la réinitialisation de mot de passe, un code de vérification est généré et envoyé à l'utilisateur par e-mail.
* **Validation du code de vérification**: Le code généré est également stocké dans Redis pendant une durée de 2 minutes. La réinitialisation du mot de passe est validée en comparant le code fourni par l'utilisateur avec celui stocké dans Redis.

## Architecture du projet

* **Modèle MVC (Model-View-Controller)**: L'application suit le pattern MVC, avec les répertoires distincts pour chaque couche :
    * **entities**: Contiennent la définition des modèles de données utilisés dans l'application.
    * **views**: Les fichiers HTML et CSS utilisés pour afficher l'interface utilisateur.
    * **controllers**: Logique métier et gestion des requêtes HTTP.

* **Services**: Contient les scripts JavaScript utilisés par les contrôleurs pour interagir avec la base de données.
* **Routes**: Contient les fichiers JavaScript qui assignent des contrôleurs aux routes HTTP du serveur.

## Prérequis

Avant de lancer l'application, assurez-vous d'avoir Node.js, MySQL et Redis installés sur votre système.

## Installation

1. Cloner ce dépôt sur votre machine.
2. Installer les dépendances en exécutant **npm install**.
3. Configurer les variables d'environnement dans un fichier .env en se basant sur le fichier .env.example fourni.
4. Assurez-vous que MySQL et Redis sont en cours d'exécution sur votre machine.
5. Lancer l'application en exécutant **npm start**.

### **Martial Kom**
