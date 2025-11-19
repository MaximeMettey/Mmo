# Medieval MMORPG

Un mini MMORPG médiéval en 3D développé avec Godot 4 et Node.js.

## Caractéristiques

- **Multi-joueurs en temps réel** avec synchronisation via WebSockets
- **Graphismes 3D** simples mais efficaces
- **Chat en direct** entre joueurs
- **Mouvement fluide** avec interpolation
- **Cross-platform** : fonctionne sur Windows, Linux (Debian), et macOS

## Technologies utilisées

### Client
- **Godot 4.2+** : Moteur de jeu gratuit et open-source
- **GDScript** : Langage de script simple et performant

### Serveur
- **Node.js** : Runtime JavaScript
- **ws** : WebSocket pour la communication temps réel
- **better-sqlite3** : Base de données SQLite pour la persistance

## Installation

### Prérequis

#### Sur Debian/Ubuntu
```bash
# Installer Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Installer Godot
wget https://github.com/godotengine/godot/releases/download/4.2.1-stable/Godot_v4.2.1-stable_linux.x86_64.zip
unzip Godot_v4.2.1-stable_linux.x86_64.zip
sudo mv Godot_v4.2.1-stable_linux.x86_64 /usr/local/bin/godot
```

#### Sur Windows
1. **Node.js** : Téléchargez depuis https://nodejs.org/ (version LTS)
2. **Godot** : Téléchargez depuis https://godotengine.org/download (version 4.2+)

### Installation des dépendances

#### Serveur
```bash
cd server
npm install
```

## Lancement

### 1. Démarrer le serveur

```bash
cd server
npm start
```

Le serveur démarre sur le port **8080** par défaut.

Pour changer le port :
```bash
PORT=3000 npm start
```

### 2. Lancer le client

#### Méthode 1 : Avec l'éditeur Godot
1. Ouvrez Godot
2. Cliquez sur "Importer"
3. Naviguez vers le dossier `client`
4. Sélectionnez `project.godot`
5. Cliquez sur "Ouvrir"
6. Appuyez sur **F5** ou cliquez sur le bouton "Play"

#### Méthode 2 : En ligne de commande
```bash
cd client
godot --path . scenes/main.tscn
```

## Utilisation

### Connexion
1. Au lancement, entrez votre **nom d'utilisateur**
2. Cliquez sur **Connexion**
3. Le jeu charge et vous apparaissez dans le monde

### Contrôles
- **ZQSD** ou **WASD** : Déplacement
- **Espace** : Saut
- **Souris** : Regarder autour
- **Échap** : Libérer/capturer la souris
- **Entrée** : Ouvrir le chat
- **Entrée** (dans le chat) : Envoyer un message
- **Échap** (dans le chat) : Fermer le chat

### Chat
1. Appuyez sur **Entrée** pour ouvrir le chat
2. Tapez votre message
3. Appuyez sur **Entrée** pour envoyer
4. **Échap** pour fermer sans envoyer

## Architecture du projet

```
Mmo/
├── client/              # Client Godot
│   ├── scenes/         # Scènes 3D
│   │   ├── main.tscn
│   │   ├── player.tscn
│   │   └── remote_player.tscn
│   ├── scripts/        # Scripts GDScript
│   │   ├── main.gd
│   │   ├── player.gd
│   │   ├── remote_player.gd
│   │   └── network_manager.gd
│   ├── assets/         # Ressources (textures, modèles)
│   └── project.godot   # Configuration Godot
│
├── server/             # Serveur Node.js
│   ├── src/
│   │   └── server.js   # Serveur WebSocket
│   ├── package.json
│   └── game.db         # Base de données SQLite (créée auto)
│
└── README.md
```

## Fonctionnalités du serveur

### Messages WebSocket

Le serveur gère les types de messages suivants :

#### Client → Serveur
- `join` : Rejoindre le jeu avec un nom d'utilisateur
- `move` : Mettre à jour la position/rotation du joueur
- `chat` : Envoyer un message de chat

#### Serveur → Client
- `joined` : Confirmation de connexion avec ID joueur
- `players_list` : Liste des joueurs déjà connectés
- `player_joined` : Nouveau joueur rejoint
- `player_left` : Joueur déconnecté
- `player_moved` : Mouvement d'un joueur
- `chat_message` : Message de chat

### Base de données

La table `players` stocke :
- `id` : Identifiant unique
- `username` : Nom d'utilisateur
- `position_x`, `position_y`, `position_z` : Position 3D
- `rotation_y` : Rotation
- `last_seen` : Dernière connexion

## Configuration

### Changer l'adresse du serveur

Modifiez `client/scripts/network_manager.gd` :
```gdscript
var server_url = "ws://localhost:8080"
```

Remplacez `localhost` par l'IP du serveur si hébergé ailleurs.

### Ajuster les performances

Dans `client/scripts/player.gd`, modifiez :
```gdscript
var update_interval = 0.05  # Fréquence d'envoi (en secondes)
```

Valeurs plus élevées = moins de bande passante, mais moins fluide.

## Développement futur

Idées d'améliorations :
- [ ] Ajout de monstres (PvE)
- [ ] Système d'inventaire
- [ ] Objets à ramasser
- [ ] Animations de personnages
- [ ] Modèles 3D médiévaux (châteaux, arbres, etc.)
- [ ] Sons et musique
- [ ] Système de compétences
- [ ] Guildes/Groupes
- [ ] Zones différentes (donjons, villes)

## Dépannage

### Le client ne se connecte pas
1. Vérifiez que le serveur est démarré
2. Vérifiez l'adresse dans `network_manager.gd`
3. Vérifiez le pare-feu (port 8080)

### Lag ou désynchronisation
1. Réduisez `update_interval` dans `player.gd`
2. Vérifiez la latence réseau
3. Utilisez un serveur dédié avec bonne connexion

### Erreurs Godot
1. Assurez-vous d'utiliser Godot 4.2+
2. Réimportez le projet si nécessaire
3. Vérifiez les chemins dans project.godot

## Licence

MIT - Libre d'utilisation et de modification

## Crédits

Développé avec :
- **Godot Engine** - https://godotengine.org
- **Node.js** - https://nodejs.org
- **ws** - https://github.com/websockets/ws
- **better-sqlite3** - https://github.com/WiseLibs/better-sqlite3

---

Bon jeu ! 🎮⚔️