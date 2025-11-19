# Assets 3D - Medieval MMORPG

Ce dossier contient tous les assets 3D gratuits (CC0) pour le jeu.

## Sources des Assets

### 1. Kenney - Retro Medieval Kit
- **Nombre de modèles**: 105 assets GLB
- **Licence**: CC0 (Domaine Public)
- **Source**: https://kenney.nl/assets/retro-medieval-kit
- **Formats**: GLB (optimisé pour Godot)

**Contenu**:
- Murs, tours, portes, fenêtres
- Toits et structures
- Escaliers et plateformes
- Décor: barils, caisses, poulies
- Arbres et végétation
- Éléments fortifiés

### 2. Quaternius - Animated Knight Character
- **Source**: https://opengameart.org/content/lowpoly-animated-knight
- **Licence**: CC0 (Domaine Public)
- **Format**: FBX (avec animations)

**Fichiers**:
- `KnightCharacter.fbx` - Personnage chevalier complet avec animations
- `Helmet1.fbx`, `Helmet2.fbx`, `Helmet3.fbx` - Différents casques
- `Sword.fbx`, `ShortSword.fbx`, `Katana.fbx` - Armes
- `Club.fbx` - Massue
- `ShoulderPads.fbx` - Épaulettes

**Animations incluses** (dans KnightCharacter.fbx):
- Idle (repos)
- Walk (marche)
- Run (course)
- Jump (saut)
- Roll (roulade)
- Attack (attaque)
- Death (mort)

## Utilisation dans Godot

### Importer les models

Godot importe automatiquement les fichiers GLB et FBX. Quand vous ouvrez le projet:

1. Les fichiers GLB sont directement utilisables
2. Les FBX créent des scènes `.tscn` automatiquement

### Utiliser le chevalier animé

Pour utiliser le personnage Quaternius avec animations:

1. Dans Godot, ouvrez `res://assets/models/KnightCharacter.fbx`
2. Godot va créer un fichier `.tscn` avec toutes les animations
3. Vous pouvez l'instancier dans vos scènes

### Construire des bâtiments

Les assets Kenney sont modulaires. Vous pouvez:

- Combiner différents murs avec `wall-*.glb`
- Ajouter des toits avec `roof-*.glb`
- Placer des tours avec `tower-*.glb`
- Décorer avec les props (`detail-*.glb`)

## Structure du dossier

```
models/
├── KnightCharacter.fbx          # Personnage principal animé
├── Helmet*.fbx                   # Casques et équipements
├── Sword*.fbx                    # Armes
├── *.glb                         # 105 modèles d'environnement
└── Knight Character by @Quaternius/  # Sources originales
```

## Exemples d'usage

### Créer un château

```gdscript
# Utiliser les murs fortifiés
wall-fortified.glb
wall-fortified-gate.glb
tower-base.glb
tower-top.glb
```

### Créer une maison

```gdscript
# Murs en bois
wall-pane-wood.glb
wall-pane-wood-door.glb
wall-pane-wood-window.glb
roof-side.glb
roof.glb
```

### Décor de village

```gdscript
# Props
barrels.glb
detail-crate.glb
fence-wood.glb
tree-large.glb
```

## Licence

Tous les assets sont sous licence **CC0** (Creative Commons Zero / Domaine Public).

Vous pouvez:
- Les utiliser dans des projets commerciaux
- Les modifier librement
- Les redistribuer
- **Aucune attribution requise** (mais toujours appréciée!)

## Crédits

- **Kenney** - https://kenney.nl/
- **Quaternius** - https://quaternius.com/

---

Pour plus d'assets gratuits similaires, visitez:
- https://kenney.nl/assets
- https://quaternius.com/
- https://opengameart.org/
