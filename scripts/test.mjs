// npm run test: toàn bộ kiểm thử, tuần tự, trên DB riêng (mặc định tracker_test) CÓ SẴN dữ liệu demo:
//   1. tạo lại DB test -> migrate -> seed -> seed demo
//   2. API (NODE_ENV=test, TZ=UTC) ở cổng TEST_API_PORT (3001) -> kiểm tra bất biến dữ liệu demo qua API -> backend e2e
//   3. khởi động lại API (xóa bộ đếm rate limit) -> admin e2e Playwright (tự bật Vite ở :5174)
//   4. dừng API, xóa DB test (KEEP_TEST_DB=1 để giữ)
// Tùy chọn: TEST_DB, TEST_API_PORT, E2E_PORT, SKIP_BACKEND=1, SKIP_ADMIN=1
import os from 'node:os';
import path from 'node:path';
import { ADMIN, BACKEND, dbExec, dbUp, dbUrl, log, rootEnv, run, startApi } from './lib.mjs';

const env = rootEnv();
const DB = process.env.TEST_DB ?? 'tracker_test';
const PORT = Number(process.env.TEST_API_PORT ?? 3001);
const E2E_PORT = Number(process.env.E2E_PORT ?? 5174);
const API_URL = `http://localhost:${PORT}/api`;
const LOG = path.join(os.tmpdir(), `thuchi-test-api-${PORT}.log`);
const ADMIN_EMAIL = 'admin@thuchi.vn';
const ADMIN_PASSWORD = 'admin123';
const apiEnv = {
  DATABASE_URL: dbUrl(env.DB_PORT, DB),
  NODE_ENV: 'test',
  TZ: 'UTC',
  JWT_SECRET: 'test-secret-0123456789abcdef',
  CORS_ORIGINS: `http://localhost:${E2E_PORT}`,
  SMTP_HOST: '',
  TRUST_PROXY: '',
};

const results = [];
let stop = null;
const t0 = Date.now();
const step = (name, fn) => {
  const s = Date.now();
  const r = fn();
  const ok = r.status === 0;
  results.push(`${ok ? '\x1b[32m✔' : '\x1b[31m✘'} ${name}\x1b[0m (${Math.round((Date.now() - s) / 1000)}s)`);
  return ok;
};

process.on('SIGINT', async () => { if (stop) await stop(); process.exit(130); });

try {
  log(`Chuẩn bị DB "${DB}" (cổng ${env.DB_PORT}) + dữ liệu demo`);
  dbUp();
  dbExec(['dropdb', '-U', 'tracker', '--if-exists', '--force', DB]);
  dbExec(['createdb', '-U', 'tracker', DB]);
  const dbEnv = { DATABASE_URL: apiEnv.DATABASE_URL, ADMIN_EMAIL, ADMIN_PASSWORD };
  run('npx', ['prisma', 'migrate', 'deploy'], { cwd: BACKEND, env: dbEnv, quiet: true });
  run('npm', ['run', 'db:seed'], { cwd: BACKEND, env: dbEnv, quiet: true });
  run('npm', ['run', 'db:seed:demo'], { cwd: BACKEND, env: dbEnv });

  log('Build backend');
  run('npm', ['run', 'build'], { cwd: BACKEND, quiet: true });

  let allOk = true;
  if (!process.env.SKIP_BACKEND) {
    log(`API test ở ${API_URL} (log: ${LOG})`);
    stop = await startApi({ port: PORT, env: apiEnv, logFile: LOG });
    log('Bất biến dữ liệu demo qua API');
    allOk = step('Dữ liệu demo (verify-demo)', () => run('node', ['scripts/verify-demo.mjs'], { cwd: BACKEND, env: { API_URL }, allowFail: true })) && allOk;
    log('Backend e2e');
    allOk = step('Backend e2e', () => run('node', ['scripts/e2e.mjs'], { cwd: BACKEND, env: { API_URL, API_LOG: LOG, ADMIN_EMAIL, ADMIN_PASSWORD }, allowFail: true })) && allOk;
    await stop();
    stop = null;
  }

  if (!process.env.SKIP_ADMIN) {
    log('Admin e2e (Playwright)');
    stop = await startApi({ port: PORT, env: apiEnv, logFile: LOG });
    run('npx', ['playwright', 'install', 'chromium'], { cwd: ADMIN, quiet: true });
    allOk = step('Admin e2e (Playwright)', () => run('npx', ['playwright', 'test'], {
      cwd: ADMIN, env: { E2E_API_URL: API_URL, E2E_PORT: String(E2E_PORT), E2E_ADMIN_EMAIL: ADMIN_EMAIL, E2E_ADMIN_PASSWORD: ADMIN_PASSWORD }, allowFail: true,
    })) && allOk;
    await stop();
    stop = null;
  }

  if (!process.env.KEEP_TEST_DB) dbExec(['dropdb', '-U', 'tracker', '--if-exists', '--force', DB]);
  console.log(`\n${results.join('\n')}\nTổng thời gian ${Math.round((Date.now() - t0) / 1000)}s`);
  process.exitCode = allOk ? 0 : 1;
} catch (e) {
  console.error(`\n\x1b[31m${e.message}\x1b[0m`);
  process.exitCode = 1;
} finally {
  if (stop) await stop();
}
