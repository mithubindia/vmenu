import "./globals.css"
import { Inter } from "next/font/google"
import Navbar from "@/components/navbar"
import MouseMoveEffect from "@/components/mouse-move-effect"
import Footer from "@/components/footer"
import type React from "react"

const inter = Inter({ subsets: ["latin"] })

const basePath = "/ProxMenux"

export const metadata = {
  title: "ProxMenux",
  generator: "Next.js",
  applicationName: "ProxMenux",
  referrer: "origin-when-cross-origin",
  keywords: ["Proxmox VE", "VE", "ProxMenux", "MacRimi", "menu-driven", "menu", "scripts", "virtualization"],
  authors: [{ name: "MacRimi" }],
  creator: "MacRimi",
  publisher: "MacRimi",
  description:
    "A menu-driven script for Proxmox VE management, designed to simplify and streamline the execution of commands and tasks.",
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  metadataBase: new URL(`https://macrimi.github.io${basePath}/`),
  openGraph: {
    title: "ProxMenux",
    description:
      "A menu-driven script for Proxmox VE management, designed to simplify and streamline the execution of commands and tasks.",
    url: "/main.png",
    siteName: "ProxMenux",
    images: [
      {
        url: `https://raw.githubusercontent.com/MacRimi/ProxMenux/main/web/public/main.png`,
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
    description:
      "A menu-driven script for Proxmox VE management, designed to simplify and streamline the execution of commands and tasks.",
    images: [`https://raw.githubusercontent.com/MacRimi/ProxMenux/main/web/public/main.png`],
  },
  icons: {
    icon: [
      { url: `https://raw.githubusercontent.com/MacRimi/ProxMenux/main/web/public/favicon.ico`, sizes: "any" },
      { url: `https://raw.githubusercontent.com/MacRimi/ProxMenux/main/web/public/icon.svg`, type: "image/svg+xml" },
    ],
    apple: [{ url: `https://raw.githubusercontent.com/MacRimi/ProxMenux/main/web/public/apple-touch-icon.png` }],
  },
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className="dark">
      <head>
        <link rel="canonical" href={metadata.metadataBase.href} />
        {metadata.icons.icon.map((icon, index) => (
          <link key={index} rel="icon" type={icon.type} sizes={icon.sizes} href={icon.url} />
        ))}
        {metadata.icons.apple.map((icon, index) => (
          <link key={index} rel="apple-touch-icon" sizes={icon.sizes} href={icon.url} />
        ))}
      </head>
      <body className={`${inter.className} bg-background text-foreground antialiased`}>
        <Navbar />
        <MouseMoveEffect />
        <div className="pt-16 md:pt-16">{children}</div>
        <Footer />
      </body>
    </html>
  )
}

