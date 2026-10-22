import {DatabaseSync} from 'node:sqlite';
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';

const SQL_DIR = path.join(path.dirname(fileURLToPath(import.meta.url)), '..', 'sql');

// Migration: mỗi file sql/NNN_*.sql chạy đúng một lần, theo thứ tự; số phiên bản lưu ở PRAGMA user_version.
function migrate(db) {
  const files = fs.readdirSync(SQL_DIR).filter((f) => /^\d+_.*\.sql$/.test(f)).sort();
  let current = db.prepare('PRAGMA user_version').get().user_version;
  for (const f of files) {
    const v = parseInt(f, 10);
    if (v <= current) continue;
    db.exec('BEGIN');
    try {
      db.exec(fs.readFileSync(path.join(SQL_DIR, f), 'utf8'));
      db.exec(`PRAGMA user_version = ${v}`);
      db.exec('COMMIT');
    } catch (e) {
      db.exec('ROLLBACK');
      throw new Error(`Migration ${f} lỗi: ${e.message}`);
    }
    current = v;
  }
}

export function openDb(file = process.env.DB_FILE ?? './data/lifequest.db') {
  if (file !== ':memory:') fs.mkdirSync(path.dirname(path.resolve(file)), {recursive: true});
  const db = new DatabaseSync(file);
  db.exec('PRAGMA foreign_keys = ON');
  migrate(db);
  return db;
}

export const tx = (db, fn) => {
  db.exec('BEGIN IMMEDIATE');
  try {
    const r = fn();
    db.exec('COMMIT');
    return r;
  } catch (e) {
    db.exec('ROLLBACK');
    throw e;
  }
};
