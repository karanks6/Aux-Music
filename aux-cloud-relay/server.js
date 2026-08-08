const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const crypto = require('crypto');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

app.get('/health', (req, res) => res.json({ status: 'ok', rooms: Object.keys(rooms).length }));

// In-memory state
// rooms[roomId] = { host: socketId, guests: Set<socketId>, queue: [], nowPlaying, isPlaying, position, timestamp }
const rooms = {};

// Helper: generate a 6-character alphanumeric room code that is not already taken
function generateRoomCode() {
  let code;
  do {
    code = crypto.randomBytes(3).toString('hex').toUpperCase(); // e.g. "A3F91C"
  } while (rooms[code]);
  return code;
}

// Helper: broadcast updated guest count to everyone in a room
function broadcastGuestCount(roomId) {
  const room = rooms[roomId];
  if (!room) return;
  const count = room.guests.size;
  io.to(roomId).emit('guest_count_changed', { count });
}

io.on('connection', (socket) => {
  console.log(`[+] Connected: ${socket.id}`);

  // ── Host Creates a Room ──────────────────────────────────────────
  socket.on('create_room', (_, callback) => {
    const roomId = generateRoomCode();
    rooms[roomId] = {
      host: socket.id,
      guests: new Set(),
      queue: [],
      nowPlaying: null,
      isPlaying: false,
      position: 0,
      timestamp: Date.now(),
    };
    socket.join(roomId);
    socket.data.roomId = roomId;
    socket.data.isHost = true;
    console.log(`[Host] ${socket.id} created room: ${roomId}`);
    if (callback) callback({ success: true, roomId });
  });

  // ── Guest Joins a Room ───────────────────────────────────────────
  socket.on('join_room', (roomId, callback) => {
    const room = rooms[roomId];
    if (!room) {
      if (callback) callback({ success: false, error: 'Room not found. Check the code and try again.' });
      return;
    }
    socket.join(roomId);
    room.guests.add(socket.id);
    socket.data.roomId = roomId;
    socket.data.isHost = false;
    console.log(`[Guest] ${socket.id} joined room: ${roomId}`);
    broadcastGuestCount(roomId);
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
      broadcastGuestCount(roomId);
    }
    socket.data.roomId = null;
    socket.data.isHost = false;
  });

  // ── Guest Adds a Track to Host Queue ────────────────────────────
  socket.on('add_track', ({ roomId, track, guestName }) => {
    const room = rooms[roomId];
    if (room && room.host) {
      io.to(room.host).emit('guest_added_track', { track, guestName: guestName || 'A guest' });
      console.log(`[Queue] Track "${track?.title}" forwarded to host in room ${roomId}`);
    }
  });

  // ── Host Syncs Current State to all Guests ───────────────────────
  socket.on('host_sync_state', ({ roomId, nowPlaying, isPlaying, queue, position, timestamp }) => {
    const room = rooms[roomId];
    if (!room || room.host !== socket.id) return;

    if (nowPlaying !== undefined) room.nowPlaying = nowPlaying;
    if (isPlaying !== undefined) room.isPlaying = isPlaying;
    if (queue !== undefined) room.queue = queue;
    if (position !== undefined) room.position = position;
    if (timestamp !== undefined) room.timestamp = timestamp;

    // Broadcast to all guests (excludes host socket)
    socket.to(roomId).emit('state_synced', {
      nowPlaying: room.nowPlaying,
      isPlaying: room.isPlaying,
      queue: room.queue,
      position: room.position,
      timestamp: room.timestamp,
    });
  });

  // ── Guest Requests Full Re-sync (e.g. after joining mid-song) ───
  socket.on('request_sync', (roomId, callback) => {
    const room = rooms[roomId];
    if (!room) {
      if (callback) callback({ success: false });
      return;
    }
    // Ask the host to broadcast its current state immediately
    io.to(room.host).emit('sync_requested', { guestId: socket.id });
    if (callback) callback({ success: true });
  });

  // ── Host Removes a Track from Shared Queue ───────────────────────
  socket.on('kick_track', ({ roomId, trackIndex }) => {
    const room = rooms[roomId];
    if (!room || room.host !== socket.id) return;
    if (trackIndex >= 0 && trackIndex < room.queue.length) {
      room.queue.splice(trackIndex, 1);
      // Broadcast updated queue to all in room
      io.to(roomId).emit('state_synced', {
        nowPlaying: room.nowPlaying,
        isPlaying: room.isPlaying,
        queue: room.queue,
        position: room.position,
        timestamp: room.timestamp,
      });
    }
  });

  // ── Disconnect ───────────────────────────────────────────────────
  socket.on('disconnect', () => {
    console.log(`[-] Disconnected: ${socket.id}`);
    const roomId = socket.data.roomId;
    if (!roomId || !rooms[roomId]) return;

    const room = rooms[roomId];
    if (room.host === socket.id) {
      // Host left — close the room
      io.to(roomId).emit('room_closed', { reason: 'The host ended the session.' });
      delete rooms[roomId];
      console.log(`[Room] ${roomId} closed — host disconnected.`);
    } else {
      // Guest left
      room.guests.delete(socket.id);
      broadcastGuestCount(roomId);
      console.log(`[Room] Guest ${socket.id} disconnected from ${roomId}.`);
    }
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Aux Cloud Relay listening on port ${PORT}`);
});
