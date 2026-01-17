# Nitter实例测试清单

部署到Railway后，使用此清单验证Nitter实例是否正常工作。

## 部署后测试步骤

### ✅ 1. 基础功能测试

- [ ] 访问Nitter主页：`https://your-nitter-service.railway.app`
- [ ] 检查页面是否正常加载
- [ ] 查看服务日志，确认没有错误

### ✅ 2. RSS端点测试

#### 测试@OpenAI的RSS
- [ ] 访问：`https://your-nitter-service.railway.app/OpenAI/rss`
- [ ] 检查是否返回XML格式的RSS内容
- [ ] 验证RSS中包含推文条目（item标签）
- [ ] 检查推文标题、链接、发布时间是否完整

#### 测试@elonmusk的RSS
- [ ] 访问：`https://your-nitter-service.railway.app/elonmusk/rss`
- [ ] 检查是否返回XML格式的RSS内容
- [ ] 验证RSS中包含推文条目
- [ ] 检查推文内容是否完整

### ✅ 3. 用户页面测试

- [ ] 访问：`https://your-nitter-service.railway.app/OpenAI`
- [ ] 访问：`https://your-nitter-service.railway.app/elonmusk`
- [ ] 检查页面是否正常显示用户信息

### ✅ 4. 在网站后台集成测试

- [ ] 登录网站管理后台（`/admin.html`）
- [ ] 进入"Nitter管理"页签
- [ ] 添加Nitter实例：
  - URL：`https://your-nitter-service.railway.app`
  - 名称：例如 "Railway Nitter实例"
  - 优先级：例如 `10`
- [ ] 点击"测试"按钮，确认实例可用

### ✅ 5. 推文抓取测试

#### 添加OpenAI订阅源
- [ ] 在订阅管理中添加：
  - 源URL：`https://twitter.com/OpenAI` 或 `@OpenAI`
  - 源类型：`twitter`
- [ ] 等待系统抓取（或手动触发）
- [ ] 在"最新推文"页面查看OpenAI的推文

#### 添加Elon Musk订阅源
- [ ] 在订阅管理中添加：
  - 源URL：`https://twitter.com/elonmusk` 或 `@elonmusk`
  - 源类型：`twitter`
- [ ] 等待系统抓取（或手动触发）
- [ ] 在"最新推文"页面查看Elon Musk的推文

## 常见问题排查

### 问题：RSS端点返回空内容或404

**可能原因**：
1. Nitter可能需要Twitter session token
2. Nitter实例配置不正确
3. Twitter/X的API限制

**解决方案**：
1. 检查Nitter服务日志
2. 确认`NITTER_DOMAIN`环境变量设置正确
3. 尝试访问用户页面（非RSS），看是否正常
4. 参考`RAILWAY_DEPLOY.md`中的"关于Session Token"部分

### 问题：推文抓取失败

**可能原因**：
1. Nitter实例未正确添加到网站后台
2. RSS端点不可用
3. 订阅源配置错误

**解决方案**：
1. 在网站后台的Nitter管理中测试实例可用性
2. 直接访问RSS端点验证
3. 检查订阅源的URL格式是否正确

### 问题：服务无法启动

**可能原因**：
1. Redis连接失败
2. 环境变量配置错误
3. 端口冲突

**解决方案**：
1. 检查Redis服务是否正常运行
2. 验证所有必需的环境变量都已设置
3. 查看Railway服务日志

## 成功标准

✅ 所有测试项都通过后，Nitter实例就可以正常使用了！

- RSS端点返回有效的XML内容
- 网站后台可以成功抓取推文
- 推文内容完整（标题、链接、时间等）

## 后续维护

- 定期检查Nitter实例可用性
- 监控服务日志，及时发现问题
- 如果RSS功能失效，考虑更新Nitter镜像或配置session token
