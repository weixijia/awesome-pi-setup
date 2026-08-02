# Awesome Pi Setup

[English](README.md) | **Français** | [简体中文](README.zh-CN.md)

Une configuration globale de [Pi Coding Agent](https://github.com/earendil-works/pi), éprouvée en conditions réelles et conçue pour concilier sécurité et efficacité.

Il ne s'agit pas d'une collection où « plus d'extensions » serait forcément synonyme de « mieux ». Cette sélection volontairement limitée poursuit des objectifs précis :

- **Garde-fous** : confirmation ou refus lors de l'accès à des chemins sensibles, à des répertoires extérieurs au projet ou lors de commandes Shell dangereuses
- **Intelligence de code** : diagnostics LSP, définitions, références, symboles et corrections automatisées
- **Tâches longues** : planification, listes de tâches, sous-agents et workflows Goal/List/Loop audités
- **Recherche sur le Web** : recherche, extraction de pages, PDF, dépôts GitHub et vidéos, ainsi que vérification des sources
- **Contexte à long terme** : mémoire intersessions, recherche sémantique et connaissances de projet persistantes
- **Retour arrière** : sauvegarde privée avant installation et restauration fondée sur une liste blanche stricte
- **Chaîne d'approvisionnement vérifiable** : versions exactes, intégrité des archives, comparaison des fichiers installés et liens vers les sources

> Instantané du **2 août 2026**. Versions minimales : Pi **0.83.0** et Node.js **22**.

## À lire avant l'installation

Les extensions Pi s'exécutent avec les droits de votre compte utilisateur. Elles peuvent lire et modifier des fichiers, lancer des commandes et accéder au réseau. Avant toute installation, examinez au minimum :

```bash
less install.sh
less SECURITY.md
cat manifest/packages.json
```

Ce dépôt ne propose volontairement **aucune** commande de type `curl ... | bash`. Le programme d'installation ne lit pas, ne téléverse pas, ne supprime pas et ne modifie pas :

- `~/.pi/agent/auth.json`
- vos fournisseurs personnalisés ni `models.json`
- votre modèle, fournisseur, niveau de réflexion ou thème par défaut
- l'historique des sessions ni la base de données de Magic Context

## Installation en confiant la procédure à Pi

Copiez l'intégralité du message ci-dessous dans Pi. Pi commencera par auditer le dépôt, puis demandera votre accord avant l'installation :

```text
Installe et vérifie pour moi le dépôt public https://github.com/weixijia/awesome-pi-setup.

Contraintes :
1. Commence par le cloner dans un répertoire temporaire. Lis intégralement README.md, SECURITY.md, install.sh, verify.sh, manifest/*.json et scripts/restore.sh.
2. Vérifie le propriétaire du dépôt et le commit Git courant, ainsi que les versions exactes, les valeurs d'intégrité et les dépôts GitHub liés pour les 15 paquets npm. Arrête-toi si le code et la documentation se contredisent.
3. Examine mon fichier ~/.pi/agent/settings.json existant, mais ne lis et n'affiche jamais auth.json, les cookies, les clés d'API, le contenu des sessions ni aucun autre identifiant secret.
4. Explique ce qui sera conservé, ajouté ou remplacé, puis demande-moi confirmation avant toute modification.
5. Après confirmation, exécute ./install.sh. N'utilise pas curl|bash et n'ajoute pas --yes ; conserve toutes les validations interactives.
6. Exécute ensuite ./verify.sh. Présente chaque résultat, le chemin de la sauvegarde et les éventuels avertissements de npm audit. N'exécute jamais npm audit fix uniquement pour faire passer les contrôles.
7. Ne modifie ni mon modèle par défaut, ni mon fournisseur, ni mon thème, ni mes connexions existantes. À la fin, rappelle-moi d'exécuter /reload ou de redémarrer Pi.
```

Une version autonome se trouve dans [`PROMPT.md`](PROMPT.md).

## Installation manuelle rapide

### 1. Prérequis

- macOS ou Linux
- [Pi](https://github.com/earendil-works/pi) `>= 0.83.0`
- [Node.js](https://github.com/nodejs/node) `>= 22`
- `git`, `python3`, `npm` et `tar`
- [uv](https://github.com/astral-sh/uv) pour les serveurs de langage Python ; sous macOS, Homebrew peut l'installer

### 2. Cloner, examiner et installer

```bash
gh repo clone weixijia/awesome-pi-setup
cd awesome-pi-setup
less install.sh
./install.sh
```

Options disponibles :

```bash
./install.sh --magic-model 'anthropic/claude-sonnet-4-5'
./install.sh --skip-lsp
./install.sh --skip-skills
```

Réservez `--yes` aux automatisations pour lesquelles vous avez déjà examiné et épinglé le commit du dépôt. Cette option est déconseillée lors d'une première installation.

### 3. Recharger Pi

Dans une session Pi déjà ouverte :

```text
/reload
```

Vous pouvez également quitter Pi puis le relancer.

Pour suivre chaque commande manuellement, consultez [`docs/MANUAL_INSTALL.md`](docs/MANUAL_INSTALL.md).

## Extensions Pi incluses

Chaque extension est épinglée à une version exacte. Les liens renvoient directement au dépôt GitHub de son mainteneur.

| Extension | Version | Rôle | GitHub |
|---|---:|---|---|
| `@gotgenes/pi-subagents` | 19.2.1 | Sous-agents au premier plan ou en arrière-plan, reprise et pilotage | [gotgenes/pi-packages](https://github.com/gotgenes/pi-packages/tree/main/packages/pi-subagents) |
| `pi-web-access` | 0.17.1 | Recherche, extraction de pages/PDF/vidéos/GitHub et vérification des sources | [nicobailon/pi-web-access](https://github.com/nicobailon/pi-web-access) |
| `@juicesharp/rpiv-todo` | 2.3.1 | Gestion de tâches persistante dans la session | [juicesharp/rpiv-mono](https://github.com/juicesharp/rpiv-mono/tree/main/packages/rpiv-todo) |
| `@juicesharp/rpiv-ask-user-question` | 2.3.1 | Questions de clarification structurées | [juicesharp/rpiv-mono](https://github.com/juicesharp/rpiv-mono/tree/main/packages/rpiv-ask-user-question) |
| `@narumitw/pi-plan-mode` | 0.44.0 | Mode de planification doté d'un ensemble d'outils restreint | [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-plan-mode) |
| `@mrclrchtr/supi-claude-md` | 4.4.0 | Skills de maintenance des fichiers AGENTS.md et CLAUDE.md | [mrclrchtr/supi](https://github.com/mrclrchtr/supi/tree/main/packages/supi-claude-md) |
| `pi-cache-optimizer` | 2.6.25 | Optimisation et diagnostic du cache de prompts/KV | [jiangge/pi-cache-optimizer](https://github.com/jiangge/pi-cache-optimizer) |
| `@narumitw/pi-statusline` | 0.43.0 | Barre d'état pour le modèle, Git, le contexte, l'activité et l'utilisation | [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-statusline) |
| `@benvargas/pi-openai-fast` | 1.0.5 | Activation facultative du niveau prioritaire OpenAI ; désactivée par défaut | [ben-vargas/pi-packages](https://github.com/ben-vargas/pi-packages/tree/main/packages/pi-openai-fast) |
| `@narumitw/pi-usage` | 0.43.0 | Affichage de l'utilisation de Codex, Copilot et OpenRouter | [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-usage) |
| `@cortexkit/pi-magic-context` | 0.33.0 | Mémoire intersessions et contexte sémantique | [cortexkit/magic-context](https://github.com/cortexkit/magic-context/tree/master/packages/pi-plugin) |
| `pi-goal-list-loop-audit` | 0.34.20 | Workflows Goal/List/Loop assortis d'un audit indépendant | [DraconDev/pi-goal-list-loop-audit](https://github.com/DraconDev/pi-goal-list-loop-audit) |
| `@narumitw/pi-lsp` | 0.44.0 | Diagnostics, définitions, références et corrections LSP | [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-lsp) |
| `@narumitw/pi-worktree` | 0.43.0 | Gestion interactive et sûre des worktrees Git | [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-worktree) |

Les réglages nécessaires, commandes et précautions propres à chaque extension sont détaillés dans [`docs/PLUGINS.md`](docs/PLUGINS.md). Les valeurs d'intégrité npm et les liens vers les sources, lisibles par machine, figurent dans [`manifest/packages.json`](manifest/packages.json).

## Outils LSP

| Outil | Version épinglée | GitHub |
|---|---:|---|
| Biome | 2.5.6 | [biomejs/biome](https://github.com/biomejs/biome) |
| Bash Language Server | 5.6.0 | [bash-lsp/bash-language-server](https://github.com/bash-lsp/bash-language-server) |
| YAML Language Server | 1.24.0 | [redhat-developer/yaml-language-server](https://github.com/redhat-developer/yaml-language-server) |
| Ruff | 0.16.1 | [astral-sh/ruff](https://github.com/astral-sh/ruff) |
| ty | 0.0.65 | [astral-sh/ty](https://github.com/astral-sh/ty) |
| clangd (outil système facultatif) | Fourni par Xcode/LLVM | [llvm/llvm-project](https://github.com/llvm/llvm-project) |
| SourceKit-LSP (facultatif sous macOS) | Fourni par Xcode | [swiftlang/sourcekit-lsp](https://github.com/swiftlang/sourcekit-lsp) |

L'extension Pi LSP utilise son propre catalogue de serveurs. Cette configuration ne crée volontairement aucun fichier global susceptible de remplacer ce catalogue.

## Skills sélectionnés

Le programme d'installation récupère cinq Skills depuis un commit épinglé de [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions) :

```text
ceaabed6c40ee98ba1b61e264fe1ecf527538770
```

Skills installés :

- `applying-tdd`
- `reviewing-code`
- `writing-git-commits`
- `hardening-code-paths`
- `designing-user-experiences`

L'épinglage du commit empêche une installation ultérieure d'exécuter silencieusement la toute dernière version des prompts amont. Examinez les différences avant de modifier ce commit.

## Réglages de sécurité appliqués

Le programme d'installation fusionne les clés suivantes dans `settings.json`, sans remplacer le modèle, le fournisseur, le thème ni les extensions sans rapport :

```json
{
  "enableInstallTelemetry": false,
  "enableSkillCommands": true
}
```

`defaultProjectTrust` est intentionnellement laissé tel quel : c'est une décision propre à chaque
utilisateur, et l'installateur ne doit pas la réinitialiser silencieusement à chaque exécution.

Il applique également les choix suivants :

- au plus `2` sous-agents simultanés et `30` tours par défaut
- acceptation automatique des brouillons, reprise automatique et mode agressif de GLLA désactivés
- confirmation obligatoire pour toute commande Shell inconnue
- confirmation lors de l'accès aux fichiers `.env`, clés, certificats, identifiants ou répertoires extérieurs au projet
- refus explicite de `rm -rf /`
- accès de Gemini Web aux cookies du navigateur désactivé
- OpenAI Fast installé mais désactivé
- Sidekick de Magic Context désactivé pour éviter un second agent d'arrière-plan
- Todo de Magic Context désactivé pour ne pas faire doublon avec `rpiv-todo`
- ajout, dans Plan Mode, des seuls outils de recherche Web et LSP en lecture seule

Le système de permissions ne constitue pas un bac à sable au niveau du système d'exploitation. Pour un dépôt non fiable, utilisez un conteneur ou une machine virtuelle.

## Commandes utiles

```text
/lsp
/worktree
/plan
/usage
/code-review
/commit
/doctor
/skill:applying-tdd
/skill:reviewing-code
/skill:writing-git-commits
/skill:hardening-code-paths
/skill:designing-user-experiences
```

## Vérification

```bash
./verify.sh
```

Le vérificateur contrôle :

- les versions exactes des 15 extensions et la liste des extensions à retirer
- la conformité des fichiers installés aux archives contrôlées indépendamment
- les fichiers de configuration JSON/JSONC
- le commit épinglé des Skills
- les versions des outils LSP en ligne de commande
- l'absence de scripts npm non examinés et la portée par version des autorisations
- le démarrage RPC de Pi, les erreurs d'extension, les délais d'attente et les conflits de commandes Slash
- les alertes de `npm audit`, en mode rapport uniquement

Un véritable appel de modèle nécessite votre propre connexion à un fournisseur. Le vérificateur public n'envoie donc aucune requête à un LLM.

## Sauvegarde et restauration

Chaque installation crée le répertoire suivant :

```text
~/.pi/backups/awesome-pi-setup-YYYYMMDD-HHMMSS/
```

Les identifiants, modèles personnalisés et sessions sont exclus. En cas d'échec, le programme restaure automatiquement la configuration Pi. Des paquets téléchargés mais non référencés peuvent rester sur le disque sans être chargés ; les versions d'outils LSP globaux déjà mises à jour peuvent également subsister, car restaurer les versions globales antérieures sans instantané du gestionnaire de paquets serait hasardeux.

Restauration manuelle :

```bash
./scripts/restore.sh ~/.pi/backups/awesome-pi-setup-YYYYMMDD-HHMMSS
```

Le script de restauration n'accepte que la liste blanche documentée de configurations et de Skills. Il refuse les identifiants, sessions, liens symboliques, fichiers spéciaux et entrées inattendues.

## Éléments volontairement absents

- **Identifiants des fournisseurs** : configurez-les vous-même avec `/login` dans Pi
- **MCP** : n'ajoutez pas cette surface d'attaque sans serveur précis à utiliser
- **Synchronisation WebDAV** : elle peut copier des identifiants, des sessions ou des extensions exécutables
- **Automatisation du navigateur** : activez-la projet par projet avec un profil dédié et peu privilégié
- **Deuxième système de mémoire, tâches, planification ou sous-agents** : évitez les fonctions en double et les conflits d'événements
- **Faux “sandbox”** : une demande de confirmation ne remplace ni un conteneur ni une machine virtuelle

## Risques connus

- À la date de l'instantané, la chaîne de dépendances des embeddings locaux de Magic Context peut provoquer des alertes High dans `npm audit`. N'exécutez pas `npm audit fix` à l'aveugle : vérifiez d'abord qu'une correction amont compatible existe.
- L'activation de `pi-openai-fast` demande le niveau prioritaire OpenAI et peut modifier la facturation. L'option est désactivée par défaut.
- La valeur de 4 000 000 tokens de GLLA est une limite d'arrêt, pas une garantie budgétaire. Réduisez-la dans `/glla` selon votre compte.
- Le Shell restreint de Plan Mode et le système de permissions ne fournissent pas d'isolation au niveau du noyau.
- `supi-claude-md` est encore en version bêta ; n'utilisez ses Skills de maintenance des fichiers d'instructions que dans des dépôts fiables.

Consultez [`SECURITY.md`](SECURITY.md) pour le modèle de menace complet et les remarques relatives à la chaîne d'approvisionnement.

## Mettre cette configuration à jour

N'automatisez pas la mise à niveau sans surveillance de toutes les extensions vers leur dernière version. Procédez plutôt ainsi :

1. Ouvrez une issue ou une pull request qui modifie `manifest/*.json`.
2. Lisez les journaux de modifications et les différences de code en amont.
3. Mettez à jour les versions exactes, les valeurs d'intégrité et les versions des scripts de cycle de vie examinés.
4. Testez l'installation avec un `PI_CODING_AGENT_DIR` isolé.
5. Exécutez `./verify.sh`.
6. Ne fusionnez qu'après une vérification humaine.

## Licence

Ce projet est publié sous licence [MIT](LICENSE). Les extensions et Skills tiers restent soumis à leurs propres licences.
