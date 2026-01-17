/**
 * Vercel Serverless Function
 * Nitter RSS代理API
 * 解决前端访问Nitter RSS时的CORS问题
 */

const https = require('https');
const http = require('http');

module.exports = async (req, res) => {
  // 处理CORS预检请求
  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    return res.status(200).end();
  }

  // 只允许GET请求
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  // 获取目标URL
  const targetUrl = req.query.url;
  
  if (!targetUrl) {
    return res.status(400).json({ error: 'Missing url parameter' });
  }

  try {
    // 解析目标URL
    const urlObj = new URL(targetUrl);
    const client = urlObj.protocol === 'https:' ? https : http;

    const options = {
      hostname: urlObj.hostname,
      port: urlObj.port || (urlObj.protocol === 'https:' ? 443 : 80),
      path: urlObj.pathname + urlObj.search,
      method: 'GET',
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': 'application/rss+xml, application/xml, text/xml, */*'
      },
      timeout: 10000 // 10秒超时
    };

    // 发起代理请求
    const proxyReq = client.request(options, (proxyRes) => {
      // 设置CORS头
      res.setHeader('Access-Control-Allow-Origin', '*');
      res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
      res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

      // 复制响应头
      res.statusCode = proxyRes.statusCode;
      Object.keys(proxyRes.headers).forEach(key => {
        // 跳过一些不应该转发的头
        if (key.toLowerCase() !== 'access-control-allow-origin' &&
            key.toLowerCase() !== 'connection' &&
            key.toLowerCase() !== 'transfer-encoding') {
          res.setHeader(key, proxyRes.headers[key]);
        }
      });

      // 转发响应体
      proxyRes.pipe(res);
    });

    proxyReq.on('error', (error) => {
      console.error('代理请求错误:', error);
      res.setHeader('Access-Control-Allow-Origin', '*');
      res.status(500).json({ 
        error: 'Proxy request failed',
        message: error.message 
      });
    });

    proxyReq.on('timeout', () => {
      proxyReq.destroy();
      res.setHeader('Access-Control-Allow-Origin', '*');
      res.status(504).json({ error: 'Request timeout' });
    });

    proxyReq.end();
  } catch (error) {
    console.error('处理请求错误:', error);
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.status(500).json({ 
      error: 'Internal server error',
      message: error.message 
    });
  }
};
