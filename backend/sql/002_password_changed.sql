-- v2: thời điểm đổi mật khẩu gần nhất
ALTER TABLE users ADD COLUMN password_changed_at TEXT;
