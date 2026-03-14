# UI Refonte Plan - MuniRenommage

Date: 2026-03-11

## Cible

- Un shell visuel commun (style MuniConversion, inspire elementary OS sans copie).
- Deux zones majeures stables: regles (gauche) et apercu/resultat (droite).
- Actions principales clairement mises en avant (Appliquer), secondaires plus discretes.

## Mise en oeuvre

1. Centraliser les tokens visuels (`MuniTheme`).
2. Introduire des composants reutilisables (`AppShell`, `ContentCard`, `StatusBadge`, etc.).
3. Refondre `ContentView` sur ces composants.
4. Rendre le panneau regles adaptatif:
   - 1 colonne sur largeur standard,
   - 2 colonnes sur tres large ecran.
5. Standardiser les etats vides et badges.

## Non-objectifs immediats

- Refonte fonctionnelle du moteur de renommage.
- Refonte de toutes les fenetres secondaires en une seule passe.
