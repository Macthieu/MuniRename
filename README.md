# MuniRename

MuniRename est une application macOS (SwiftUI) de renommage de fichiers en lot, avec aperçu en direct, règles combinables et presets JSON.

## Fonctionnalités

- Chargement d'un dossier avec options récursives et prise en charge des fichiers cachés.
- Prévisualisation en direct du nouveau nom avant application.
- Règles de renommage activables individuellement:
- Remplacer (texte ou regex, sensible/insensible à la casse)
- Retirer (plage de caractères, trim, réduction des espaces)
- Ajouter (préfixe, suffixe, insertion à une position donnée)
- Date automatique (préfixe, suffixe, insertion à position)
- Numérotation (départ, pas, padding, patron `#`, sélection uniquement)
- Casse (inchangée, minuscules, MAJUSCULES, casse titre)
- Extension (nouvelle extension + transformation de casse)
- Dossier parent (ajout en préfixe ou suffixe)
- Spécial (normalisation Unicode, suppression accents, remplacement espaces/tiret)
- Destination configurable:
- Renommer sur place
- Déplacer vers un autre dossier
- Copier au lieu de déplacer
- Sélection partielle des fichiers et prévisualisation limitée à la sélection.
- Undo de la dernière opération appliquée.
- Gestionnaire de presets:
- création, duplication, suppression
- catégories
- import/export JSON
- application depuis une fenêtre dédiée

## Prérequis

- macOS
- Xcode (version récente compatible SwiftUI)

## Installation et lancement

1. Cloner le dépôt:

```bash
git clone https://github.com/Macthieu/MuniRename.git
cd MuniRename
```

2. Ouvrir le projet:

```bash
open MuniRename.xcodeproj
```

3. Dans Xcode, sélectionner le schéma `MuniRename` puis lancer l'app (`Run`).

## Utilisation rapide

1. Cliquer sur `Choisir un dossier`.
2. Activer les règles souhaitées dans le panneau de gauche.
3. Vérifier la colonne `Nouveau nom`.
4. Cliquer sur `Appliquer`.
5. Si nécessaire, utiliser `Undo` pour annuler la dernière opération.

## Presets

Les presets sont enregistrés dans `~/Library/Application Support/MuniRename/` et peuvent être importés/exportés au format JSON.

## Sécurité

Le renommage de masse modifie ou déplace des fichiers réels. Il est recommandé de tester d'abord sur un dossier de copie avant usage en production.

## Licence

Ce projet est distribué sous licence GNU GPL v3.0. Voir le fichier `LICENSE`.
