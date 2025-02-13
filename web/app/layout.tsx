import "./globals.css"
import { Inter } from "next/font/google"
import type { Metadata } from "next"
import ClientLayout from "@/components/ClientLayout" // ✅ Import ClientLayout (Recommended)

const inter = Inter({ subsets: ["latin"] })

export const metadata: Metadata = {
  title: "ProxMenux - A menu-driven script for Proxmox VE management",
  description:
    "ProxMenux is a tool designed to execute shell scripts in an organized manner for Proxmox VE management.",
  generator: "v0.dev",
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className="dark">
      <body className={`${inter.className} bg-background text-foreground antialiased`}>
        <ClientLayout>  {/* ✅ Now using ClientLayout */}
          {children}
        </ClientLayout>
      </body>
    </html>
  )
}
