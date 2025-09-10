import { http, createConfig } from 'wagmi';
import { sepolia, mainnet } from 'wagmi/chains';
import { injected, metaMask, coinbaseWallet, walletConnect } from 'wagmi/connectors';

// Get projectId from https://cloud.walletconnect.com
export const projectId = import.meta.env.VITE_WALLETCONNECT_PROJECT_ID || 'e08e99d213c331aa0fd00f625de06e66';

export const config = createConfig({
  chains: [sepolia, mainnet],
  connectors: [
    // Use specific connectors to avoid conflicts with browser extensions
    metaMask(),
    coinbaseWallet({
      appName: 'Trust Confidential Verify',
      appLogoUrl: 'https://trust-confidential-verify.vercel.app/icon.svg',
    }),
    walletConnect({
      projectId,
      metadata: {
        name: 'Trust Confidential Verify',
        description: 'FHE-Powered Trust Verification Platform',
        url: 'https://trust-confidential-verify.vercel.app',
        icons: ['https://trust-confidential-verify.vercel.app/icon.svg']
      }
    }),
    // Generic injected connector as fallback (but with lower priority)
    injected({
      target: 'metaMask', // Only target MetaMask to reduce conflicts
    }),
  ],
  transports: {
    [sepolia.id]: http(import.meta.env.VITE_RPC_URL || 'https://sepolia.rpc.zama.ai'),
    [mainnet.id]: http(),
  },
});

declare module 'wagmi' {
  interface Register {
    config: typeof config
  }
}
