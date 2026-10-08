// npm run setup: cài đặt từ con số 0 => cài dependency, tạo .env, bật PostgreSQL (Docker), migrate, seed, seed demo.
// Chạy lại được nhiều lần (không ghi đè .env đã có; seed + seed demo idempotent).
// Đổi cổng / tên DB lần đầu: DB_PORT=5543 API_DB=tracker2 API_PORT=3100 npm run setup
import { randomBytes } from 'node:crypto';
import { copyFileSync, existsSync, readFileSync, writeFileSync } from 'node:fs';
import path from 'node:path';
import { ADMIN, BACKEND, ROOT, dbExec, dbUp, dbUrl, log, rootEnv, run, setEnv } from './lib.mjs';

const t0 = Date.now();
const secret = () => randomBytes(32).toString('hex');

// ---- .env gốc (docker compose)
const rootFile = path.join(ROOT, '.env');
if (!existsSync(rootFile)) {
  log('Tạo .env từ .env.example');
  let text = readFileSync(path.join(ROOT, '.env.example'), 'utf8');
  for (const k of ['DB_PORT', 'API_PORT', 'ADMIN_PORT', 'API_DB', 'ADMIN_EMAIL', 'ADMIN_PASSWORD']) if (process.env[k]) text = setEnv(text, k, process.env[k]);
  writeFileSync(rootFile, setEnv(text, 'JWT_SECRET', secret()));
}
const env = rootEnv();
if (!env.JWT_SECRET) {
  writeFileSync(rootFile, setEnv(readFileSync(rootFile, 'utf8'), 'JWT_SECRET', (env.JWT_SECRET = secret())));
}

// ---- backend/.env + admin/.env cho dev
const beFile = path.join(BACKEND, '.env');
if (!existsSync(beFile)) {
  log('Tạo backend/.env');
  let text = readFileSync(path.join(BACKEND, '.env.example'), 'utf8');
  text = setEnv(text, 'DATABASE_URL', dbUrl(env.DB_PORT, env.API_DB));
  text = setEnv(text, 'PORT', env.API_PORT);
  text = setEnv(text, 'JWT_SECRET', env.JWT_SECRET);
  text = setEnv(text, 'ADMIN_EMAIL', env.ADMIN_EMAIL);
  text = setEnv(text, 'ADMIN_PASSWORD', env.ADMIN_PASSWORD);
  writeFileSync(beFile, text);
}
const adFile = path.join(ADMIN, '.env');
if (!existsSync(adFile)) {
  log('Tạo admin/.env');
  copyFileSync(path.join(ADMIN, '.env.example'), adFile);
  writeFileSync(adFile, setEnv(readFileSync(adFile, 'utf8'), 'VITE_API_URL', `http://localhost:${env.API_PORT}/api`));
}

// ---- dependency
log('Cài dependency (gốc, backend, admin)');
for (const dir of [ROOT, BACKEND, ADMIN]) run('npm', ['install', '--no-audit', '--no-fund'], { cwd: dir });

// ---- DB
log(`Bật PostgreSQL (Docker, cổng ${env.DB_PORT})`);
dbUp();
if (env.API_DB !== 'tracker') {
  const exists = dbExec(['psql', '-U', 'tracker', '-tAc', `SELECT 1 FROM pg_database WHERE datname = '${env.API_DB}'`]).stdout.trim() === '1';
  if (!exists) dbExec(['createdb', '-U', 'tracker', env.API_DB]);
}
const dbEnv = { DATABASE_URL: dbUrl(env.DB_PORT, env.API_DB), ADMIN_EMAIL: env.ADMIN_EMAIL, ADMIN_PASSWORD: env.ADMIN_PASSWORD };
log(`Migrate + seed DB "${env.API_DB}"`);
run('npx', ['prisma', 'migrate', 'deploy'], { cwd: BACKEND, env: dbEnv });
run('npm', ['run', 'db:seed'], { cwd: BACKEND, env: dbEnv });
log('Nạp dữ liệu demo');
run('npm', ['run', 'db:seed:demo'], { cwd: BACKEND, env: dbEnv });

console.log(`
\x1b[1;32m✔ Xong sau ${Math.round((Date.now() - t0) / 1000)}s.\x1b[0m Chạy:  npm run dev
  API     http://localhost:${env.API_PORT}/api   (Swagger: http://localhost:${env.API_PORT}/docs)
  Admin   http://localhost:5173                  ${env.ADMIN_EMAIL} / ${env.ADMIN_PASSWORD}
  Demo    demo@thuchi.vn / demo123  (+ ~40 user <tên>@demo.thuchi.vn / demo123)`);
