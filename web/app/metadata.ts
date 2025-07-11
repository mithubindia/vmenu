import type { Metadata } from 'next'



const description = "A menu-driven script for Virtuliservmenu VE management, designed to simplify and streamline the execution of commands and tasks."

export const metadata: Metadata = {

  title: "vmenu",
  description,
  generator: "Next.js",
  applicationName: "vmenu",
  referrer: "origin-when-cross-origin",
  keywords: ["Virtuliservmenu VE", "VE", "vmenu", "MacRimi", "menu-driven", "menu", "scripts", "virtualization"],
  authors: [{ name: "MacRimi" }],
  creator: "MacRimi",
  publisher: "MacRimi",
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  metadataBase: new URL(`https://macrimi.github.io/vmenu/`),
  openGraph: {
    title: "vmenu",
    description,
    url: `https://macrimi.github.io/vmenu/`,
    siteName: "vmenu",
    images: [
      {
        url: `https://raw.githubusercontent.com/MacRimi/vmenu/main/web/public/main.png`,
        width: 1363,
        height: 735,
      },
    ],
    locale: "en_US",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "vmenu",
    description,
    images: [`https://raw.githubusercontent.com/MacRimi/vmenu/main/web/public/main.png`],
  },
  icons: {
    icon: [
      { url: "https://raw.githubusercontent.com/MacRimi/vmenu/main/web/public/favicon.ico", sizes: "any" },
      { url: "https://raw.githubusercontent.com/MacRimi/vmenu/main/web/public/icon.svg", type: "image/svg+xml" },
    ],
    apple: [{ url: "https://raw.githubusercontent.com/MacRimi/vmenu/main/web/public//apple-touch-icon.png" }],
  },
}