const express = require('express');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// In-memory state
// rooms[roomId] = { host: socketId, queue: [], state: {} }
const rooms = {};

io.on('connection', (socket) => {
  console.log(`[+] User connected: ${socket.id}`);

  // ── Host Creates a Room ──
  socket.on('create_room', (roomId, callback) => {
    rooms[roomId] = {
      host: socket.id,
      queue: [],
      nowPlaying: null,
      isPlaying: false
    };
    socket.join(roomId);
    console.log(`[Host] ${socket.id} created room: ${roomId}`);
    if (callback) callback({ success: true, roomId });
  });

  // ── Guest Joins a Room ──
  socket.on('join_room', (roomId, callback) => {
    if (rooms[roomId]) {
      socket.join(roomId);
      console.log(`[Guest] ${socket.id} joined room: ${roomId}`);
      // Send current state to the new guest
      if (callback) {
        callback({
          success: true,
          queue: rooms[roomId].queue,
          nowPlaying: rooms[roomId].nowPlaying,
          isPlaying: rooms[roomId].isPlaying
        });
      }
    } else {
      if (callback) callback({ success: false, error: 'Room not found' });
    }
  });

  // ── Add Track to Queue ──
  socket.on('add_track', ({ roomId, track }) => {
    const room = rooms[roomId];
    if (room) {
      room.queue.push(track);
      io.to(roomId).emit('queue_updated', room.queue);
      console.log(`[Queue] Track added in ${roomId}`);
    }
  });

  // ── Host Syncs Current State ──
  // The host periodically (or on change) tells the room what's currently playing
  socket.on('host_sync_state', ({ roomId, nowPlaying, isPlaying, queue }) => {
    const room = rooms[roomId];
    if (room && room.host === socket.id) {
      room.nowPlaying = nowPlaying !== undefined ? nowPlaying : room.nowPlaying;
      room.isPlaying = isPlaying !== undefined ? isPlaying : room.isPlaying;
      room.queue = queue !== undefined ? queue : room.queue;
      
      // Broadcast to all guests (exclude host)
      socket.to(roomId).emit('state_synced', {
        nowPlaying: room.nowPlaying,
        isPlaying: room.isPlaying,
        queue: room.queue
      });
    }
  });

  // ── Disconnect ──
  socket.on('disconnect', () => {
    console.log(`[-] User disconnected: ${socket.id}`);
    // If host disconnects, ideally destroy the room or transfer host
    for (const [roomId, room] of Object.entries(rooms)) {
      if (room.host === socket.id) {
        io.to(roomId).emit('room_closed');
        delete rooms[roomId];
        console.log(`[Room] ${roomId} closed because host left.`);
      }
    }
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Aux Cloud Relay listening on port ${PORT}`);
});
