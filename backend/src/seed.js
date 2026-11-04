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
    {id: 'maianh-user', email: 'maianh@lifequest.vn', name: 'Mai Anh', xp: 320, streak: 5, longest: 9, interests: '["Cầu lông", "Yoga"]'},
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

  // 4. CLB thể thao & học tập của nhóm (Lãm, Kỳ, Lợi, Tuấn + Mai Anh) kèm tin nhắn mẫu
  const clubs = [
    {id: 'club-badminton', name: 'CLB Cầu Lông Chiều Thứ 7', desc: 'Hẹn nhau đánh cầu lông mỗi chiều thứ 7 tại sân HUTECH', code: 'CAULONG26', owner: 'ky-user', members: ['lam-admin', 'loi-user', 'tuan-user', 'maianh-user']},
    {id: 'club-football', name: 'Hội Bóng Đá Cuối Tuần', desc: 'Đá bóng sân 7 giao hữu Chủ nhật hàng tuần', code: 'BONGDA26', owner: 'loi-user', members: ['ky-user', 'tuan-user', 'lam-admin']},
    {id: 'club-flutter', name: 'Nhóm Học Flutter Nhóm 10', desc: 'Cùng làm đồ án Lập trình thiết bị di động', code: 'FLUTTER26', owner: 'lam-admin', members: ['ky-user', 'loi-user', 'tuan-user']},
  ];
  for (const c of clubs) {
    if (db.prepare('SELECT 1 x FROM groups_ WHERE id=?').get(c.id)) continue;
    const h = createHash('sha256').update('lifequest-invite:' + c.code).digest('hex');
    ins('INSERT INTO groups_ VALUES (?,?,?,?,?,?,?,?)', c.id, c.name, c.desc, c.owner, h, c.code, new Date(Date.now() + 365 * 864e5).toISOString(), now);
    ins("INSERT INTO group_members VALUES (?,?, 'owner', ?)", c.id, c.owner, now);
    for (const m of c.members) ins("INSERT OR IGNORE INTO group_members VALUES (?,?, 'member', ?)", c.id, m, now);
  }

  const minutesAgo = (m) => new Date(Date.now() - m * 60000).toISOString();
  const addMsg = (id, group, from, to, content, ago) => {
    if (db.prepare('SELECT 1 x FROM messages WHERE id=?').get(id)) return;
    ins('INSERT INTO messages (id,group_id,sender_id,receiver_id,content,created_at) VALUES (?,?,?,?,?,?)', id, group, from, to, content, minutesAgo(ago));
  };
  // Tin nhắn nhóm
  addMsg('m-bad-1', 'club-badminton', 'ky-user', null, 'Chiều thứ 7 này 17h đánh cầu lông nhé mọi người 🏸', 300);
  addMsg('m-bad-2', 'club-badminton', 'maianh-user', null, 'Mình tham gia! Ai mang cầu không?', 280);
  addMsg('m-bad-3', 'club-badminton', 'loi-user', null, 'Lợi mang 2 ống cầu, Tuấn lo đặt sân nha', 260);
  addMsg('m-bad-4', 'club-badminton', 'tuan-user', null, 'OK, Tuấn đặt sân số 3 lúc 17h.', 240);
  addMsg('m-bad-5', 'club-badminton', 'lam-admin', null, 'Mình đến muộn 15 phút, cứ bắt đầu trước nhé 👍', 200);
  addMsg('m-fb-1', 'club-football', 'loi-user', null, 'Chủ nhật này đá sân 7, đủ 14 người chưa?', 180);
  addMsg('m-fb-2', 'club-football', 'ky-user', null, 'Kỳ rủ thêm 3 bạn lớp nữa, đủ rồi ⚽', 170);
  addMsg('m-fb-3', 'club-football', 'tuan-user', null, 'Tuấn làm thủ môn nha 🧤', 150);
  addMsg('m-fl-1', 'club-flutter', 'lam-admin', null, 'Mọi người nhớ pull code mới nhất trước khi làm phần của mình.', 120);
  addMsg('m-fl-2', 'club-flutter', 'ky-user', null, 'Kỳ làm xong màn Nhiệm vụ rồi, Lãm review giúp.', 100);
  addMsg('m-fl-3', 'club-flutter', 'loi-user', null, 'Lợi đang làm phần AI, chiều nay xong.', 80);
  addMsg('m-fl-4', 'club-flutter', 'tuan-user', null, 'Tuấn viết xong test đăng nhập, đã pass hết ✅', 60);
  // Tin nhắn 1-1
  addMsg('dm-lam-ky-1', null, 'lam-admin', 'ky-user', 'Kỳ ơi, tối nay họp nhóm lúc 8h nhé.', 90);
  addMsg('dm-lam-ky-2', null, 'ky-user', 'lam-admin', 'Ok Lãm, mình online đúng giờ.', 85);
  addMsg('dm-lam-loi-1', null, 'lam-admin', 'loi-user', 'Lợi, phần AI xong chưa?', 70);
  addMsg('dm-lam-loi-2', null, 'loi-user', 'lam-admin', 'Sắp xong rồi, tối mình gửi nhé.', 65);
  addMsg('dm-lam-tuan-1', null, 'tuan-user', 'lam-admin', 'Lãm ơi, mình gửi file test case rồi nha.', 50);
  addMsg('dm-lam-tuan-2', null, 'lam-admin', 'tuan-user', 'Nhận rồi, cảm ơn Tuấn 👍', 45);
  addMsg('dm-ky-loi-1', null, 'ky-user', 'loi-user', 'Chủ nhật đá bóng nhớ mang áo xanh nha.', 40);
  addMsg('dm-ky-loi-2', null, 'loi-user', 'ky-user', 'Ok, hẹn 6h sáng ở sân.', 35);
  addMsg('dm-ky-tuan-1', null, 'ky-user', 'tuan-user', 'Tuấn đặt sân cầu lông giúp mình nhé.', 30);
  addMsg('dm-ky-tuan-2', null, 'tuan-user', 'ky-user', 'Đã đặt sân 3 lúc 17h rồi.', 25);

  // 5. Nhiệm vụ nhóm
  const groupQuests = [
    {id: 'gq-badminton', group: 'club-badminton', owner: 'ky-user', assignee: 'tuan-user', title: 'Đặt sân cầu lông thứ 7', desc: 'Đặt sân và báo giờ cho cả nhóm.', cat: 'Sức khỏe', diff: 'easy', xp: 20, steps: ['Gọi chủ sân', 'Chốt giờ 17h', 'Báo nhóm']},
    {id: 'gq-football', group: 'club-football', owner: 'loi-user', assignee: null, title: 'Chuẩn bị trận bóng Chủ nhật', desc: 'Chia đội, mang bóng và nước uống.', cat: 'Sức khỏe', diff: 'medium', xp: 40, steps: ['Chia 2 đội', 'Mang bóng', 'Mua nước cho cả đội']},
    {id: 'gq-flutter', group: 'club-flutter', owner: 'lam-admin', assignee: 'ky-user', title: 'Hoàn thiện màn hình Nhiệm vụ', desc: 'Sửa lỗi tràn viền và hoàn tất checklist.', cat: 'Học tập', diff: 'hard', xp: 70, steps: ['Sửa lỗi overflow', 'Viết widget test', 'Chạy thử trên điện thoại thật']},
  ];
  for (const q of groupQuests) {
    if (hasQuest(q.id)) continue;
    ins('INSERT INTO quests (id,owner_id,group_id,assignee_id,title,description,category,difficulty,xp_reward,due_at,created_at,updated_at) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)',
      q.id, q.owner, q.group, q.assignee, q.title, q.desc, q.cat, q.diff, q.xp, new Date(Date.now() + 3 * 864e5).toISOString(), now, now);
    q.steps.forEach((t, i) => ins('INSERT INTO quest_steps VALUES (?,?,?,0,?)', randomUUID(), q.id, t, i));
  }

  // Thông báo ban đầu
  ins('INSERT OR IGNORE INTO notifications VALUES (?,?,?,?,0,?)', 'notif-lam', 'lam-admin', 'Chào mừng Lãm đến LifeQuest', 'Bắt đầu ngày mới với mục tiêu rèn luyện và quản lý!', now);
  ins('INSERT OR IGNORE INTO notifications VALUES (?,?,?,?,0,?)', 'notif-ky', 'ky-user', 'Lời mời cầu lông', 'CLB Cầu Lông Chiều Thứ 7 hẹn 17h thứ 7 này!', now);
  ins('INSERT OR IGNORE INTO notifications VALUES (?,?,?,?,0,?)', 'notif-demo', 'demo-user', 'Chào mừng đến LifeQuest', 'Bắt đầu một nhiệm vụ nhỏ hôm nay nhé!', now);

  return true;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  console.log(seed(openDb()) ? 'Đã tạo/cập nhật dữ liệu demo.' : 'DB đã có dữ liệu.');
}
