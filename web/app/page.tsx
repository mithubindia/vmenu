import dynamic from "next/dynamic"
import type { Metadata } from "next"
import { metadata as siteMetadata } from './metadata'

const Hero = dynamic(() => import("@/components/hero"), { ssr: false })
const Resources = dynamic(() => import("@/components/resources"), { ssr: false })
const SupportProject = dynamic(() => import("@/components/support-project"), { ssr: false })
const Footer = dynamic(() => import("@/components/footer"), { ssr: false })

export const metadata: Metadata = {
  ...siteMetadata,
  title: "ProxMenux - Home",
  openGraph: {
    ...siteMetadata.openGraph,
    title: "ProxMenux - Home",
  },
  twitter: {
    ...siteMetadata.twitter,
    title: "ProxMenux - Home",
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