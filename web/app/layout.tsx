import "./globals.css"
import { Inter } from "next/font/google"
import Navbar from "@/components/navbar"
import MouseMoveEffect from "@/components/mouse-move-effect"
import type React from "react"

const inter = Inter({ subsets: ["latin"] })

export const metadata = {
  title: "vmenu",
  generator: "Next.js",
  applicationName: "vmenu",
  referrer: "origin-when-cross-origin",
  keywords: ["Virtuliser VE", "VE", "vmenu", "MacRimi", "menu-driven", "menu", "scripts", "virtualization"],
  authors: [{ name: "MacRimi" }],
  creator: "MacRimi",
  publisher: "MacRimi",
  description:
    "A menu-driven script for Virtuliser VE management, designed to simplify and streamline the execution of commands and tasks.",
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  metadataBase: new URL(`https://macrimi.github.io/vmenu/`),
  openGraph: {
    title: "vmenu",
    description:
      "A menu-driven script for Virtuliser VE management, designed to simplify and streamline the execution of commands and tasks.",
    url: "https://macrimi.github.io/vmenu/",
    siteName: "vmenu",
    images: [
      {
        url: "https://macrimi.github.io/vmenu/main.png",
        width: 1363,
        height: 735,
        alt: "vmenu",
      },
    ],
    locale: "en_US",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "vmenu",
    description:
      "A menu-driven script for Virtuliser VE management, designed to simplify and streamline the execution of commands and tasks.",
    images: ["https://macrimi.github.io/vmenu/main.png"],
  },
  icons: {
    icon: [
      { url: "https://macrimi.github.io/vmenu/favicon.ico", sizes: "any" },
      { url: "https://macrimi.github.io/vmenu/icon.svg", type: "image/svg+xml" },
    ],
    apple: [{ url: "https://macrimi.github.io/vmenu/apple-touch-icon.png", sizes: "180x180" } as const],
  },
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className="dark">
      <head>
        <meta name="description" content={metadata.description} />
        <meta property="og:title" content={metadata.openGraph?.title} />
        <meta property="og:description" content={metadata.openGraph?.description} />
        <meta property="og:image" content={metadata.openGraph?.images?.[0]?.url} />
        <meta property="og:url" content={metadata.openGraph?.url} />
        <meta name="twitter:card" content="summary_large_image" />
        <meta name="twitter:title" content={metadata.twitter?.title} />
        <meta name="twitter:description" content={metadata.twitter?.description} />
        <meta name="twitter:image" content={metadata.twitter?.images?.[0]} />
        <link rel="canonical" href={metadata.metadataBase.href} />

        {/* Favicon y Apple Icons */}
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
      </body>
    </html>
  )
}
