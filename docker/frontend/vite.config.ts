// vite.config.js
import { defineConfig } from 'vite';
import { resolve } from 'path';


function rewritepcErrorRoutes() {
  return {
    name: 'rewrite-pc-error-routes',
    configureServer(server) {
      server.middlewares.use((req, _res, next) => {
        // /pc/urlproxy_error?...  ->  /src/pc/urlproxy_error.html?...
        if (req.url?.startsWith('/pc/urlproxy_error')) {
          const q = req.url.includes('?') ? req.url.slice(req.url.indexOf('?')) : '';
          req.url = '/src/pc/urlproxy_error.html' + q;
        }
        next();
      });
    },
  };
}

export default defineConfig({
  appType: 'mpa',
  plugins: [rewritepcErrorRoutes()],
  build: {
    rollupOptions: {
      input: {
        login: resolve(__dirname, 'src/admin/login.html'),
        admin: resolve(__dirname, 'src/admin/index.html'),
        admin_error: resolve(__dirname, 'src/admin/error.html'),
        pc: resolve(__dirname, 'src/pc/index.html'),
        pc_error: resolve(__dirname, 'src/pc/error.html'),
        pc_urlproxy_error: resolve(__dirname, 'src/pc/urlproxy_error.html'),
      },
    },
  },
  server: {
    host: '0.0.0.0',
    port: 5173,
    strictPort: true,
    open: '/src/admin/login.html',
    proxy: {
      '/api': {
        target: 'http://localhost:5001', // << Backend-URL
        changeOrigin: true,
        // Logging
        configure: (proxy) => {
          proxy.on('proxyReq', (proxyReq, req) => {
            console.log('[PROXY] →', req.method, req.url);
          });
          proxy.on('proxyRes', (proxyRes, req) => {
            console.log('[PROXY] ←', proxyRes.statusCode, req.method, req.url);
          });
          proxy.on('error', (err, req) => {
            console.error('[PROXY ERROR]', req.method, req.url, err?.message);
          });
        },
      },
      // lass Vite nur /api proxyen
    },
    // zus. Middleware-Log (zeigt überhaupt an, was 5173 empfängt)
    configureServer(server) {
      server.middlewares.use((req, _res, next) => {
        console.log('[DEV]', req.method, req.url);
        next();
      });
    },
  },
});
