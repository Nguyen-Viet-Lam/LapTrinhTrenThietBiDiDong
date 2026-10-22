import {test, before, after} from 'node:test';
import assert from 'node:assert/strict';
import {createApp, levelForXp} from '../src/app.js';
import {openDb} from '../src/db.js';
import {seed} from '../src/seed.js';

process.env.AI_COOLDOWN_MS = '0';
let server, base, db;
before(async () => {
  db = openDb(':memory:');
  seed(db);
  server = createApp({db, jwtSecret: 't'}).listen(0);
  base = `http://localhost:${server.address().port}/api`;
});
after(() => server.close());

const call = async (method, path, body, token) => {
  const res = await fetch(base + path, {
    method, headers: {'Content-Type': 'application/json', ...(token ? {Authorization: `Bearer ${token}`} : {})},
    body: body ? JSON.stringify(body) : undefined,
  });
  return {status: res.status, body: res.status === 204 ? null : await res.json()};
};
const login = async (email = 'demo@lifequest.vn') => (await call('POST', '/auth/login', {email, password: '123456'})).body.token;

test('level formula', () => { assert.equal(levelForXp(0), 1); assert.equal(levelForXp(100), 2); assert.equal(levelForXp(400), 3); });

test('auth: đăng ký, đăng nhập, sai mật khẩu, thiếu token', async () => {
  const r = await call('POST', '/auth/register', {email: 'a@b.vn', password: '123456', displayName: 'A'});
  assert.equal(r.status, 201);
  assert.equal((await call('POST', '/auth/register', {email: 'a@b.vn', password: '123456', displayName: 'A'})).status, 409);
  assert.equal((await call('POST', '/auth/login', {email: 'a@b.vn', password: 'sai-sai'})).status, 401);
  assert.equal((await call('GET', '/me')).status, 401);
  assert.equal((await call('POST', '/auth/register', {email: 'x', password: '1', displayName: ''})).status, 400);
});

test('quest: tạo, toggle bước, hoàn thành idempotent cộng XP một lần', async () => {
  const t = await login();
  const q = (await call('POST', '/quests', {title: 'Đọc sách', difficulty: 'hard', steps: ['Mở sách', 'Đọc 10 trang']}, t)).body;
  assert.equal(q.xpReward, 70);
  const t1 = await call('POST', `/quests/${q.id}/steps/${q.steps[0].id}/toggle`, null, t);
  assert.equal(t1.body.progress, 0.5);
  const before = (await call('GET', '/me', null, t)).body.xp;
  const c1 = await call('POST', `/quests/${q.id}/complete`, null, t);
  const c2 = await call('POST', `/quests/${q.id}/complete`, null, t);
  assert.equal(c1.body.xpAwarded, 70);
  assert.equal(c2.body.idempotent, true);
  assert.equal((await call('GET', '/me', null, t)).body.xp, before + 70);
});

test('quest: người ngoài không truy cập được', async () => {
  const t = await login();
  const outsider = (await call('POST', '/auth/register', {email: 'o@b.vn', password: '123456', displayName: 'O'})).body.token;
  assert.equal((await call('GET', '/quests/sample-quest', null, outsider)).status, 404);
  assert.equal((await call('POST', '/quests/sample-quest/complete', null, outsider)).status, 404);
  assert.equal((await call('GET', '/quests/sample-quest', null, t)).status, 200);
});

test('nhóm: join bằng mã, quest nhóm, quyền chủ nhóm, rời nhóm', async () => {
  const owner = await login();
  const friend = await login('ban@lifequest.vn');
  const newbie = (await call('POST', '/auth/register', {email: 'n@b.vn', password: '123456', displayName: 'N'})).body.token;
  assert.equal((await call('POST', '/groups/join', {inviteCode: 'SAI'}, newbie)).status, 404);
  assert.equal((await call('POST', '/groups/join', {inviteCode: 'life2026'}, newbie)).status, 200);
  assert.equal((await call('POST', '/quests', {title: 'Chạy bộ nhóm', groupId: 'sample-group'}, friend)).status, 201);
  assert.equal((await call('GET', '/quests?groupId=sample-group', null, newbie)).body.length, 1);
  assert.equal((await call('DELETE', '/groups/sample-group/members/friend-user', null, newbie)).status, 403);
  assert.equal((await call('POST', '/groups/sample-group/leave', null, newbie)).status, 204);
  assert.equal((await call('GET', '/groups/sample-group', null, newbie)).status, 404);
  assert.equal((await call('POST', '/groups/sample-group/leave', null, owner)).status, 409);
  assert.equal((await call('POST', '/quests', {title: 'x', groupId: 'sample-group'}, newbie)).status, 403);
});

test('AI: bản nháp theo độ khó, từ chối nội dung nguy hiểm', async () => {
  const t = await login();
  const ok = await call('POST', '/ai/quest-plan', {goal: 'Ôn thi Flutter trong 7 ngày', difficulty: 'hard'}, t);
  assert.equal(ok.status, 200);
  assert.equal(ok.body.steps.length, 7);
  assert.equal((await call('POST', '/ai/quest-plan', {goal: 'cách tự tử', difficulty: 'easy'}, t)).status, 422);
});

test('thông báo, báo cáo, chặn, xóa tài khoản', async () => {
  const t = (await call('POST', '/auth/register', {email: 'z@b.vn', password: '123456', displayName: 'Z'})).body.token;
  assert.equal((await call('GET', '/notifications', null, t)).body.length, 1);
  await call('POST', '/notifications/read-all', null, t);
  assert.equal((await call('GET', '/notifications', null, t)).body[0].isRead, true);
  assert.equal((await call('POST', '/reports', {targetType: 'user', targetId: 'friend-user', reason: 'Spam'}, t)).status, 201);
  assert.equal((await call('POST', '/blocks', {userId: 'friend-user'}, t)).status, 201);
  assert.equal((await call('GET', '/blocks', null, t)).body.length, 1);
  assert.equal((await call('DELETE', '/me', null, t)).status, 204);
  assert.equal((await call('GET', '/me', null, t)).status, 401);
});

test('rate limit đăng nhập: sai 5 lần thì bị khóa 429', async () => {
  await call('POST', '/auth/register', {email: 'rl@b.vn', password: '123456', displayName: 'RL'});
  for (let i = 0; i < 5; i++) assert.equal((await call('POST', '/auth/login', {email: 'rl@b.vn', password: 'saisai'})).status, 401);
  assert.equal((await call('POST', '/auth/login', {email: 'rl@b.vn', password: '123456'})).status, 429);
});

test('đổi mật khẩu', async () => {
  const t = (await call('POST', '/auth/register', {email: 'cp@b.vn', password: '123456', displayName: 'CP'})).body.token;
  assert.equal((await call('POST', '/auth/change-password', {currentPassword: 'sai', newPassword: '654321'}, t)).status, 401);
  assert.equal((await call('POST', '/auth/change-password', {currentPassword: '123456', newPassword: '654321'}, t)).status, 200);
  assert.equal((await call('POST', '/auth/login', {email: 'cp@b.vn', password: '123456'})).status, 401);
  assert.equal((await call('POST', '/auth/login', {email: 'cp@b.vn', password: '654321'})).status, 200);
});

test('chặn người dùng: ẩn quest nhóm của người bị chặn', async () => {
  const owner = await login();
  const friend = await login('ban@lifequest.vn');
  await call('POST', '/quests', {title: 'Quest của Huy', groupId: 'sample-group'}, friend);
  const titles = async () => (await call('GET', '/quests?groupId=sample-group', null, owner)).body.map((q) => q.title);
  assert.ok((await titles()).includes('Quest của Huy'));
  await call('POST', '/blocks', {userId: 'friend-user'}, owner);
  assert.ok(!(await titles()).includes('Quest của Huy'));
  await call('DELETE', '/blocks/friend-user', null, owner);
  assert.ok((await titles()).includes('Quest của Huy'));
});

test('SSE: thành viên nhóm nhận sự kiện realtime, người ngoài bị từ chối', async () => {
  const owner = await login();
  const friend = await login('ban@lifequest.vn');
  const outsider = (await call('POST', '/auth/register', {email: 'sse@b.vn', password: '123456', displayName: 'S'})).body.token;
  assert.equal((await fetch(`${base}/groups/sample-group/events?token=${outsider}`)).status, 404);
  const ctrl = new AbortController();
  const res = await fetch(`${base}/groups/sample-group/events?token=${owner}`, {signal: ctrl.signal});
  assert.equal(res.status, 200);
  const reader = res.body.getReader();
  await reader.read(); // event: ready
  await call('POST', '/quests', {title: 'SSE quest', groupId: 'sample-group'}, friend);
  const {value} = await reader.read();
  assert.match(new TextDecoder().decode(value), /event: quest\.created/);
  ctrl.abort();
});

test('migration: user_version = số file sql', () => {
  assert.equal(db.prepare('PRAGMA user_version').get().user_version, 2);
  assert.ok(db.prepare('PRAGMA table_info(users)').all().some((c) => c.name === 'password_changed_at'));
});
