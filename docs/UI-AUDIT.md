# UI Audit - MuniRename

Date: 2026-03-11

## Bloquant

- Hierarchie visuelle faible dans l'ancien ecran principal: actions critiques et secondaires melangees.
- Separation entre zone regles et zone apercu trop ambiguë selon la largeur (impression de 3 panneaux au lieu de 2).

## Important

- Densite irreguliere (effet mur de panneaux).
- Styles disperses et hardcodes (couleurs, bordures, espacements) rendant la coherence inter-app difficile.
- Etats vides utiles mais presentation non unifiee.

## Souhaitable

- Composants UI communs entre MuniRename et MuniConvert.
- Palette et tokens partages (espacements/rayons/boutons/badges).
- Adaptation explicite a la largeur ecran pour les regles (1 colonne vs 2 colonnes).
