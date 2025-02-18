import type { Metadata } from 'next'

const basePath = "/ProxMenux"

const description = "A menu-driven script for Proxmox VE management, designed to facilitate productivity, it simplifies automation and streamlines task execution."

export const metadata: Metadata = {
  title: {
    default: "ProxMenux",
    template: "%s | ProxMenux",
  },
  description,
  generator: "Next.js",
  applicationName: "ProxMenux",
  referrer: "origin-when-cross-origin",
  keywords: ["Proxmox VE", "VE", "ProxMenux", "MacRimi", "menu-driven", "menu", "scripts", "virtualization"],
  authors: [{ name: "MacRimi" }],
  creator: "MacRimi",
  publisher: "MacRimi",
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  metadataBase: new URL(`https://macrimi.github.io${basePath}/`),
  openGraph: {
    title: "ProxMenux",
    description,
    url: `https://macrimi.github.io${basePath}/`,
    siteName: "ProxMenux",
    images: [
      {
        url: `https://macrimi.github.io${basePath}/main.png`,
        width: 1363,
        height: 735,
      },
    ],
    locale: "en_US",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "ProxMenux",
    description,
    images: [`https://macrimi.github.io${basePath}/main.png`],
  },
  icons: {
    icon: [
      { url: "/favicon.ico", sizes: "any" },
      { url: "/icon.svg", type: "image/svg+xml" },
    ],
    apple: [{ url: "/apple-touch-icon.png" }],
  },
}