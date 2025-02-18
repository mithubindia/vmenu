import type { Metadata } from "next"
import Hero from "@/components/hero"
import Resources from "@/components/resources"
import SupportProject from "@/components/support-project"
import Footer from "@/components/footer"

export const metadata: Metadata = {
  title: "ProxMenux",
  description:
    "A menu-driven script for Proxmox VE management, designed to simplify and streamline the execution of commands and tasks.",
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
