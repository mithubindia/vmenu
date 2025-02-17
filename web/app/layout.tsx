import "./globals.css"
import { Inter } from "next/font/google"
import Navbar from "@/components/navbar"
import MouseMoveEffect from "@/components/mouse-move-effect"
import DocSidebar from "@/components/DocSidebar"
import type React from "react"
import type { Metadata } from "next"

const inter = Inter({ subsets: ["latin"] })

const basePath = "/ProxMenux"

const description =
  "A menu-driven script for Proxmox VE management, designed to facilitate productivity, it simplifies automation and streamlines task execution."

export const metadata: Metadata = {
  title: "ProxMenux",
  description,
  generator: "Next.js",
  applicationName: "ProxMenux",
  referrer: "origin-when-cross-origin",
  keywords: ["Proxmox VE", "ProxMenux", "menu-driven", "script", "management", "virtualization"],
  authors: { name: "MacRimi" },
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
    images: [
      {
        url: `https://macrimi.github.io${basePath}/main.png`,
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
      { url: "/icon.png", type: "image/png" },
    ],
    apple: [{ url: "/apple-touch-icon.png" }],
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className="dark">
      <body className={`${inter.className} bg-background text-foreground antialiased`}>
        <Navbar />
        <MouseMoveEffect />
        <div className="flex flex-col md:flex-row min-h-screen pt-28 md:pt-16">
          <DocSidebar />
          <main className="flex-1 p-4 md:p-6">{children}</main>
        </div>
      </body>
    </html>
  )
}

