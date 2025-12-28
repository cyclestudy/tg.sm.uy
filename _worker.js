export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    // 场景 A：如果你只想代理特定的路径（例如 /file/ 开头），请修改这里的判断
    // 场景 B：如果你想全站代理，保持 startsWith('/') 即可，但要注意 env.ASSETS 将失效
    if (url.pathname.startsWith('/')) { 
      url.hostname = 'cdn4.telesco.pe';

      // 1. 创建新的 Headers 对象，避免只读错误
      const newHeaders = new Headers(request.headers);
      
      // 2. 关键修正：将 Host 设置为目标域名，否则对方服务器可能会拒绝
      newHeaders.set('Host', 'cdn4.telesco.pe');
      // 可选：有些服务器会检查 Referer，也可以伪造一下
      newHeaders.set('Referer', 'https://cdn4.telesco.pe/');

      // 3. 构建新请求
      const newRequest = new Request(url, {
        method: request.method,
        headers: newHeaders,
        body: request.body,
        redirect: 'follow'
      });

      return fetch(newRequest);
    }

    // 只有当你修改了上面的 if 条件（例如只代理特定路径）时，这一行才有意义
    return env.ASSETS.fetch(request);
  },
};
