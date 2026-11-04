import express from 'express';
import cors from 'cors';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import {createHash, randomBytes, randomUUID} from 'node:crypto';
import {z} from 'zod';
import {openDb, tx} from './db.js';
import {generatePlan, isUnsafe} from './ai.js';

const XP = {easy: 20, medium: 40, hard: 70};
const CATEGORIES = ['Sức khỏe', 'Học tập', 'Công việc', 'Gia đình', 'Khác'];
const now = () => new Date().toISOString();
const dateKey = (d = new Date()) => d.toISOString().slice(0, 10);
export const levelForXp = (xp) => Math.floor(Math.sqrt(xp / 100)) + 1;
const hashInvite = (c) => createHash('sha256').update(`lifequest-invite:${c.toUpperCase()}`).digest('hex');

class HttpError extends Error {
  constructor(status, message) { super(message); this.status = status; }
}
const bad = (m) => new HttpError(400, m);
const forbidden = (m = 'Bạn không có quyền thực hiện thao tác này.') => new HttpError(403, m);
const notFound = (m = 'Không tìm thấy dữ liệu.') => new HttpError(404, m);

const str = (max) => z.string().trim().min(1).max(max);
const questBase = z.object({
  title: str(80), description: z.string().trim().max(500).default(''), category: z.enum(CATEGORIES).default('Khác'),
  difficulty: z.enum(['easy', 'medium', 'hard']).default('easy'),
  steps: z.array(str(160)).max(20).default([]), dueAt: z.string().datetime({offset: true}).nullable().optional(),
  groupId: z.string().nullable().optional(), assigneeId: z.string().nullable().optional(), createdByAi: z.boolean().default(false),
});
const schemas = {
  register: z.object({email: z.string().trim().toLowerCase().email().max(120), password: z.string().min(6).max(72), displayName: str(60)}),
  login: z.object({email: z.string().trim().toLowerCase().email(), password: z.string().min(1).max(72)}),
  profile: z.object({
    displayName: str(60), interests: z.array(str(30)).max(10), onboardingCompleted: z.boolean(),
    notificationsEnabled: z.boolean(), darkMode: z.boolean(),
  }).partial(),
  quest: questBase,
  questPatch: z.object({
    title: str(80), description: z.string().trim().max(500), category: z.enum(CATEGORIES),
    difficulty: z.enum(['easy', 'medium', 'hard']), dueAt: z.string().datetime({offset: true}).nullable(),
  }).partial(),
  group: z.object({name: str(80), description: z.string().trim().max(300).default('')}),
  message: z.object({content: str(1000)}),
  report: z.object({targetType: z.enum(['user', 'quest', 'group']), targetId: str(128), reason: str(500)}),
  ai: z.object({goal: str(300), difficulty: z.enum(['easy', 'medium', 'hard']).default('easy'), constraints: z.string().max(300).optional()}),
};
const parse = (schema, data) => {
  const r = schema.safeParse(data ?? {});
  if (!r.success) throw bad(r.error.issues.map((i) => `${i.path.join('.') || 'body'}: ${i.message}`).join('; '));
  return r.data;
};

export function createApp({db = openDb(), jwtSecret = process.env.JWT_SECRET ?? 'dev-secret-change-me'} = {}) {
  const app = express();
  app.use(cors());
  app.use(express.json({limit: '100kb'}));
  const hub = new Map(); // groupId -> Set<res>  (đồng bộ nhóm thời gian thực qua SSE)

  const one = (sql, ...p) => db.prepare(sql).get(...p);
  const all = (sql, ...p) => db.prepare(sql).all(...p);
  const run = (sql, ...p) => db.prepare(sql).run(...p);
  const isMember = (gid, uid) => !!one('SELECT 1 x FROM group_members WHERE group_id=? AND user_id=?', gid, uid);
  const emit = (gid, type, data = {}) => {
    for (const res of hub.get(gid) ?? []) res.write(`event: ${type}\ndata: ${JSON.stringify({groupId: gid, ...data, at: now()})}\n\n`);
  };
  const notify = (uid, title, body) => run('INSERT INTO notifications VALUES (?,?,?,?,0,?)', randomUUID(), uid, title, body, now());

  const badges = (u) => {
    const done = one("SELECT COUNT(*) c FROM quests WHERE completed_by=? AND status='completed'", u.id).c;
    const list = [];
    if (done >= 1) list.push({id: 'first-quest', name: 'Khởi đầu', description: 'Hoàn thành quest đầu tiên'});
    if (done >= 10) list.push({id: 'ten-quests', name: 'Chăm chỉ', description: 'Hoàn thành 10 quest'});
    if (u.longest_streak >= 3) list.push({id: 'streak-3', name: 'Chuỗi 3 ngày', description: 'Duy trì streak 3 ngày'});
    if (u.longest_streak >= 7) list.push({id: 'streak-7', name: 'Chuỗi 7 ngày', description: 'Duy trì streak 7 ngày'});
    if (levelForXp(u.xp) >= 5) list.push({id: 'level-5', name: 'Cấp 5', description: 'Đạt cấp độ 5'});
    return list;
  };
  const userDto = (u) => ({
    id: u.id, email: u.email, displayName: u.display_name, xp: u.xp, level: levelForXp(u.xp), streak: u.streak,
    longestStreak: u.longest_streak, lastActiveDate: u.last_active_date, onboardingCompleted: !!u.onboarding_completed,
    interests: JSON.parse(u.interests), notificationsEnabled: !!u.notifications_enabled, darkMode: !!u.dark_mode,
    badges: badges(u), createdAt: u.created_at,
    role: (u.email === 'lam@lifequest.vn' || u.email.includes('admin')) ? 'admin' : 'user',
  });
  const questDto = (q) => {
    const steps = all('SELECT id,title,is_done FROM quest_steps WHERE quest_id=? ORDER BY position', q.id)
      .map((s) => ({id: s.id, title: s.title, isDone: !!s.is_done}));
    const doneCount = steps.filter((s) => s.isDone).length;
    return {
      id: q.id, ownerId: q.owner_id, groupId: q.group_id, assigneeId: q.assignee_id, title: q.title, description: q.description,
      category: q.category, difficulty: q.difficulty, status: q.status, xpReward: q.xp_reward, xpAwarded: !!q.xp_awarded,
      createdByAi: !!q.created_by_ai, dueAt: q.due_at, completedAt: q.completed_at, createdAt: q.created_at, steps,
      progress: steps.length ? doneCount / steps.length : (q.status === 'completed' ? 1 : 0),
    };
  };
  const groupDto = (g, uid) => ({
    id: g.id, name: g.name, description: g.description, ownerId: g.owner_id, createdAt: g.created_at,
    inviteCode: g.owner_id === uid ? g.invite_code : undefined,
    members: all('SELECT u.id,u.display_name,m.role,m.joined_at FROM group_members m JOIN users u ON u.id=m.user_id WHERE m.group_id=? ORDER BY m.joined_at', g.id)
      .map((m) => ({id: m.id, displayName: m.display_name, role: m.role, joinedAt: m.joined_at})),
  });
  const loadQuest = (id, uid) => {
    const q = one('SELECT * FROM quests WHERE id=?', id);
    if (!q) throw notFound('Không tìm thấy quest.');
    const member = q.group_id && isMember(q.group_id, uid);
    if (q.owner_id !== uid && q.assignee_id !== uid && !member) throw notFound('Không tìm thấy quest.');
    return {q, canEdit: q.owner_id === uid || q.assignee_id === uid || (member && !q.assignee_id)};
  };

  const auth = (req, _res, next) => {
    const raw = req.headers.authorization?.replace(/^Bearer /i, '') ?? req.query.token;
    try {
      const {sub} = jwt.verify(String(raw), jwtSecret);
      const u = one('SELECT * FROM users WHERE id=?', sub);
      if (!u) throw new Error('gone');
      req.user = u;
      next();
    } catch { next(new HttpError(401, 'Phiên đăng nhập không hợp lệ hoặc đã hết hạn.')); }
  };
  const wrap = (fn) => (req, res, next) => {
    try { Promise.resolve(fn(req, res)).catch(next); } catch (e) { next(e); }
  };
  const token = (u) => jwt.sign({sub: u.id}, jwtSecret, {expiresIn: '7d'});

  app.get('/api/health', (_q, res) => res.json({ok: true, time: now()}));

  // ---------- Auth & profile ----------
  app.post('/api/auth/register', wrap((req, res) => {
    const d = parse(schemas.register, req.body);
    if (one('SELECT 1 x FROM users WHERE email=?', d.email)) throw new HttpError(409, 'Email đã được đăng ký.');
    const id = randomUUID();
    run('INSERT INTO users (id,email,display_name,password_hash,created_at) VALUES (?,?,?,?,?)', id, d.email, d.displayName, bcrypt.hashSync(d.password, 10), now());
    notify(id, 'Chào mừng đến LifeQuest', 'Bắt đầu một nhiệm vụ nhỏ hôm nay nhé!');
    const u = one('SELECT * FROM users WHERE id=?', id);
    res.status(201).json({token: token(u), user: userDto(u)});
  }));
  // Chống dò mật khẩu: tối đa 5 lần sai / 15 phút cho mỗi email
  const fails = new Map();
  const MAX_FAILS = Number(process.env.LOGIN_MAX_FAILS ?? 5), WINDOW = 15 * 60 * 1000;
  app.post('/api/auth/login', wrap((req, res) => {
    const d = parse(schemas.login, req.body);
    const rec = fails.get(d.email);
    if (rec && Date.now() - rec.first < WINDOW && rec.count >= MAX_FAILS) throw new HttpError(429, 'Đăng nhập sai quá nhiều lần. Vui lòng thử lại sau 15 phút.');
    const u = one('SELECT * FROM users WHERE email=?', d.email);
    if (!u || !bcrypt.compareSync(d.password, u.password_hash)) {
      const fresh = !rec || Date.now() - rec.first >= WINDOW;
      fails.set(d.email, fresh ? {first: Date.now(), count: 1} : {first: rec.first, count: rec.count + 1});
      throw new HttpError(401, 'Email hoặc mật khẩu không đúng.');
    }
    fails.delete(d.email);
    res.json({token: token(u), user: userDto(u)});
  }));
  app.post('/api/auth/change-password', auth, wrap((req, res) => {
    const d = parse(z.object({currentPassword: z.string().min(1).max(72), newPassword: z.string().min(6).max(72)}), req.body);
    if (!bcrypt.compareSync(d.currentPassword, req.user.password_hash)) throw new HttpError(401, 'Mật khẩu hiện tại không đúng.');
    run('UPDATE users SET password_hash=?, password_changed_at=? WHERE id=?', bcrypt.hashSync(d.newPassword, 10), now(), req.user.id);
    res.json({ok: true});
  }));
  app.get('/api/me', auth, (req, res) => res.json(userDto(req.user)));
  app.patch('/api/me', auth, wrap((req, res) => {
    const d = parse(schemas.profile, req.body);
    const col = {displayName: 'display_name', onboardingCompleted: 'onboarding_completed', notificationsEnabled: 'notifications_enabled', darkMode: 'dark_mode', interests: 'interests'};
    for (const [k, v] of Object.entries(d)) {
      run(`UPDATE users SET ${col[k]}=? WHERE id=?`, k === 'interests' ? JSON.stringify(v) : typeof v === 'boolean' ? +v : v, req.user.id);
    }
    res.json(userDto(one('SELECT * FROM users WHERE id=?', req.user.id)));
  }));
  app.delete('/api/me', auth, wrap((req, res) => {
    run('DELETE FROM users WHERE id=?', req.user.id); // ON DELETE CASCADE xóa dữ liệu liên quan
    res.status(204).end();
  }));
  app.get('/api/stats', auth, wrap((req, res) => {
    const c = (s) => one('SELECT COUNT(*) c FROM quests WHERE (owner_id=? OR assignee_id=?) AND status=?', req.user.id, req.user.id, s).c;
    const u = userDto(req.user);
    res.json({xp: u.xp, level: u.level, xpToNextLevel: u.level * u.level * 100 - u.xp, streak: u.streak, active: c('active'), completed: c('completed'), archived: c('archived'), badges: u.badges});
  }));

  // ---------- Quests ----------
  app.get('/api/quests', auth, wrap((req, res) => {
    const where = ['(q.owner_id=@u OR q.assignee_id=@u OR q.group_id IN (SELECT group_id FROM group_members WHERE user_id=@u))'];
    where.push('(q.owner_id=@u OR q.owner_id NOT IN (SELECT blocked_id FROM blocks WHERE user_id=@u))');
    const p = {u: req.user.id};
    if (req.query.status) { where.push('q.status=@s'); p.s = String(req.query.status); }
    if (req.query.groupId) { where.push('q.group_id=@g'); p.g = String(req.query.groupId); }
    if (req.query.q) { where.push('(q.title LIKE @k OR q.description LIKE @k)'); p.k = `%${String(req.query.q).replace(/[%_]/g, '')}%`; }
    const rows = db.prepare(`SELECT q.* FROM quests q WHERE ${where.join(' AND ')} ORDER BY q.status='active' DESC, q.due_at IS NULL, q.due_at, q.created_at DESC`).all(p);
    res.json(rows.map(questDto));
  }));
  app.post('/api/quests', auth, wrap((req, res) => {
    const d = parse(schemas.quest, req.body);
    if (d.groupId && !isMember(d.groupId, req.user.id)) throw forbidden('Bạn không thuộc nhóm này.');
    if (d.assigneeId && (!d.groupId || !isMember(d.groupId, d.assigneeId))) throw bad('Người được giao phải là thành viên của nhóm.');
    const id = randomUUID();
    tx(db, () => {
      run('INSERT INTO quests (id,owner_id,group_id,assignee_id,title,description,category,difficulty,xp_reward,created_by_ai,due_at,created_at,updated_at) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)',
        id, req.user.id, d.groupId ?? null, d.assigneeId ?? null, d.title, d.description, d.category, d.difficulty, XP[d.difficulty], +d.createdByAi, d.dueAt ?? null, now(), now());
      d.steps.forEach((t, i) => run('INSERT INTO quest_steps VALUES (?,?,?,0,?)', randomUUID(), id, t, i));
      if (d.assigneeId && d.assigneeId !== req.user.id) notify(d.assigneeId, 'Quest mới được giao', `${req.user.display_name} giao bạn: ${d.title}`);
    });
    if (d.groupId) emit(d.groupId, 'quest.created', {questId: id});
    res.status(201).json(questDto(one('SELECT * FROM quests WHERE id=?', id)));
  }));
  app.get('/api/quests/:id', auth, wrap((req, res) => res.json(questDto(loadQuest(req.params.id, req.user.id).q))));
  app.patch('/api/quests/:id', auth, wrap((req, res) => {
    const {q, canEdit} = loadQuest(req.params.id, req.user.id);
    if (!canEdit) throw forbidden();
    if (q.status !== 'active') throw new HttpError(409, 'Chỉ sửa được quest đang hoạt động.');
    const d = parse(schemas.questPatch, req.body);
    const diff = d.difficulty ?? q.difficulty;
    run('UPDATE quests SET title=?,description=?,category=?,difficulty=?,xp_reward=?,due_at=?,updated_at=? WHERE id=?',
      d.title ?? q.title, d.description ?? q.description, d.category ?? q.category, diff, XP[diff],
      d.dueAt === undefined ? q.due_at : d.dueAt, now(), q.id);
    if (q.group_id) emit(q.group_id, 'quest.updated', {questId: q.id});
    res.json(questDto(one('SELECT * FROM quests WHERE id=?', q.id)));
  }));
  app.post('/api/quests/:id/steps/:stepId/toggle', auth, wrap((req, res) => {
    const {q, canEdit} = loadQuest(req.params.id, req.user.id);
    if (!canEdit) throw forbidden();
    if (q.status !== 'active') throw new HttpError(409, 'Quest không còn hoạt động.');
    const r = run('UPDATE quest_steps SET is_done = 1 - is_done WHERE id=? AND quest_id=?', req.params.stepId, q.id);
    if (!r.changes) throw notFound('Không tìm thấy bước.');
    if (q.group_id) emit(q.group_id, 'step.toggled', {questId: q.id});
    res.json(questDto(q));
  }));
  app.post('/api/quests/:id/complete', auth, wrap((req, res) => {
    const out = tx(db, () => {
      const {q, canEdit} = loadQuest(req.params.id, req.user.id);
      const u = one('SELECT * FROM users WHERE id=?', req.user.id);
      if (!canEdit) throw forbidden();
      if (q.status === 'completed' || q.xp_awarded) return {quest: q, xpAwarded: 0, idempotent: true, user: u};
      if (q.status !== 'active') throw new HttpError(409, 'Quest không ở trạng thái hoạt động.');
      const xp = u.xp + q.xp_reward;
      const today = dateKey(), yesterday = dateKey(new Date(Date.now() - 864e5));
      const streak = u.last_active_date === today ? u.streak : u.last_active_date === yesterday ? u.streak + 1 : 1;
      run("UPDATE quests SET status='completed',xp_awarded=1,completed_at=?,completed_by=?,updated_at=? WHERE id=?", now(), u.id, now(), q.id);
      run('UPDATE quest_steps SET is_done=1 WHERE quest_id=?', q.id);
      run('UPDATE users SET xp=?,streak=?,longest_streak=?,last_active_date=? WHERE id=?', xp, streak, Math.max(u.longest_streak, streak), today, u.id);
      notify(u.id, 'Hoàn thành quest', `Bạn nhận +${q.xp_reward} XP từ "${q.title}"`);
      return {quest: one('SELECT * FROM quests WHERE id=?', q.id), xpAwarded: q.xp_reward, idempotent: false, user: one('SELECT * FROM users WHERE id=?', u.id)};
    });
    if (!out.idempotent && out.quest.group_id) emit(out.quest.group_id, 'quest.completed', {questId: out.quest.id, userId: req.user.id});
    res.json({xpAwarded: out.xpAwarded, idempotent: out.idempotent, quest: questDto(out.quest), user: userDto(out.user)});
  }));
  app.post('/api/quests/:id/archive', auth, wrap((req, res) => {
    const {q, canEdit} = loadQuest(req.params.id, req.user.id);
    if (!canEdit) throw forbidden();
    run("UPDATE quests SET status='archived',updated_at=? WHERE id=?", now(), q.id);
    if (q.group_id) emit(q.group_id, 'quest.archived', {questId: q.id});
    res.json(questDto(one('SELECT * FROM quests WHERE id=?', q.id)));
  }));
  app.delete('/api/quests/:id', auth, wrap((req, res) => {
    const {q} = loadQuest(req.params.id, req.user.id);
    if (q.owner_id !== req.user.id) throw forbidden('Chỉ người tạo mới được xóa quest.');
    run('DELETE FROM quests WHERE id=?', q.id);
    if (q.group_id) emit(q.group_id, 'quest.deleted', {questId: q.id});
    res.status(204).end();
  }));

  // ---------- Groups ----------
  app.get('/api/groups', auth, wrap((req, res) => {
    res.json(all('SELECT g.* FROM groups_ g JOIN group_members m ON m.group_id=g.id WHERE m.user_id=? ORDER BY g.created_at DESC', req.user.id).map((g) => groupDto(g, req.user.id)));
  }));
  app.post('/api/groups', auth, wrap((req, res) => {
    const d = parse(schemas.group, req.body);
    const id = randomUUID(), code = randomBytes(4).toString('hex').toUpperCase();
    tx(db, () => {
      run('INSERT INTO groups_ VALUES (?,?,?,?,?,?,?,?)', id, d.name, d.description, req.user.id, hashInvite(code), code, new Date(Date.now() + 7 * 864e5).toISOString(), now());
      run("INSERT INTO group_members VALUES (?,?, 'owner', ?)", id, req.user.id, now());
    });
    res.status(201).json(groupDto(one('SELECT * FROM groups_ WHERE id=?', id), req.user.id));
  }));
  app.post('/api/groups/join', auth, wrap((req, res) => {
    const {inviteCode} = parse(z.object({inviteCode: str(32)}), req.body);
    const g = one('SELECT * FROM groups_ WHERE invite_code_hash=?', hashInvite(inviteCode));
    if (!g) throw notFound('Mã mời không tồn tại.');
    if (new Date(g.invite_expires_at) < new Date()) throw new HttpError(410, 'Mã mời đã hết hạn.');
    if (!isMember(g.id, req.user.id)) {
      run("INSERT INTO group_members VALUES (?,?, 'member', ?)", g.id, req.user.id, now());
      notify(g.owner_id, 'Thành viên mới', `${req.user.display_name} vừa tham gia "${g.name}"`);
      emit(g.id, 'member.joined', {userId: req.user.id});
    }
    res.json(groupDto(g, req.user.id));
  }));
  app.get('/api/groups/:id', auth, wrap((req, res) => {
    if (!isMember(req.params.id, req.user.id)) throw notFound('Không tìm thấy nhóm.');
    res.json(groupDto(one('SELECT * FROM groups_ WHERE id=?', req.params.id), req.user.id));
  }));
  app.post('/api/groups/:id/leave', auth, wrap((req, res) => {
    const g = one('SELECT * FROM groups_ WHERE id=?', req.params.id);
    if (!g || !isMember(g.id, req.user.id)) throw notFound('Không tìm thấy nhóm.');
    if (g.owner_id === req.user.id) throw new HttpError(409, 'Trưởng nhóm phải chuyển quyền hoặc xóa nhóm trước khi rời.');
    run('DELETE FROM group_members WHERE group_id=? AND user_id=?', g.id, req.user.id);
    emit(g.id, 'member.left', {userId: req.user.id});
    res.status(204).end();
  }));
  app.delete('/api/groups/:id/members/:uid', auth, wrap((req, res) => {
    const g = one('SELECT * FROM groups_ WHERE id=?', req.params.id);
    if (!g || !isMember(g.id, req.user.id)) throw notFound('Không tìm thấy nhóm.');
    if (g.owner_id !== req.user.id) throw forbidden('Chỉ trưởng nhóm mới được xóa thành viên.');
    if (req.params.uid === g.owner_id) throw bad('Không thể xóa trưởng nhóm.');
    run('DELETE FROM group_members WHERE group_id=? AND user_id=?', g.id, req.params.uid);
    emit(g.id, 'member.removed', {userId: req.params.uid});
    res.status(204).end();
  }));
  app.post('/api/groups/:id/transfer', auth, wrap((req, res) => {
    const {userId} = parse(z.object({userId: str(128)}), req.body);
    const g = one('SELECT * FROM groups_ WHERE id=?', req.params.id);
    if (!g || g.owner_id !== req.user.id) throw forbidden('Chỉ trưởng nhóm mới được chuyển quyền.');
    if (!isMember(g.id, userId)) throw bad('Người nhận phải là thành viên nhóm.');
    tx(db, () => {
      run('UPDATE groups_ SET owner_id=? WHERE id=?', userId, g.id);
      run("UPDATE group_members SET role='owner' WHERE group_id=? AND user_id=?", g.id, userId);
      run("UPDATE group_members SET role='member' WHERE group_id=? AND user_id=?", g.id, req.user.id);
    });
    emit(g.id, 'owner.changed', {userId});
    res.json(groupDto(one('SELECT * FROM groups_ WHERE id=?', g.id), req.user.id));
  }));
  app.delete('/api/groups/:id', auth, wrap((req, res) => {
    const g = one('SELECT * FROM groups_ WHERE id=?', req.params.id);
    if (!g || g.owner_id !== req.user.id) throw forbidden('Chỉ trưởng nhóm mới được xóa nhóm.');
    emit(g.id, 'group.deleted');
    run('DELETE FROM groups_ WHERE id=?', g.id);
    res.status(204).end();
  }));
  // ---------- Tin nhắn ----------
  const msgDto = (m, uid) => ({
    id: m.id, groupId: m.group_id, senderId: m.sender_id, senderName: m.sender_name, receiverId: m.receiver_id,
    content: m.content, createdAt: m.created_at, isSelf: m.sender_id === uid,
  });
  const MSG_SELECT = 'SELECT m.*, u.display_name sender_name FROM messages m JOIN users u ON u.id=m.sender_id';
  app.get('/api/groups/:id/messages', auth, wrap((req, res) => {
    if (!isMember(req.params.id, req.user.id)) throw notFound('Không tìm thấy nhóm.');
    res.json(all(`${MSG_SELECT} WHERE m.group_id=? ORDER BY m.created_at DESC LIMIT 200`, req.params.id).reverse().map((m) => msgDto(m, req.user.id)));
  }));
  app.post('/api/groups/:id/messages', auth, wrap((req, res) => {
    if (!isMember(req.params.id, req.user.id)) throw notFound('Không tìm thấy nhóm.');
    const d = parse(schemas.message, req.body);
    const id = randomUUID();
    run('INSERT INTO messages (id,group_id,sender_id,content,created_at) VALUES (?,?,?,?,?)', id, req.params.id, req.user.id, d.content, now());
    emit(req.params.id, 'message.created', {messageId: id, senderId: req.user.id});
    res.status(201).json(msgDto(one(`${MSG_SELECT} WHERE m.id=?`, id), req.user.id));
  }));
  app.get('/api/messages/:peerId', auth, wrap((req, res) => {
    const me = req.user.id, peer = req.params.peerId;
    res.json(all(`${MSG_SELECT} WHERE (m.sender_id=? AND m.receiver_id=?) OR (m.sender_id=? AND m.receiver_id=?) ORDER BY m.created_at DESC LIMIT 200`, me, peer, peer, me).reverse().map((m) => msgDto(m, me)));
  }));
  app.post('/api/messages/:peerId', auth, wrap((req, res) => {
    const peer = one('SELECT id FROM users WHERE id=?', req.params.peerId);
    if (!peer || peer.id === req.user.id) throw notFound('Không tìm thấy người nhận.');
    const d = parse(schemas.message, req.body);
    const id = randomUUID();
    run('INSERT INTO messages (id,sender_id,receiver_id,content,created_at) VALUES (?,?,?,?,?)', id, req.user.id, peer.id, d.content, now());
    notify(peer.id, `Tin nhắn mới từ ${req.user.display_name}`, d.content.slice(0, 80));
    res.status(201).json(msgDto(one(`${MSG_SELECT} WHERE m.id=?`, id), req.user.id));
  }));
  // Realtime: EventSource không gửi được header nên auth chấp nhận ?token=
  app.get('/api/groups/:id/events', auth, (req, res, next) => {
    if (!isMember(req.params.id, req.user.id)) return next(notFound('Không tìm thấy nhóm.'));
    res.set({'Content-Type': 'text/event-stream', 'Cache-Control': 'no-cache', Connection: 'keep-alive'});
    res.flushHeaders();
    res.write('event: ready\ndata: {}\n\n');
    const set = hub.get(req.params.id) ?? new Set();
    set.add(res);
    hub.set(req.params.id, set);
    const ping = setInterval(() => res.write(': ping\n\n'), 25000);
    req.on('close', () => { clearInterval(ping); set.delete(res); });
  });

  // ---------- AI ----------
  app.post('/api/ai/quest-plan', auth, wrap(async (req, res) => {
    const d = parse(schemas.ai, req.body);
    if (isUnsafe(d.goal)) throw new HttpError(422, 'LifeQuest không biến nội dung nguy hiểm thành nhiệm vụ. Hãy tìm hỗ trợ từ người đáng tin cậy.');
    const last = one('SELECT last_request_at t FROM ai_requests WHERE user_id=?', req.user.id)?.t;
    if (last && Date.now() - last < Number(process.env.AI_COOLDOWN_MS ?? 5000)) throw new HttpError(429, 'Vui lòng chờ vài giây trước khi yêu cầu tiếp.');
    run('INSERT INTO ai_requests VALUES (?,?,?) ON CONFLICT(user_id) DO UPDATE SET last_request_at=excluded.last_request_at,outcome=excluded.outcome', req.user.id, Date.now(), 'started');
    try {
      const plan = await generatePlan(d);
      run("UPDATE ai_requests SET outcome='success' WHERE user_id=?", req.user.id);
      res.json(plan); // bản nháp: client cho người dùng duyệt rồi mới POST /api/quests
    } catch (e) {
      run("UPDATE ai_requests SET outcome='failed' WHERE user_id=?", req.user.id);
      console.error('AI failed:', e.message);
      throw new HttpError(502, 'AI chưa thể tạo kế hoạch. Vui lòng thử lại sau.');
    }
  }));

  // ---------- Notifications / Safety ----------
  app.get('/api/notifications', auth, wrap((req, res) => {
    res.json(all('SELECT * FROM notifications WHERE user_id=? ORDER BY created_at DESC LIMIT 100', req.user.id)
      .map((n) => ({id: n.id, title: n.title, body: n.body, isRead: !!n.is_read, createdAt: n.created_at})));
  }));
  app.post('/api/notifications/read-all', auth, wrap((req, res) => {
    run('UPDATE notifications SET is_read=1 WHERE user_id=?', req.user.id);
    res.json({ok: true});
  }));
  app.post('/api/reports', auth, wrap((req, res) => {
    const d = parse(schemas.report, req.body);
    const id = randomUUID();
    run('INSERT INTO reports VALUES (?,?,?,?,?,?)', id, req.user.id, d.targetType, d.targetId, d.reason, now());
    res.status(201).json({id});
  }));
  app.get('/api/blocks', auth, wrap((req, res) => {
    res.json(all('SELECT u.id,u.display_name FROM blocks b JOIN users u ON u.id=b.blocked_id WHERE b.user_id=?', req.user.id).map((u) => ({id: u.id, displayName: u.display_name})));
  }));
  app.post('/api/blocks', auth, wrap((req, res) => {
    const {userId} = parse(z.object({userId: str(128)}), req.body);
    if (userId === req.user.id) throw bad('Không thể tự chặn chính mình.');
    if (!one('SELECT 1 x FROM users WHERE id=?', userId)) throw notFound('Không tìm thấy người dùng.');
    run('INSERT OR IGNORE INTO blocks VALUES (?,?,?)', req.user.id, userId, now());
    res.status(201).json({ok: true});
  }));
  app.delete('/api/blocks/:uid', auth, wrap((req, res) => {
    run('DELETE FROM blocks WHERE user_id=? AND blocked_id=?', req.user.id, req.params.uid);
    res.status(204).end();
  }));

  app.use('/api', (_req, _res, next) => next(notFound('Endpoint không tồn tại.')));
  app.use((err, _req, res, _next) => {
    const status = err.status ?? (err.type === 'entity.parse.failed' ? 400 : 500);
    if (status === 500) console.error(err);
    res.status(status).json({error: status === 500 ? 'Lỗi máy chủ.' : err.message});
  });
  app.locals.db = db;
  return app;
}
