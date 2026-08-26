/**
 * RuoYi-Vue-Plus 后端 AI 功能接口测试脚本 (Node 24+, 零依赖)
 *
 * 用法:
 *   node ai-api-test.js login   # 加密登录获取 token (验证码通过 Redis 直读自动解析)
 *   node ai-api-test.js ai      # 测试 AI 接口: 创建会话/会话列表/历史消息/流式对话
 *   node ai-api-test.js ping    # 检查本地 1234 端口的 OpenAI 兼容模型服务
 *   node ai-api-test.js all     # 依次执行 login -> ping -> ai
 */
const crypto = require('crypto');
const fs = require('fs');
const net = require('net');
const path = require('path');

// ============ 配置 ============
const BASE = 'http://localhost:8080';
// RSA 公钥与后端 api-decrypt privateKey 对应 (见 ruoyi-ui/.env.development)
const RSA_PUBLIC_KEY = 'MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAKoR8mX0rGKLqzcWmOzbfj64K8ZIgOdHnzkXSOVOZbFu/TJhZ7rFAN+eaGkl3C4buccQd/EjEsj9ir7ijT7h96MCAwEAAQ==';
const CLIENT_ID = 'e5cd7e4891bf95d1d19206ce24a7b32e';
const USERNAME = 'admin';
const PASSWORD = 'admin123';
// Redis (验证码存储) 见 application-dev.yml
const REDIS = { host: '192.168.150.10', port: 6379, password: 'tomori', db: 6 };
// OpenAI 兼容模型服务 (ai.enabled 时后端调用)
const LLM_BASE = 'http://192.168.100.1:1234';
const LLM_MODEL = 'qwen3.5-2b';
const TOKEN_FILE = path.join(__dirname, 'token.txt');

// ============ 加密 (与前端 utils/crypto.ts + jsencrypt 一致) ============
function generateAesKey() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let key = '';
  for (let i = 0; i < 32; i++) key += chars.charAt(Math.floor(Math.random() * chars.length));
  return key;
}

function encryptWithAes(plain, key) {
  // AES/ECB/PKCS7 -> Base64
  const cipher = crypto.createCipheriv('aes-256-ecb', Buffer.from(key, 'utf8'), null);
  return Buffer.concat([cipher.update(plain, 'utf8'), cipher.final()]).toString('base64');
}

function encryptWithRsa(plain) {
  const pem = `-----BEGIN PUBLIC KEY-----\n${RSA_PUBLIC_KEY.match(/.{1,64}/g).join('\n')}\n-----END PUBLIC KEY-----`;
  return crypto.publicEncrypt({ key: pem, padding: crypto.constants.RSA_PKCS1_PADDING }, Buffer.from(plain, 'utf8')).toString('base64');
}

/** 模拟前端加密流程发送 POST 请求 */
async function postEncrypted(urlPath, bodyObj, headers = {}) {
  const aesKey = generateAesKey();
  const encBody = encryptWithAes(JSON.stringify(bodyObj), aesKey);
  const encKey = encryptWithRsa(Buffer.from(aesKey, 'utf8').toString('base64'));
  const resp = await fetch(BASE + urlPath, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json;charset=utf-8',
      clientid: CLIENT_ID,
      'encrypt-key': encKey,
      ...headers
    },
    body: encBody
  });
  return { status: resp.status, data: await resp.json(), headers: resp.headers };
}

// ============ Redis RESP 直读验证码 ============
function redisGetValue(key) {
  return new Promise((resolve, reject) => {
    const socket = net.connect(REDIS.port, REDIS.host);
    let phase = 0;
    let pending = '';
    socket.on('connect', () => socket.write(respCmd('AUTH', REDIS.password)));
    socket.on('data', (chunk) => {
      pending += chunk.toString();
      if (phase === 0 && pending.endsWith('+OK\r\n')) {
        phase = 1; pending = '';
        socket.write(respCmd('SELECT', String(REDIS.db)));
      } else if (phase === 1 && pending.endsWith('+OK\r\n')) {
        phase = 2; pending = '';
        socket.write(respCmd('GET', key));
      } else if (phase === 2 && pending.endsWith('\r\n')) {
        const m = pending.match(/^\$(-?\d+)\r\n([\s\S]*?)\r\n$/);
        socket.destroy();
        if (m) {
          // TypedJsonJacksonCodec 存储字符串带 JSON 引号
          resolve(m[1] === '-1' ? null : m[2].replace(/^"|"$/g, ''));
        } else if (pending.startsWith('$-1')) {
          resolve(null);
        }
      }
    });
    socket.on('error', reject);
    setTimeout(() => { socket.destroy(); reject(new Error('redis timeout')); }, 5000);
  });
}

function respCmd(...args) {
  let s = `*${args.length}\r\n`;
  for (const a of args) s += `$${Buffer.byteLength(a)}\r\n${a}\r\n`;
  return s;
}

// ============ 登录 ============
async function login() {
  console.log('==> [1/3] 获取验证码');
  const codeResp = await fetch(BASE + '/auth/code', { headers: { clientid: CLIENT_ID } });
  const codeData = await codeResp.json();
  if (codeData.code !== 200) throw new Error('验证码接口异常: ' + JSON.stringify(codeData));
  const uuid = codeData.data.uuid;

  console.log('==> [2/3] Redis 直读验证码答案 (uuid=' + uuid + ')');
  const answer = await redisGetValue('GLOBAL:CAPTCHA_CODES:' + uuid);
  if (!answer) throw new Error('验证码已从 Redis 过期');
  console.log('    验证码答案: ' + answer);

  console.log('==> [3/3] 加密登录 (' + USERNAME + ')');
  const { status, data } = await postEncrypted('/auth/login', {
    clientId: CLIENT_ID,
    grantType: 'password',
    tenantId: '000000',
    username: USERNAME,
    password: PASSWORD,
    code: answer,
    uuid
  });
  if (data.code !== 200) throw new Error('登录失败: ' + data.msg);
  const token = data.data.access_token;
  fs.writeFileSync(TOKEN_FILE, token);
  console.log('    登录成功, token 已保存 -> ' + TOKEN_FILE);
  console.log('    token: ' + token.substring(0, 40) + '...');
  return token;
}

function loadToken() {
  if (!fs.existsSync(TOKEN_FILE)) throw new Error('未找到 token, 请先执行: node ai-api-test.js login');
  return fs.readFileSync(TOKEN_FILE, 'utf8').trim();
}

// ============ AI 接口测试 ============
async function testAi() {
  const token = loadToken();
  const headers = { Authorization: 'Bearer ' + token, clientid: CLIENT_ID };

  console.log('==> [1/4] POST /ai/chat/conversations 创建会话');
  let resp = await fetch(BASE + '/ai/chat/conversations', {
    method: 'POST', headers: { 'Content-Type': 'application/json', ...headers },
    body: JSON.stringify({ title: '接口测试会话' })
  });
  let data = await resp.json();
  console.log('    code=' + data.code + (data.msg ? ' msg=' + data.msg : ''));
  if (data.code !== 200) throw new Error('创建会话失败: ' + JSON.stringify(data));
  const conversationId = data.data.conversationId;
  console.log('    conversationId=' + conversationId);

  console.log('==> [2/4] GET /ai/chat/conversations 会话列表');
  resp = await fetch(BASE + '/ai/chat/conversations', { headers });
  data = await resp.json();
  console.log('    code=' + data.code + ', 会话数量=' + (data.data ? data.data.length : 0));

  console.log('==> [3/4] POST /ai/chat/completions 流式对话 (SSE)');
  resp = await fetch(BASE + '/ai/chat/completions', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Accept: 'text/event-stream', ...headers },
    body: JSON.stringify({ conversationId, content: '你好，请用一句话介绍你自己' })
  });
  console.log('    HTTP ' + resp.status + ', content-type=' + resp.headers.get('content-type'));
  if (!resp.ok || !resp.body) throw new Error('流式对话请求失败: HTTP ' + resp.status);
  const reader = resp.body.getReader();
  const decoder = new TextDecoder('utf-8');
  let buffer = '';
  let fullText = '';
  let done = false;
  let errMsg = null;
  while (!done) {
    const { done: streamEnd, value } = await reader.read();
    if (streamEnd) break;
    buffer += decoder.decode(value, { stream: true });
    const blocks = buffer.split('\n\n');
    buffer = blocks.pop() || '';
    for (const block of blocks) {
      if (!block.trim()) continue;
      let eventName = 'message';
      const dataLines = [];
      for (const line of block.split('\n')) {
        if (line.startsWith('event:')) eventName = line.slice(6).trim();
        else if (line.startsWith('data:')) dataLines.push(line.slice(5).replace(/^ /, ''));
      }
      const payload = dataLines.join('\n');
      if (eventName === 'error') { errMsg = payload || 'AI 服务异常'; done = true; break; }
      if (payload === '[DONE]') { done = true; break; }
      if (payload) { fullText += payload; process.stdout.write(payload); }
    }
  }
  console.log('');
  if (errMsg) {
    console.log('    [流式输出异常] ' + errMsg);
    console.log('    提示: 请检查本地模型服务 -> node ai-api-test.js ping');
  } else {
    console.log('    [流式输出完成] 共 ' + fullText.length + ' 字符');
  }

  console.log('==> [4/4] GET /ai/chat/conversations/{id}/messages 历史消息');
  resp = await fetch(BASE + '/ai/chat/conversations/' + conversationId + '/messages', { headers });
  data = await resp.json();
  console.log('    code=' + data.code + ', 消息数量=' + (data.data ? data.data.length : 0));
  if (data.data) {
    for (const msg of data.data) {
      const preview = String(msg.content || '').substring(0, 60).replace(/\n/g, ' ');
      console.log('    [' + msg.role + '] ' + preview);
    }
  }
}

// ============ 本地模型服务检查 ============
async function pingLlm() {
  console.log('==> 检查模型服务 ' + LLM_BASE + '/v1/models');
  try {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), 5000);
    const resp = await fetch(LLM_BASE + '/v1/models', { signal: controller.signal });
    clearTimeout(timer);
    const data = await resp.json();
    console.log('    HTTP ' + resp.status + ', 可用模型:');
    for (const m of data.data || []) console.log('    - ' + m.id);
    const found = (data.data || []).some((m) => m.id === LLM_MODEL);
    console.log(found ? '    [OK] 配置模型 ' + LLM_MODEL + ' 已加载' : '    [WARN] 配置模型 ' + LLM_MODEL + ' 未在列表中, 请核对 application.yml spring.ai.openai.chat.model');
  } catch (e) {
    console.log('    [FAIL] 无法连接模型服务: ' + (e.name === 'AbortError' ? '超时' : e.message));
    console.log('    提示: 请确认本地 1234 端口的模型服务(如 LM Studio)已启动并加载模型');
  }
}

// ============ 入口 ============
(async () => {
  const cmd = process.argv[2] || 'all';
  try {
    if (cmd === 'login') await login();
    else if (cmd === 'ping') await pingLlm();
    else if (cmd === 'ai') await testAi();
    else if (cmd === 'all') {
      await login();
      await pingLlm();
      await testAi();
    } else {
      console.log('未知命令: ' + cmd + ' (可选: login | ping | ai | all)');
    }
    console.log('==> 测试结束');
  } catch (e) {
    console.error('[测试失败] ' + e.message);
    process.exit(1);
  }
})();
