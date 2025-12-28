/* 调试专用代码 */
export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const pathParts = url.pathname.split('/');
    
    // 构造调试信息
    const debugInfo = {
        "Worker状态": "已生效! Worker is running",
        "你请求的地址": request.url,
        "解析到的节点": pathParts[1] || "未知",
        "应该去往的目标": (pathParts[1] || "cdn4") + ".telesco.pe",
        "当前时间": new Date().toLocaleString()
    };

    // 直接返回 JSON，不请求 Telegram
    return new Response(JSON.stringify(debugInfo, null, 2), {
        headers: { "content-type": "application/json;charset=UTF-8" }
    });
  }
};
