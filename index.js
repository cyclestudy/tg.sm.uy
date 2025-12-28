export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    
    // 1. 拆分路径，提取 cdn 节点
    // 例如: /cdn5/file/xxx -> ["", "cdn5", "file", "xxx"]
    const pathParts = url.pathname.split('/');
    const cdnNode = pathParts[1]; // 拿到 "cdn5"
    
    // 2. 检查是否是合法的 cdn 节点
    if (!cdnNode || !cdnNode.startsWith('cdn')) {
        return new Response('Error: Invalid Path. Expected /cdnX/file/...', { status: 400 });
    }

    // 3. 动态指向正确的目标服务器 (cdn5.telesco.pe)
    const targetHost = cdnNode + '.telesco.pe';
    
    // 4. 【关键步骤】重写路径：去掉开头的 /cdn5，只保留后面的 /file/xxx
    const realPath = '/' + pathParts.slice(2).join('/');
    
    url.hostname = targetHost;
    url.pathname = realPath;
    
    // 5. 发起请求
    const newRequest = new Request(url, {
        method: request.method,
        headers: request.headers,
        redirect: 'follow'
    });
    
    // 6. 伪装 Host 头
    newRequest.headers.set('Host', targetHost);
    
    return fetch(newRequest);
  },
};
