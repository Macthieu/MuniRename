# Harmonisation MuniConvert

Date: 2026-03-11

## Base reutilisable immediate

- Copier `MuniTheme.swift` et `MuniComponents.swift` dans MuniConvert (ou extraire en package commun `MuniUIKit`).
- Remplacer progressivement les wrappers visuels locaux de MuniConvert par:
  - `AppShell`
  - `ContentCard`
  - `StatusBadge`

## Strategie recommandee

1. Harmoniser d'abord header + cards + badges.
2. Harmoniser ensuite boutons et etats vides.
3. Garder la personnalite fonctionnelle de chaque app (pas de fusion UX complete).

## Risque principal

- Uniformiser trop vite et perdre les patterns qui marchent deja dans MuniConvert.
