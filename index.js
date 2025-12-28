export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    
    // 解析路径: /cdn4/file/xxxx.jpg
    const pathParts = url.pathname.split('/');
    const cdnNode = pathParts[1]; // 提取 'cdn4', 'cdn5' 等
    
    if (!cdnNode || !cdnNode.startsWith('cdn')) {
        return new Response('Invalid CDN Path. Use format: /cdnX/file/...', { status: 400 });
    }

    // 动态指向目标: cdn5.telesco.pe
    const targetHost = cdnNode + '.telesco.pe';
    
    // 移除 /cdn4 前缀，恢复原始路径 /file/xxx...
    url.hostname = targetHost;
    url.pathname = '/' + pathParts.slice(2).join('/');
    
    const newRequest = new Request(url, {
        method: request.method,
        headers: request.headers,
        redirect: 'follow'
    });
    
    // 动态修改 Host 头
    newRequest.headers.set('Host', targetHost);
    
    return fetch(newRequest);
  },
};
