"use client"

import type React from "react"

export default function DocsLayout({ children }: { children: React.ReactNode }) {
  return <div className="min-h-screen bg-white text-gray-900">{children}</div>
}

