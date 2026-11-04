-- Tin nhắn nhóm (group_id != NULL) và tin nhắn 1-1 (receiver_id != NULL)
CREATE TABLE IF NOT EXISTS messages (
  id TEXT PRIMARY KEY,
  group_id TEXT REFERENCES groups_(id) ON DELETE CASCADE,
  sender_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  receiver_id TEXT REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TEXT NOT NULL,
  CHECK ((group_id IS NOT NULL) <> (receiver_id IS NOT NULL))
);
CREATE INDEX IF NOT EXISTS idx_messages_group ON messages(group_id, created_at);
CREATE INDEX IF NOT EXISTS idx_messages_dm ON messages(sender_id, receiver_id, created_at);
