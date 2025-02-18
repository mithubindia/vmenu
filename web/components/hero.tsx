"use client"

import type { Metadata } from "next"
import { Button } from "@/components/ui/button"
import { ArrowRight } from "lucide-react"
import Link from "next/link"

export const metadata: Metadata = {
  title: "ProxMenux",
  description:
    "A menu-driven script for Proxmox VE management, designed to simplify and streamline the execution of commands and tasks.",
}

export default function Hero() {
  return (
    <section className="py-20 px-4 sm:px-6 lg:px-8 text-center">
      <h1 className="text-4xl sm:text-5xl md:text-6xl font-extrabold mb-6">
        ProxMenux{" "}
        <span className="bg-clip-text text-transparent bg-gradient-to-r from-blue-400 to-purple-500">
          A menu-driven script for Proxmox VE management
        </span>
      </h1>
      <p className="text-base sm:text-lg md:text-xl mb-8 max-w-4xl mx-auto text-gray-300">
       ProxMenux is a tool for executing shell scripts in a user-friendly way, featuring a categorized menu system for easy access to scripts hosted on GitHub. 
       Designed to facilitate productivity, it simplifies automation and streamlines task execution.
      </p>
      <div className="flex justify-center">
        <Button size="lg" className="bg-blue-500 hover:bg-blue-600" asChild>
          <Link href="/docs/installation">
            Install Now
            <ArrowRight className="ml-2 h-4 w-4" />
          </Link>
        </Button>
      </div>
    </section>
  )
}

