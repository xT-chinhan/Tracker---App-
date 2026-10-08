// Tiện ích chung cho scripts/setup.mjs và scripts/test.mjs (chỉ dùng thư viện có sẵn của Node).
import { spawn, spawnSync } from 'node:child_process';
import { existsSync, readFileSync } from 'node:fs';
import path from 'node:path';

export const ROOT = path.resolve(import.meta.dirname, '..');
export const BACKEND = path.join(ROOT, 'backend');
export const ADMIN = path.join(ROOT, 'admin');

/** Đọc file .env đơn giản (KEY=value, bỏ dòng #, bỏ ngoặc kép bao ngoài). */
export function readEnv(file) {
  if (!existsSync(file)) return {};
  const out = {};
  for (const line of readFileSync(file, 'utf8').split('\n')) {
    const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*?)\s*$/);
    if (!m) continue;
    out[m[1]] = m[2].replace(/^"(.*)"$/, '$1').replace(/^'(.*)'$/, '$1');
  }
  return out;
}

/** Ghi đè / thêm KEY=value vào nội dung .env, giữ nguyên các dòng khác. */
export function setEnv(text, key, value) {
  const line = `${key}=${/[\s#"<>]/.test(value) ? JSON.stringify(value) : value}`;
  const re = new RegExp(`^${key}=.*$`, 'm');
  return re.test(text) ? text.replace(re, line) : `${text.replace(/\n?$/, '\n')}${line}\n`;
}

export const log = (msg) => console.log(`\n\x1b[1;36m▶ ${msg}\x1b[0m`);

/** Chạy lệnh đồng bộ, in output ra màn hình; lỗi => ném ngoại lệ (trừ khi allowFail). */
export function run(cmd, args, { cwd = ROOT, env = {}, allowFail = false, quiet = false } = {}) {
  const r = spawnSync(cmd, args, { cwd, env: { ...process.env, ...env }, stdio: quiet ? 'pipe' : 'inherit', encoding: 'utf8' });
  if (r.status !== 0 && !allowFail) {
    if (quiet) process.stderr.write(`${r.stdout ?? ''}${r.stderr ?? ''}`);
    throw new Error(`Lệnh lỗi (${r.status}): ${cmd} ${args.join(' ')}`);
  }
  return r;
}

/** Biến môi trường gốc: .env ở thư mục gốc, process.env được ưu tiên. */
export function rootEnv() {
  const file = readEnv(path.join(ROOT, '.env'));
  const pick = (k, d) => process.env[k] ?? file[k] ?? d;
  return {
    DB_PORT: pick('DB_PORT', '5433'),
    API_PORT: pick('API_PORT', '3000'),
    ADMIN_PORT: pick('ADMIN_PORT', '8080'),
    API_DB: pick('API_DB', 'tracker'),
    JWT_SECRET: pick('JWT_SECRET', ''),
    ADMIN_EMAIL: pick('ADMIN_EMAIL', 'admin@thuchi.vn'),
    ADMIN_PASSWORD: pick('ADMIN_PASSWORD', 'admin123'),
  };
}

export const dbUrl = (port, db) => `postgresql://tracker:tracker@localhost:${port}/${db}?schema=public`;

/** Bật container PostgreSQL và chờ healthy. */
export function dbUp() {
  run('docker', ['compose', 'up', '-d', '--wait', 'db']);
}

/** Lệnh psql-tools trong container db (createdb, dropdb...). */
export function dbExec(args, opts = {}) {
  return run('docker', ['compose', 'exec', '-T', 'db', ...args], { quiet: true, ...opts });
}

/** Chạy API (dist/main) nền, log ra file; trả về hàm dừng. */
export async function startApi({ port, env, logFile }) {
  const { openSync } = await import('node:fs');
  const fd = openSync(logFile, 'w');
  const child = spawn(process.execPath, ['dist/main'], { cwd: BACKEND, env: { ...process.env, ...env, PORT: String(port) }, stdio: ['ignore', fd, fd], detached: true });
  const url = `http://localhost:${port}/api/health`;
  for (let i = 0; i < 60; i++) {
    if (child.exitCode !== null) throw new Error(`API thoát sớm, xem ${logFile}`);
    try { if ((await fetch(url)).ok) break; } catch { /* chưa lên */ }
    await new Promise((r) => setTimeout(r, 500));
    if (i === 59) throw new Error(`API không lên ở ${url}`);
  }
  return () => new Promise((resolve) => {
    if (child.exitCode !== null) return resolve();
    child.once('exit', () => resolve());
    try { process.kill(-child.pid, 'SIGTERM'); } catch { resolve(); }
    setTimeout(() => { try { process.kill(-child.pid, 'SIGKILL'); } catch { /* đã dừng */ } }, 5000);
  });
}
