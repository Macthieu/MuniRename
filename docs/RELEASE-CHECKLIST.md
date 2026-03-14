# RELEASE CHECKLIST - MuniRenommage

Version cible: `v0.3.0`

## Avant tag

- [ ] Arbre Git propre (`git status`)
- [ ] `swift build` OK
- [ ] `swift run munirename-smoketests` OK
- [ ] `swift run munirename-cli --help` OK
- [ ] `swift run munirename-cli run --request <request.json> --result <result.json>` OK
- [ ] Commandes legacy OK: `preview`, `apply --dry-run`, `validate-preset`
- [ ] README à jour
- [ ] CHANGELOG à jour
- [ ] Licence GPLv3 présente
- [ ] AppIcon généré et intégré

## Publication GitHub

- [ ] Commit final sur `main`
- [ ] Push `main`
- [ ] Tag annoté `v0.3.0`
- [ ] Push du tag
- [ ] Création release GitHub avec notes `docs/RELEASE-NOTES-v0.3.0.md`

## Après publication

- [ ] Vérifier assets/release notes sur GitHub
- [ ] Vérifier badge CI et exécution workflow
