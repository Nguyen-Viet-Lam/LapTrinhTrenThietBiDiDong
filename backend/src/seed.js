import bcrypt from 'bcryptjs';
import {createHash, randomUUID} from 'node:crypto';
import {fileURLToPath} from 'node:url';
import {openDb} from './db.js';

// Dữ liệu demo giống bản Flutter: demo@lifequest.vn / 123456, nhóm mã LIFE2026
export function seed(db) {
  if (db.prepare('SELECT COUNT(*) c FROM users').get().c > 0) return false;
  const now = new Date().toISOString();
  const pw = bcrypt.hashSync('123456', 10);
  const ins = (sql, ...p) => db.prepare(sql).run(...p);
  ins('INSERT INTO users (id,email,display_name,password_hash,xp,streak,longest_streak,last_active_date,onboarding_completed,interests,created_at) VALUES (?,?,?,?,?,?,?,?,1,?,?)',
    'demo-user', 'demo@lifequest.vn', 'Minh Anh', pw, 160, 3, 5, now.slice(0, 10), '["Sức khỏe","Học tập"]', now);
  ins('INSERT INTO users (id,email,display_name,password_hash,onboarding_completed,created_at) VALUES (?,?,?,?,1,?)', 'friend-user', 'ban@lifequest.vn', 'Gia Huy', pw, now);
  const hash = createHash('sha256').update('lifequest-invite:LIFE2026').digest('hex');
  ins('INSERT INTO groups_ VALUES (?,?,?,?,?,?,?,?)', 'sample-group', 'Nhóm sống khỏe', 'Cùng nhau xây dựng thói quen tốt', 'demo-user', hash, 'LIFE2026', new Date(Date.now() + 365 * 864e5).toISOString(), now);
  ins("INSERT INTO group_members VALUES ('sample-group','demo-user','owner',?)", now);
  ins("INSERT INTO group_members VALUES ('sample-group','friend-user','member',?)", now);
  ins("INSERT INTO quests (id,owner_id,title,description,category,difficulty,xp_reward,due_at,created_at,updated_at) VALUES ('sample-quest','demo-user','Đi bộ 20 phút','Vận động nhẹ sau giờ học','Sức khỏe','easy',20,?,?,?)", new Date(Date.now() + 6 * 36e5).toISOString(), now, now);
  ['Chuẩn bị giày', 'Đi bộ đủ 20 phút', 'Uống nước'].forEach((t, i) => ins('INSERT INTO quest_steps VALUES (?,?,?,0,?)', randomUUID(), 'sample-quest', t, i));
  ins('INSERT INTO notifications VALUES (?,?,?,?,0,?)', randomUUID(), 'demo-user', 'Chào mừng đến LifeQuest', 'Bắt đầu một nhiệm vụ nhỏ hôm nay nhé!', now);
  return true;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  console.log(seed(openDb()) ? 'Đã tạo dữ liệu demo.' : 'DB đã có dữ liệu.');
}
