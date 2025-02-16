import "./globals.css"
import { Inter } from "next/font/google"
import Navbar from "@/components/navbar"
import MouseMoveEffect from "@/components/mouse-move-effect"
import type React from "react"
import type { Metadata } from "next"

const inter = Inter({ subsets: ["latin"] })

export const metadata: Metadata = {
  title: "ProxMenux",
  description: "A menu-driven script for Proxmox VE management",
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
        <div className="pt-16 md:pt-16">{children}</div>
      </body>
    </html>
  )
}

