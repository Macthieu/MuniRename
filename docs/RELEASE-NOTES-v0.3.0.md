# MuniRenommage v0.3.0

Date: 2026-03-14

## Points cles

- Ajout du mode canonique OrchivisteKit:
  - `munirename-cli run --request <file> --result <file>`
- Conservation des commandes legacy:
  - `preview`
  - `apply`
  - `validate-preset`
- Renforcement des garde-fous en mode canonique:
  - `dry_run=true` par defaut pour `apply`
  - execution reelle seulement avec `dry_run=false` et `confirm_apply=true`
- Harmonisation UI et documentation du projet.

## Compatibilite

- Les commandes CLI historiques restent supportees.
- Le mode app macOS reste autonome.
- Le nom public est `MuniRenommage`; certains identifiants techniques internes restent `MuniRename`.

## Verification release

- `swift build`
- `swift run munirename-smoketests`
- verification du mode canonique `run --request --result`
- verification des commandes legacy `preview`, `apply --dry-run`, `validate-preset`
