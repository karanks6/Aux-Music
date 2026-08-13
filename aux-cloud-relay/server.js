const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const crypto = require('crypto');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*', methods: ['GET', 'POST'] },
});

app.get('/health', (req, res) =>
  res.json({ status: 'ok', rooms: Object.keys(rooms).length })
);

// In-memory state
// rooms[roomId] = { host, hostName, guests: Map<socketId, displayName>, queue, nowPlaying, isPlaying, position, timestamp }
const rooms = {};

function generateRoomCode() {
  let code;
  do {
    code = crypto.randomBytes(3).toString('hex').toUpperCase();
  } while (rooms[code]);
  return code;
}

// Broadcast guest list (names + count) to everyone in a room
function broadcastGuestList(roomId) {
  const room = rooms[roomId];
  if (!room) return;
  const guests = Array.from(room.guests.entries()).map(([, name]) => name);
  io.to(roomId).emit('guest_list_changed', {
    count: room.guests.size,
    guests,
    hostName: room.hostName,
  });
}

// Broadcast updated queue state to all in room
function broadcastQueueState(roomId) {
  const room = rooms[roomId];
  if (!room) return;
  io.to(roomId).emit('state_synced', {
    nowPlaying: room.nowPlaying,
    isPlaying: room.isPlaying,
    queue: room.queue,
    position: room.position,
    timestamp: room.timestamp,
  });
}

io.on('connection', (socket) => {
  console.log(`[+] Connected: ${socket.id}`);

  // ── Host Creates a Room ──────────────────────────────────────────
  socket.on('create_room', ({ roomId, hostName } = {}, callback) => {
    // Support both (roomId, cb) and ({roomId, hostName}, cb) call signatures
    // for backward compat when roomId is passed as a plain string
    let code = roomId;
    let name = hostName || 'Host';
    if (typeof roomId !== 'string') {
      // Old call: create_room(plainCode, callback)
      code = typeof roomId === 'string' ? roomId : generateRoomCode();
      name = 'Host';
    }
    code = (code || generateRoomCode()).trim().toUpperCase();

    rooms[code] = {
      host: socket.id,
      hostName: name,
      guests: new Map(),
      queue: [],
      nowPlaying: null,
      isPlaying: false,
      position: 0,
      timestamp: Date.now(),
    };
    socket.join(code);
    socket.data.roomId = code;
    socket.data.isHost = true;
    socket.data.displayName = name;
    console.log(`[Host] ${name} (${socket.id}) created room: ${code}`);
    if (typeof callback === 'function') callback({ success: true, roomId: code });
  });

  // ── Guest Joins a Room ───────────────────────────────────────────
  socket.on('join_room', ({ roomId, displayName } = {}, callback) => {
    // Backward compat: join_room can be called with plain string roomId
    const code = (typeof roomId === 'string' ? roomId : roomId?.roomId ?? '')
      .trim().toUpperCase();
    const name = displayName || `Guest#${socket.id.substring(0, 4).toUpperCase()}`;

    const room = rooms[code];
    if (!room) {
      if (callback) callback({ success: false, error: 'Room not found. Check the code and try again.' });
      return;
    }
    socket.join(code);
    room.guests.set(socket.id, name);
    socket.data.roomId = code;
    socket.data.isHost = false;
    socket.data.displayName = name;
    console.log(`[Guest] ${name} (${socket.id}) joined room: ${code}`);
    broadcastGuestList(code);
    if (callback) {
      callback({
        success: true,
        queue: room.queue,
        nowPlaying: room.nowPlaying,
        isPlaying: room.isPlaying,
        position: room.position,
        timestamp: room.timestamp,
        guestCount: room.guests.size,
      });
    }
  });

  // ── Guest Leaves a Room ──────────────────────────────────────────
  socket.on('leave_room', (roomId) => {
    const room = rooms[roomId];
    if (room) {
      room.guests.delete(socket.id);
      socket.leave(roomId);
      console.log(`[Guest] ${socket.id} left room: ${roomId}`);
      broadcastGuestList(roomId);
    }
    socket.data.roomId = null;
    socket.data.isHost = false;
  });

  // ── Guest Adds a Track ───────────────────────────────────────────
  // FIX: now persists track to room.queue AND broadcasts to ALL guests
  socket.on('add_track', ({ roomId, track, guestName }) => {
    const room = rooms[roomId];
    if (!room) return;
    const name = guestName || socket.data.displayName || 'A guest';
    // Persist to queue
    room.queue.push(track);
    // Notify host (for snackbar)
    io.to(room.host).emit('guest_added_track', { track, guestName: name });
    // Broadcast updated queue to EVERYONE in the room
    broadcastQueueState(roomId);
    console.log(`[Queue] "${track?.title}" added by ${name} in room ${roomId}`);
  });

  // ── Host Adds a Track Directly ───────────────────────────────────
  socket.on('add_track_by_host', ({ roomId, track }) => {
    const room = rooms[roomId];
    if (!room || room.host !== socket.id) return;
    room.queue.push(track);
    broadcastQueueState(roomId);
    console.log(`[Queue] Host added "${track?.title}" in room ${roomId}`);
  });

  // ── Host Syncs Full State ────────────────────────────────────────
  socket.on('host_sync_state', ({ roomId, nowPlaying, isPlaying, queue, position, timestamp }) => {
    const room = rooms[roomId];
    if (!room || room.host !== socket.id) return;

    if (nowPlaying !== undefined) room.nowPlaying = nowPlaying;
    if (isPlaying !== undefined) room.isPlaying = isPlaying;
    if (queue !== undefined) room.queue = queue;
    if (position !== undefined) room.position = position;
    if (timestamp !== undefined) room.timestamp = timestamp;

    socket.to(roomId).emit('state_synced', {
      nowPlaying: room.nowPlaying,
      isPlaying: room.isPlaying,
      queue: room.queue,
      position: room.position,
      timestamp: room.timestamp,
    });
  });

  // ── Guest Requests Re-sync ───────────────────────────────────────
  socket.on('request_sync', (roomId, callback) => {
    const room = rooms[roomId];
    if (!room) {
      if (callback) callback({ success: false });
      return;
    }
    io.to(room.host).emit('sync_requested', { guestId: socket.id });
    if (callback) callback({ success: true });
  });

  // ── Host Removes a Track ─────────────────────────────────────────
  socket.on('kick_track', ({ roomId, trackIndex }) => {
    const room = rooms[roomId];
    if (!room || room.host !== socket.id) return;
    if (trackIndex >= 0 && trackIndex < room.queue.length) {
      room.queue.splice(trackIndex, 1);
      broadcastQueueState(roomId);
    }
  });

  // ── Disconnect ───────────────────────────────────────────────────
  socket.on('disconnect', () => {
    console.log(`[-] Disconnected: ${socket.id}`);
    const roomId = socket.data.roomId;
    if (!roomId || !rooms[roomId]) return;

    const room = rooms[roomId];
    if (room.host === socket.id) {
      io.to(roomId).emit('room_closed', { reason: 'The host ended the session.' });
      delete rooms[roomId];
      console.log(`[Room] ${roomId} closed — host disconnected.`);
    } else {
      room.guests.delete(socket.id);
      broadcastGuestList(roomId);
      console.log(`[Room] Guest ${socket.id} disconnected from ${roomId}.`);
    }
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Aux Cloud Relay listening on port ${PORT}`);
});
