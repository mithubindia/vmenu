import type React from "react"
import DocSidebar from "@/components/DocSidebar"
import Footer from "@/components/footer"

export default function DocsLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex flex-col min-h-screen bg-white text-gray-900 pt-28 md:pt-16">
      <div className="flex flex-col md:flex-row flex-1 pt-4 md:pt-0">
        <DocSidebar />
        <main className="flex-1 p-4 md:p-6">{children}</main>
      </div>
      <Footer />
    </div>
  )
}

