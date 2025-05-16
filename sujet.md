epsi®
l'école d'ingénierie
informatique

16/05/2025

# Kubernetes
## TP noté - I2 EISI DEV2

![Kubernetes Logo](kubernetes)

## Objectifs du travail
L'objectif de ce travail est de mettre en place le flux de travail pour une application Web donnée. Cela inclut donc l'environnement de travail de l'utilisateur sur **Docker** et cela va jusqu'à la mise en production sur un cluster **Kubernetes** en passant par une éventuelle chaîne CI/CD sur une forge logicielle quelconque.

## Description de l'application
L'application sur laquelle vous aurez à travailler permet de gérer de manière très simpliste des produits. Elle est développée en **PHP** et utilise une base de données **MySQL / MariaDB**.

Le dépôt git de l'application est accessible à cette adresse:
[https://gl.avalone-fr.com/anthony/gestion-produits](https://gl.avalone-fr.com/anthony/gestion-produits)

L'application dispose d'un jeu d'essai basique de produits (base de données et images) que vous pourrez intégrer dès la mise en place de l'application. Quelques instructions pour la faire fonctionner sont présents sur la fiche du dépôt git.

---
### Gestion des produits

| Num. | Libellé                                         | Prix    |
| :--- | :---------------------------------------------- | :------ |
| 3    | Chaussures VTT MAVIC CROSSMAX SL PRO THERMO Noir | 164,99 € |
| 5    | Fourche DVO SAPPHIRE 29                         | 549,99 € |
| 4    | Pack GPS GARMIN EDGE 1030 + Ceinture Cardio     | 519,99 € |
| 1    | Pédales Shimano XT M8040 M/L                    | 74,99 €  |
| 2    | Selle FIZIK ARIONE VERSUS Rails Kium            | 59,99 €  |

<button>Ajouter un produit</button> <button>Se déconnecter</button>

---
### Selle FIZIK ARIONE VERSUS Rails Kium
**59,99 €**

Modèle confortable avant tout, la selle FIZIK Arione Versus possède un profil tout à fait plat et très long (300 mm) qui convient aux pratiquants justifiant d'une excellente souplesse vertébrale. Sa surface présente un canal central évidé, caractéristique des selles de la ligne Versus, qui permet de réduire les points de pression sur la zone périnéale.

L'Arione Versus présente des rails légers et résistants en matériau Kium, et une coque associant du carbone à du nylon, pour offrir un supplément de souplesse aux endroits où les cuisses entrent en contact avec la selle, durant la phase de pédalage.

**Ressources**

![Fizik Saddle Image 1](fi'zik)
![Fizik Saddle Image 2](fi'zi:k)
![Fizik Saddle Image 3](fi'zi:)
![Fizik Saddle Image 4](image)

<button>Modifier</button> <button>Retour</button>
---
I2 EISI DEV - KUBE961 - Kubernetes
1/3
---

16/05/2025

## Travail à effectuer

### Sur le poste de travail du développeur
Dans l'objectif de faciliter le travail du développeur, vous allez conteneuriser cette application grâce à **Docker**. Le développeur doit pouvoir facilement modifier le code et tester le résultat directement su son poste de travail, quel que soit son système d'exploitation (Windows, GNU/Linux, Mac OS).
Il doit aussi avoir les instructions pour permettre une création des images qui seront déployées sur un cluster Kubernetes.

### Kubernetes
Vous déploierez un cluster Kubernetes d'au minimum trois nœuds sur la plateforme de votre choix (machines virtuelles sur votre poste de travail, machines physiques, machines virtuelles sur le Cloud, Kubernetes managé sur le Cloud...).
L'application devra pouvoir tourner sur ce cluster en prenant en compte la **tolérance à la panne**: il devra être possible de « **déplacer** » les containers sur chaque nœud tout en conservant les données.

### Version PostgreSQL de l'application
Le développeur souhaite, pour différentes raisons, basculer la base de données sur **PostgreSQL** à la place de MySQL. En considérant la version PostgreSQL comme étant en développement, créez tout le nécessaire pour permettre le développement de la version PostgreSQL en parallèle de la version originale basée sur MySQL.
Vous déploierez aussi cette version sur le même cluster Kubernetes que la version MySQL.

### Accès aux versions de l'application
Les deux versions de l'application (MySQL et PostgreSQL) devront être accessibles en utilisant des url **https** sur le port standard `tcp/443` (ou `udp/443` pour http3 si possible).
Par exemple:
*   `https://www.domaine.fr` pour la version principale (MySQL)
*   `https://dev.domaine.fr` pour la version de développement (PostgreSQL)

Vous avez le choix du nom de domaine que vous utiliserez et le certificat TLS n'a pas besoin d'être valide pour la démonstration.

> **Attention** : n'achetez pas un nom de domaine pour l'occasion. Utilisez des astuces pour la résolution de nom locale :
> *   fichier hosts
> *   serveur DNS local
> *   ...
>
> Si vous disposez d'un nom de domaine public, vous pouvez l'utiliser pour ce travail et déployer un certificat TLS public mais cela ne sera pas plus valorisé qu'une exécution purement locale avec des certificats invalides.

---
I2 EISI DEV - KUBE961 - Kubernetes
2/3
---

16/05/2025

## Livrables
Votre travail doit se traduire par la remise :
*   D'un **document technique au format PDF** décrivant le travail effectué en détails : justification des modifications pour Docker, pour Kubernetes, schéma d'infrastructure pour Kubernetes, preuves de fonctionnement (captures d'écran, screencast...).
*   Un **dépôt git** faisant apparaître votre code pour la version MySQL et pour la version PostgreSQL ou, à défaut, une **archive zip** contenant votre code.

Vos livrables doivent être transmis par mail à l'adresse [anthony@avalone-fr.com](mailto:anthony@avalone-fr.com) avant le :

**vendredi 16 mai 2025 à minuit**

## Critères évalués

| Critères                                                     | Points |
| :----------------------------------------------------------- | :----- |
| **Utilisation de Docker**                                    | **6**  |
| *   Installation de Docker                                   |        |
| *   Adaptation du code pour l'exécution dans Docker          |        |
| *   Utilisation correcte de Docker et Docker Compose         |        |
| **Déploiement Kubernetes**                                   | **7**  |
| *   Déploiement du cluster Kubernetes                        |        |
| *   Déploiement de l'application dans Kubernetes             |        |
| *   Accès aux versions de l'application en https             |        |
| **Gestion des versions MySQL et PostgreSQL**                 | **5**  |
| *   Adaptation du code pour PostgreSQL                       |        |
| *   Cohabitation des deux versions pour Docker et pour Kubernetes |        |
| **Qualité des livrables**                                    | **2**  |
| *   Lisibilité                                               |        |
| *   Présence de schémas explicatifs                          |        |
| *   Précision technique                                      |        |
| **Total**                                                    | **20** |

---
I2 EISI DEV - KUBE961 - Kubernetes
3/3
---
