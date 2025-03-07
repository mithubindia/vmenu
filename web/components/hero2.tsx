"use client"

import { Button } from "@/components/ui/button"
import { ArrowRight } from "lucide-react"
import Link from "next/link"
import Image from "next/image"

export default function Hero() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-900 to-gray-800 text-white">
      <section className="py-20 px-4 sm:px-6 lg:px-8 h-full flex flex-col justify-center">
        <div className="flex items-center justify-center mb-8">
          <div className="flex items-center">
            <Image
              src="https://raw.githubusercontent.com/MacRimi/ProxMenux/main/images/logo.png"
              alt="ProxMenux Logo"
              width={200}
              height={200}
              className="mr-2"
            />
            <div className="w-0.5 h-60 bg-white mx-6 self-center"></div> 
            <div className="text-left">
              <h1 className="text-4xl sm:text-5xl md:text-6xl font-extrabold text-white">ProxMenux</h1>
              <p className="text-2xl sm:text-3xl md:text-4xl mt-2 bg-clip-text text-transparent bg-gradient-to-r from-blue-400 to-purple-500 font-bold">
                An Interactive Menu for Proxmox VE Management
              </p>
            </div>
          </div>
        </div>
        <p className="text-base sm:text-lg md:text-xl mb-8 max-w-4xl mx-auto text-gray-300 text-center">
          ProxMenux is a management tool for Proxmox VE that simplifies system administration through an interactive
          menu, allowing you to execute commands and scripts with ease.
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
    </div>
  )
}

