import { defineConfig } from "vite";
import react from "@vitejs/plugin-react-swc";
import path from "path";

// https://vitejs.dev/config/
export default defineConfig({
  base: "/", // Ensure correct base path for Vercel
  server: {
    host: "::",
    port: 8080,
  },
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  build: {
    outDir: "dist",
    sourcemap: false,
    minify: "esbuild",
    rollupOptions: {
      output: {
        // Simplified chunking strategy
        manualChunks: (id) => {
          if (id.includes('node_modules')) {
            if (id.includes('wagmi') || id.includes('@wagmi')) {
              return 'wagmi';
            }
            if (id.includes('react') || id.includes('react-dom')) {
              return 'react';
            }
            return 'vendor';
          }
        },
        // Consistent file naming
        chunkFileNames: 'assets/[name]-[hash].js',
        entryFileNames: 'assets/[name]-[hash].js',
        assetFileNames: 'assets/[name]-[hash].[ext]',
      },
    },
    // Increase chunk size warning limit
    chunkSizeWarningLimit: 1000,
    // Ensure assets are properly generated
    assetsInlineLimit: 0,
  },
  // Optimize dependencies
  optimizeDeps: {
    include: ['wagmi', '@wagmi/core', '@wagmi/connectors'],
  },
});
