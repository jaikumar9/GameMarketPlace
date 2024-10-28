import React from "react";
import ReactDOM from "react-dom/client";
import "./index.css";
import App from "./App";
import reportWebVitals from "./reportWebVitals";
import { createAppKit } from "@reown/appkit/react";

import { WagmiProvider } from "wagmi";
import { arbitrum, mainnet } from "@reown/appkit/networks";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { WagmiAdapter } from "@reown/appkit-adapter-wagmi";
import { BrowserRouter } from "react-router-dom";

// BSC Testnet Network Configuration
const bscTestnet = {
  id: 97, // BSC Testnet chain ID
  name: "BSC Testnet",
  network: "bsc-testnet",
  rpcUrls: {
    default: "https://data-seed-prebsc-1-s1.binance.org:8545/", // Public RPC URL
  },
  blockExplorers: {
    default: { name: "BscScan", url: "https://testnet.bscscan.com" },
  },
  nativeCurrency: {
    name: "BNB",
    symbol: "BNB",
    decimals: 18,
  },
};

// Setup queryClient
const queryClient = new QueryClient();

// Project configuration
const projectId = "5b82111b61862500d529e7e488de98f4";
const metadata = {
  name: "AppKit",
  description: "AppKit Example",
  url: "https://example.com",
  icons: ["https://avatars.githubusercontent.com/u/179229932"],
};

// Include the BSC Testnet network
const networks = [mainnet, arbitrum, bscTestnet];

// Setup Wagmi Adapter
const wagmiAdapter = new WagmiAdapter({
  networks,
  projectId,
  ssr: true,
});

// Create modal with AppKit
createAppKit({
  adapters: [wagmiAdapter],
  networks,
  projectId,
  metadata,
  features: {
    analytics: true,
  },
});

const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(
  <React.StrictMode>
    <BrowserRouter>
      <WagmiProvider config={wagmiAdapter.wagmiConfig}>
        <App />
      </WagmiProvider>
    </BrowserRouter>
  </React.StrictMode>
);

// Optional: Log performance metrics
reportWebVitals();
