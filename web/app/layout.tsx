import "./globals.css"
import { Inter } from "next/font/google"
import Navbar from "@/components/navbar"
import MouseMoveEffect from "@/components/mouse-move-effect"
import type React from "react"
import { metadata } from "./metadata"

const inter = Inter({ subsets: ["latin"] })

export { metadata }

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className="dark">
      <head>
        <title>{metadata.title?.toString()}</title>
        <meta name="description" content={metadata.description} />
        <meta name="application-name" content={metadata.applicationName} />
        <meta name="author" content={metadata.authors?.[0]?.name} />
        <meta name="generator" content={metadata.generator} />
        <meta name="keywords" content={metadata.keywords?.join(",")} />
        <meta name="referrer" content={metadata.referrer} />
        <meta name="creator" content={metadata.creator} />
        <meta name="publisher" content={metadata.publisher} />
        <meta property="og:title" content={metadata.openGraph.title} />
        <meta property="og:description" content={metadata.openGraph.description} />
        <meta property="og:url" content={metadata.openGraph.url} />
        <meta property="og:site_name" content={metadata.openGraph.siteName} />
        <meta property="og:locale" content={metadata.openGraph.locale} />
        <meta property="og:type" content={metadata.openGraph.type} />
        <meta property="og:image" content={metadata.openGraph.images[0].url} />
        <meta property="og:image:width" content={metadata.openGraph.images[0].width?.toString()} />
        <meta property="og:image:height" content={metadata.openGraph.images[0].height?.toString()} />
        <meta name="twitter:card" content={metadata.twitter.card} />
        <meta name="twitter:title" content={metadata.twitter.title} />
        <meta name="twitter:description" content={metadata.twitter.description} />
        <meta name="twitter:image" content={metadata.twitter.images?.[0]} />
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

