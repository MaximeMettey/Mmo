const WebSocket = require('ws');
const Database = require('better-sqlite3');
const path = require('path');

// Configuration
const PORT = process.env.PORT || 8080;
const db = new Database(path.join(__dirname, '../game.db'));

// Initialiser la base de données
db.exec(`
  CREATE TABLE IF NOT EXISTS players (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    position_x REAL DEFAULT 0,
    position_y REAL DEFAULT 1,
    position_z REAL DEFAULT 0,
    rotation_y REAL DEFAULT 0,
    last_seen DATETIME DEFAULT CURRENT_TIMESTAMP
  )
`);

// Stockage des joueurs connectés
const players = new Map(); // sessionId -> { ws, playerId, username, position, rotation }

// Créer le serveur WebSocket
const wss = new WebSocket.Server({ port: PORT });

console.log(`🎮 Serveur MMORPG médiéval démarré sur le port ${PORT}`);

wss.on('connection', (ws) => {
  const sessionId = generateSessionId();
  console.log(`Nouvelle connexion: ${sessionId}`);

  ws.on('message', (data) => {
    try {
      const message = JSON.parse(data);
      handleMessage(ws, sessionId, message);
    } catch (error) {
      console.error('Erreur parsing message:', error);
    }
  });

  ws.on('close', () => {
    handleDisconnect(sessionId);
  });

  ws.on('error', (error) => {
    console.error('WebSocket erreur:', error);
  });
});

function handleMessage(ws, sessionId, message) {
  switch (message.type) {
    case 'join':
      handleJoin(ws, sessionId, message.username);
      break;

    case 'move':
      handleMove(sessionId, message.position, message.rotation);
      break;

    case 'chat':
      handleChat(sessionId, message.text);
      break;

    default:
      console.log('Type de message inconnu:', message.type);
  }
}

function handleJoin(ws, sessionId, username) {
  // Vérifier si le joueur existe déjà
  const stmt = db.prepare('SELECT * FROM players WHERE username = ?');
  let player = stmt.get(username);

  if (!player) {
    // Créer un nouveau joueur
    const insert = db.prepare(
      'INSERT INTO players (username, position_x, position_y, position_z) VALUES (?, ?, ?, ?)'
    );
    const result = insert.run(username, 0, 1, 0);
    player = {
      id: result.lastInsertRowid,
      username: username,
      position_x: 0,
      position_y: 1,
      position_z: 0,
      rotation_y: 0
    };
  }

  // Ajouter le joueur à la liste des connectés
  players.set(sessionId, {
    ws: ws,
    playerId: player.id,
    username: player.username,
    position: {
      x: player.position_x,
      y: player.position_y,
      z: player.position_z
    },
    rotation: player.rotation_y
  });

  // Envoyer la confirmation au joueur
  send(ws, {
    type: 'joined',
    playerId: player.id,
    position: {
      x: player.position_x,
      y: player.position_y,
      z: player.position_z
    },
    rotation: player.rotation_y
  });

  // Envoyer la liste des autres joueurs
  const otherPlayers = [];
  players.forEach((p, sid) => {
    if (sid !== sessionId) {
      otherPlayers.push({
        playerId: p.playerId,
        username: p.username,
        position: p.position,
        rotation: p.rotation
      });
    }
  });

  send(ws, {
    type: 'players_list',
    players: otherPlayers
  });

  // Notifier les autres joueurs
  broadcast({
    type: 'player_joined',
    playerId: player.id,
    username: player.username,
    position: {
      x: player.position_x,
      y: player.position_y,
      z: player.position_z
    },
    rotation: player.rotation_y
  }, sessionId);

  console.log(`✅ ${username} a rejoint le jeu (ID: ${player.id})`);
}

function handleMove(sessionId, position, rotation) {
  const player = players.get(sessionId);
  if (!player) return;

  // Mettre à jour la position
  player.position = position;
  player.rotation = rotation;

  // Sauvegarder en base de données
  const update = db.prepare(
    'UPDATE players SET position_x = ?, position_y = ?, position_z = ?, rotation_y = ?, last_seen = CURRENT_TIMESTAMP WHERE id = ?'
  );
  update.run(position.x, position.y, position.z, rotation, player.playerId);

  // Diffuser aux autres joueurs
  broadcast({
    type: 'player_moved',
    playerId: player.playerId,
    position: position,
    rotation: rotation
  }, sessionId);
}

function handleChat(sessionId, text) {
  const player = players.get(sessionId);
  if (!player) return;

  broadcast({
    type: 'chat_message',
    playerId: player.playerId,
    username: player.username,
    text: text
  });

  console.log(`💬 ${player.username}: ${text}`);
}

function handleDisconnect(sessionId) {
  const player = players.get(sessionId);
  if (!player) return;

  console.log(`❌ ${player.username} s'est déconnecté`);

  // Notifier les autres joueurs
  broadcast({
    type: 'player_left',
    playerId: player.playerId
  }, sessionId);

  players.delete(sessionId);
}

function broadcast(message, excludeSessionId = null) {
  players.forEach((player, sessionId) => {
    if (sessionId !== excludeSessionId && player.ws.readyState === WebSocket.OPEN) {
      send(player.ws, message);
    }
  });
}

function send(ws, message) {
  if (ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify(message));
  }
}

function generateSessionId() {
  return Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
}

// Gestion de la fermeture propre
process.on('SIGINT', () => {
  console.log('\n🛑 Arrêt du serveur...');
  db.close();
  process.exit(0);
});
