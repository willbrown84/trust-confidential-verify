# Trust Confidential Verify

A privacy-preserving verification platform built with FHE (Fully Homomorphic Encryption) technology, enabling secure document verification and KYC processes while maintaining complete privacy.

## Features

- **Privacy-First Design**: All sensitive data is encrypted using FHE technology
- **Document Verification**: Secure document upload and verification process
- **KYC Dashboard**: Comprehensive Know Your Customer management system
- **Wallet Integration**: Connect with popular Web3 wallets
- **Real-time Verification**: Monitor verification status securely
- **Decentralized Architecture**: Built on blockchain technology

## Technologies Used

- **Frontend**: React, TypeScript, Vite
- **UI Components**: shadcn/ui, Tailwind CSS
- **Blockchain**: Solidity, FHEVM
- **Privacy**: Fully Homomorphic Encryption (FHE)
- **Wallet Integration**: RainbowKit, Wagmi, Viem

## Getting Started

### Prerequisites

- Node.js (v18 or higher)
- npm or yarn
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/willbrown84/trust-confidential-verify.git
cd trust-confidential-verify
```

2. Install dependencies:
```bash
npm install
```

3. Start the development server:
```bash
npm run dev
```

4. Open your browser and navigate to `http://localhost:5173`

## Project Structure

```
src/
├── components/          # React components
│   ├── ui/             # shadcn/ui components
│   ├── Header.tsx      # Application header
│   ├── WalletComponent.tsx # Wallet connection component
│   └── KYCDashboard.tsx # KYC management component
├── pages/              # Application pages
├── hooks/              # Custom React hooks
├── lib/                # Utility functions
└── contracts/          # Smart contracts
```

## Smart Contracts

The project includes FHE-enabled smart contracts for:
- Secure document storage
- Privacy-preserving verification
- Encrypted KYC data management
- Anonymous verification processes

## Development

### Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run compile` - Compile smart contracts
- `npm run test` - Run contract tests
- `npm run deploy` - Deploy to Sepolia testnet

## Deployment

This project can be deployed to Vercel:

1. Connect your GitHub repository to Vercel
2. Configure build settings:
   - Build Command: `npm run build`
   - Output Directory: `dist`
3. Deploy automatically on push to main branch

## License

This project is licensed under the MIT License.
