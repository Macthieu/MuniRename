# Muni UI Design System (v0)

Date: 2026-03-11

## Tokens

- Couleurs: fond, surfaces, contours, accent, texte, success/warning/error.
- Espacements: `xs`, `sm`, `md`, `lg`, `xl`.
- Rayons: `sm`, `md`, `lg`.
- Ombres: soft/active.

Fichier source:
- `MuniRename/Shared/UI/MuniTheme.swift`

## Composants

- `AppShell`
- `ContentCard`
- `SectionHeader`
- `ToolbarButton`
- `PrimaryActionButton`
- `SecondaryActionButton`
- `StatusBadge`
- `EmptyStateView`
- `PreviewPane`
- `SidebarPanel`
- `InspectorPanel`
- `LabeledTextField`
- `ToggleRow`
- `SegmentedChoiceRow`

Fichier source:
- `MuniRename/Shared/UI/MuniComponents.swift`

## Règles

- Eviter les styles hardcodes dans les vues features.
- Utiliser `MuniTheme` pour toutes decisions de couleur/spacing/radius.
- Utiliser les composants DS pour les zones repetitives (header, cards, badges, empty states).
