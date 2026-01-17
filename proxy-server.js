#!/usr/bin/env node

/**
 * Nitter RSS代理服务器
 * 解决前端访问Nitter RSS时的CORS问题
 */

const http = require('http');
const https = require('https');
const fs = require('fs');
const path = require('path');
const url = require('url');

const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';

// MIME类型映射
const mimeTypes = {
  '.html': 'text/html',
  '.js': 'text/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon'
};

// 创建服务器
const server = http.createServer((req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;

  // 处理RSS代理请求
  if (pathname === '/api/rss' && parsedUrl.query.url) {
    handleRssProxy(parsedUrl.query.url, res);
    return;
  }

  // 处理静态文件
  if (pathname === '/' || pathname === '/index.html') {
    serveFile('index.html', res);
  } else if (pathname.startsWith('/')) {
    const filePath = pathname.substring(1);
    if (fs.existsSync(filePath) && !filePath.includes('..')) {
      serveFile(filePath, res);
    } else {
      serve404(res);
    }
  } else {
    serve404(res);
  }
});

// 处理RSS代理
function handleRssProxy(targetUrl, res) {
  try {
    const parsedTarget = url.parse(targetUrl);
    const client = parsedTarget.protocol === 'https:' ? https : http;

    const options = {
      hostname: parsedTarget.hostname,
      port: parsedTarget.port || (parsedTarget.protocol === 'https:' ? 443 : 80),
      path: parsedTarget.path,
      method: 'GET',
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': 'application/rss+xml, application/xml, text/xml, */*'
      }
    };

    const proxyReq = client.request(options, (proxyRes) => {
      // 设置CORS头
      res.setHeader('Access-Control-Allow-Origin', '*');
      res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
      res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

      // 复制响应头
      res.statusCode = proxyRes.statusCode;
      Object.keys(proxyRes.headers).forEach(key => {
        if (key.toLowerCase() !== 'access-control-allow-origin') {
          res.setHeader(key, proxyRes.headers[key]);
        }
      });

      // 转发响应体
      proxyRes.pipe(res);
    });

    proxyReq.on('error', (error) => {
      console.error('代理请求错误:', error);
      res.writeHead(500, {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      });
      res.end(JSON.stringify({ error: error.message }));
    });

    proxyReq.end();
  } catch (error) {
    console.error('处理RSS代理错误:', error);
    res.writeHead(500, {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    });
    res.end(JSON.stringify({ error: error.message }));
  }
}

// 提供静态文件
function serveFile(filePath, res) {
  fs.readFile(filePath, (err, data) => {
    if (err) {
      serve404(res);
      return;
    }

    const ext = path.extname(filePath);
    const contentType = mimeTypes[ext] || 'application/octet-stream';

    res.writeHead(200, {
      'Content-Type': contentType,
      'Access-Control-Allow-Origin': '*'
    });
    res.end(data);
  });
}

// 404响应
function serve404(res) {
  res.writeHead(404, {
    'Content-Type': 'text/plain',
    'Access-Control-Allow-Origin': '*'
  });
  res.end('404 Not Found');
}

// 启动服务器
server.listen(PORT, HOST, () => {
  console.log(`🚀 Nitter代理服务器运行在 http://${HOST}:${PORT}`);
  console.log(`📄 前端页面: http://${HOST}:${PORT}`);
  console.log(`🔗 RSS代理: http://${HOST}:${PORT}/api/rss?url=<nitter-rss-url>`);
});

// 优雅关闭
process.on('SIGTERM', () => {
  console.log('收到SIGTERM信号，正在关闭服务器...');
  server.close(() => {
    console.log('服务器已关闭');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('收到SIGINT信号，正在关闭服务器...');
  server.close(() => {
    console.log('服务器已关闭');
    process.exit(0);
  });
});
