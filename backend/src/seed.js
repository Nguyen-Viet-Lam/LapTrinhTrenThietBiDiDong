import bcrypt from 'bcryptjs';
import {createHash, randomUUID} from 'node:crypto';
import {fileURLToPath} from 'node:url';
import {openDb} from './db.js';

// Dữ liệu mẫu hệ thống LifeQuest
export function seed(db) {
  const now = new Date().toISOString();
  const pw = bcrypt.hashSync('123456', 10);
  const ins = (sql, ...p) => db.prepare(sql).run(...p);
  const hasUser = (email) => !!db.prepare('SELECT 1 x FROM users WHERE email=?').get(email);

  // 1. Admin & Users theo yêu cầu
  const initialUsers = [
    {id: 'lam-admin', email: 'lam@lifequest.vn', name: 'Lãm', xp: 450, streak: 7, longest: 14, interests: '["Quản trị", "Thể thao", "Học tập"]'},
    {id: 'ky-user', email: 'ky@lifequest.vn', name: 'Kỳ', xp: 280, streak: 4, longest: 8, interests: '["Cầu lông", "Bóng đá"]'},
    {id: 'loi-user', email: 'loi@lifequest.vn', name: 'Lợi', xp: 190, streak: 2, longest: 5, interests: '["Chạy bộ", "Đọc sách"]'},
    {id: 'tuan-user', email: 'tuan@lifequest.vn', name: 'Tuấn (Khách)', xp: 50, streak: 1, longest: 2, interests: '["Khám phá", "Thể thao"]'},
    {id: 'demo-user', email: 'demo@lifequest.vn', name: 'Thành Viên Demo', xp: 450, streak: 7, longest: 14, interests: '["Học tập", "Thể thao"]'},
    {id: 'friend-user', email: 'ban@lifequest.vn', name: 'Gia Huy', xp: 180, streak: 3, longest: 5, interests: '["Sức khỏe"]'},
  ];

  for (const u of initialUsers) {
    if (!hasUser(u.email)) {
      ins(
        'INSERT INTO users (id,email,display_name,password_hash,xp,streak,longest_streak,last_active_date,onboarding_completed,interests,created_at) VALUES (?,?,?,?,?,?,?,?,1,?,?)',
        u.id, u.email, u.name, pw, u.xp, u.streak, u.longest, now.slice(0, 10), u.interests, now
      );
    }
  }

  // 2. Nhóm thể thao & học tập
  const hasGroup = !!db.prepare('SELECT 1 x FROM groups_ WHERE id=?').get('sample-group');
  if (!hasGroup) {
    const hash = createHash('sha256').update('lifequest-invite:LIFE2026').digest('hex');
    ins('INSERT INTO groups_ VALUES (?,?,?,?,?,?,?,?)', 'sample-group', 'CLB Thể Thao & Phát Triển Bản Thân', 'Cùng rèn luyện sức khỏe, thói quen tốt mỗi ngày', 'demo-user', hash, 'LIFE2026', new Date(Date.now() + 365 * 864e5).toISOString(), now);
    ins("INSERT OR IGNORE INTO group_members VALUES ('sample-group','demo-user','owner',?)", now);
    ins("INSERT OR IGNORE INTO group_members VALUES ('sample-group','lam-admin','owner',?)", now);
    ins("INSERT OR IGNORE INTO group_members VALUES ('sample-group','friend-user','member',?)", now);
    ins("INSERT OR IGNORE INTO group_members VALUES ('sample-group','ky-user','member',?)", now);
    ins("INSERT OR IGNORE INTO group_members VALUES ('sample-group','loi-user','member',?)", now);
    ins("INSERT OR IGNORE INTO group_members VALUES ('sample-group','tuan-user','member',?)", now);
  }

  // 3. Nhiệm vụ thể thao & học tập (Dành cho thành viên Kỳ, Lợi, Tuấn; Admin không làm nhiệm vụ)
  const questData = [
    {
      id: 'quest-badminton',
      owner: 'ky-user',
      title: 'Đánh cầu lông cùng bạn bè',
      desc: 'Rèn luyện phản xạ và sức bền vào buổi chiều 17h.',
      cat: 'Sức khỏe',
      diff: 'medium',
      xp: 40,
      steps: ['Khởi động các khớp cổ tay, cổ chân', 'Đánh cầu ít nhất 3 set', 'Thả lỏng cơ thể sau khi chơi']
    },
    {
      id: 'quest-football',
      owner: 'ky-user',
      title: 'Đá bóng giao hữu cuối tuần',
      desc: 'Tham gia trận bóng sân 7 cùng anh em câu lạc bộ.',
      cat: 'Sức khỏe',
      diff: 'medium',
      xp: 50,
      steps: ['Mang giày thể thao và đồ bảo hộ', 'Chạy khởi động 10 phút', 'Đá đủ 60 phút trận đấu']
    },
    {
      id: 'quest-running',
      owner: 'loi-user',
      title: 'Chạy bộ 5km buổi sáng',
      desc: 'Khởi đầu ngày mới tràn đầy năng lượng với đường chạy 5km quanh công viên.',
      cat: 'Sức khỏe',
      diff: 'easy',
      xp: 30,
      steps: ['Uống 1 cốc nước ấm', 'Chạy bộ duy trì pace đều 5km', 'Ghi nhận thành tích trên Strava']
    },
    {
      id: 'quest-flutter',
      owner: 'tuan-user',
      title: 'Học lập trình ứng dụng Flutter',
      desc: 'Tìm hiểu Flutter State Management Riverpod và hoàn thành bài tập thực hành.',
      cat: 'Học tập',
      diff: 'hard',
      xp: 60,
      steps: ['Đọc tài liệu Flutter Riverpod', 'Cài đặt và thiết kế giao diện trên Android Studio', 'Chạy thử ứng dụng trên máy ảo']
    },
    {
      id: 'sample-quest',
      owner: 'demo-user',
      title: 'Đi bộ 20 phút',
      desc: 'Vận động nhẹ sau giờ học',
      cat: 'Sức khỏe',
      diff: 'easy',
      xp: 20,
      steps: ['Chuẩn bị giày', 'Đi bộ đủ 20 phút', 'Uống nước']
    }
  ];

  // Đảm bảo Admin không có nhiệm vụ cá nhân (Admin chỉ quản lý)
  ins("UPDATE quests SET owner_id='ky-user' WHERE id IN ('quest-badminton', 'quest-football') AND owner_id='lam-admin'");
  ins("UPDATE quests SET owner_id='loi-user' WHERE id='quest-running' AND owner_id='lam-admin'");
  ins("UPDATE quests SET owner_id='tuan-user' WHERE id='quest-flutter' AND owner_id='lam-admin'");
  ins("DELETE FROM quests WHERE owner_id='lam-admin'");

  const hasQuest = (id) => !!db.prepare('SELECT 1 x FROM quests WHERE id=?').get(id);

  for (const q of questData) {
    if (!hasQuest(q.id)) {
      ins(
        'INSERT INTO quests (id,owner_id,title,description,category,difficulty,xp_reward,due_at,created_at,updated_at) VALUES (?,?,?,?,?,?,?,?,?,?)',
        q.id, q.owner, q.title, q.desc, q.cat, q.diff, q.xp,
        new Date(Date.now() + 24 * 36e5).toISOString(), now, now
      );
      q.steps.forEach((t, i) => ins('INSERT INTO quest_steps VALUES (?,?,?,0,?)', randomUUID(), q.id, t, i));
    }
    // Also add to demo-user if not sample-quest
    if (q.owner !== 'demo-user') {
      const demoQuestId = `${q.id}-demo`;
      if (!hasQuest(demoQuestId)) {
        ins(
          'INSERT INTO quests (id,owner_id,title,description,category,difficulty,xp_reward,due_at,created_at,updated_at) VALUES (?,?,?,?,?,?,?,?,?,?)',
          demoQuestId, 'demo-user', q.title, q.desc, q.cat, q.diff, q.xp,
          new Date(Date.now() + 24 * 36e5).toISOString(), now, now
        );
        q.steps.forEach((t, i) => ins('INSERT INTO quest_steps VALUES (?,?,?,0,?)', randomUUID(), demoQuestId, t, i));
      }
    }
  }

  // Thông báo ban đầu
  ins('INSERT OR IGNORE INTO notifications VALUES (?,?,?,?,0,?)', 'notif-lam', 'lam-admin', 'Chào mừng Lãm đến LifeQuest', 'Bắt đầu ngày mới với mục tiêu rèn luyện và quản lý!', now);
  ins('INSERT OR IGNORE INTO notifications VALUES (?,?,?,?,0,?)', 'notif-demo', 'demo-user', 'Chào mừng đến LifeQuest', 'Bắt đầu một nhiệm vụ nhỏ hôm nay nhé!', now);

  return true;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  console.log(seed(openDb()) ? 'Đã tạo/cập nhật dữ liệu demo.' : 'DB đã có dữ liệu.');
}
