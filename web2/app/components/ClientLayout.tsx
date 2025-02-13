"use client";

import Navbar from "@/components/navbar"
import MouseMoveEffect from "@/components/mouse-move-effect"

export default function ClientLayout({ children }: { children: React.ReactNode }) {
  return (
    <>
      <Navbar />
      <MouseMoveEffect />
      <div className="pt-16 md:pt-16">{children}</div>
    </>
  )
}
