import dynamic from "next/dynamic"
import { Metadata } from "next"

const Hero = dynamic(() => import("@/components/hero"), { ssr: false })
const Resources = dynamic(() => import("@/components/resources"), { ssr: false })
const SupportProject = dynamic(() => import("@/components/support-project"), { ssr: false })
const Footer = dynamic(() => import("@/components/footer"), { ssr: false })


export const metadata: Metadata = {
  title: "ProxMenux",
  favicon: "/favicon.ico",
  apple: "/apple-touch-icon.png", 
  description:
    "A menu-driven script for Proxmox VE management, designed to facilitate productivity, it simplifies automation and streamlines task execution.",
  openGraph: {
    title: "ProxMenux",
    description:
     "A menu-driven script for Proxmox VE management, designed to facilitate productivity, it simplifies automation and streamlines task execution.",
    url: "https://macrimi.github.io/ProxMenux/",
    siteName: "ProxMenux",
    images: [
      {
        url: "https://macrimi.github.io/ProxMenux/main.png", 
      },
    ],
    locale: "en_US",
    type: "website",
  },
}

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-900 to-gray-800 text-white pt-16">
      <Hero />
      <Resources />
      <SupportProject />
      <Footer />
    </div>
  )
}
