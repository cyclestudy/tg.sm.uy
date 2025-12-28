export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    
    // 关键修正：解析路径中的 cdn 节点 (例如 /cdn5/file/...)
    const pathParts = url.pathname.split('/');
    // pathParts[1] 应该是 'cdn4' 或 'cdn5'
    const cdnNode = pathParts[1];
    
    // 如果路径里没有 cdn 信息，说明请求格式不对
    if (!cdnNode || !cdnNode.startsWith('cdn')) {
        // 兼容旧链接的 fallback (可选)
        if(url.pathname.startsWith('/file')) {
             url.hostname = 'cdn4.telesco.pe';
             const newReq = new Request(url, request);
             newReq.headers.set('Host', 'cdn4.telesco.pe');
             return fetch(newReq);
        }
        return new Response('路径错误: 请使用 /cdnX/file/... 格式', { status: 400 });
    }

    // 动态构建目标: cdn5.telesco.pe
    const targetHost = cdnNode + '.telesco.pe';
    
    // 移除 /cdn5 前缀，变成原始的 /file/xxxx.jpg
    const realPath = '/' + pathParts.slice(2).join('/');
    
    url.hostname = targetHost;
    url.pathname = realPath;
    
    const newRequest = new Request(url, {
        method: request.method,
        headers: request.headers,
        redirect: 'follow'
    });
    
    // 强制修改 Host
    newRequest.headers.set('Host', targetHost);
    
    return fetch(newRequest);
  },
};
