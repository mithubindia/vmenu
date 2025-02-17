import DocSidebar from "@/components/DocSidebar"
import type React from "react"

export default function DocsLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="flex flex-col md:flex-row min-h-screen pt-40 md:pt-16">
      <DocSidebar />
      <main className="flex-1 p-4 md:p-6 mt-4 md:mt-0">{children}</main>
    </div>
  )
}

