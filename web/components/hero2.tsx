"use client"

import { Button } from "@/components/ui/button"
import { ArrowRight } from "lucide-react"
import Link from "next/link"
import Image from "next/image"

export default function Hero() {
  return (
    <div className="bg-gradient-to-b from-gray-900 to-gray-800 text-white">
      <section className="py-20 px-4 sm:px-6 lg:px-8 flex flex-col justify-center">
        <div className="flex flex-col md:flex-row items-center justify-center mb-8">
          <div className="flex flex-col md:flex-row items-center">
            <div className="w-32 h-32 sm:w-40 sm:h-40 md:w-48 md:h-48 lg:w-56 lg:h-56 xl:w-64 xl:h-64 relative mb-6 md:mb-0 md:mr-6">
              <Image
                src="https://raw.githubusercontent.com/MacRimi/ProxMenux/main/images/logo.png"
                alt="ProxMenux Logo"
                fill
                className="object-contain"
                sizes="(max-width: 640px) 8rem, (max-width: 768px) 10rem, (max-width: 1024px) 12rem, (max-width: 1280px) 14rem, 16rem"
              />
            </div>
            <div className="hidden md:block w-0.5 h-40 lg:h-48 xl:h-56 bg-white mx-4 md:mx-6 self-center"></div>
            <div className="text-center md:text-left mt-4 md:mt-0 max-w-full md:max-w-md lg:max-w-lg xl:max-w-xl">
              <h1 className="text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-extrabold text-white leading-tight">
                ProxMenux
              </h1>
              <p className="text-lg sm:text-xl md:text-2xl lg:text-3xl xl:text-4xl mt-2 bg-clip-text text-transparent bg-gradient-to-r from-blue-400 to-purple-500 font-bold leading-tight">
                An Interactive Menu for Proxmox VE Management
              </p>
            </div>
          </div>
        </div>
        <p className="text-base sm:text-lg md:text-xl mb-8 max-w-xs sm:max-w-sm md:max-w-2xl lg:max-w-3xl xl:max-w-4xl mx-auto text-gray-300 text-center leading-relaxed">
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



