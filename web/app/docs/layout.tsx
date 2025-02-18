import type { ReactNode } from "react"
import DocSidebar from "@/components/DocSidebar"

interface LayoutProps {
  children: ReactNode
}

export default function DocsLayout({ children }: LayoutProps) {
  return (
    <div className="flex flex-col lg:flex-row min-h-screen bg-white">
      <DocSidebar />
      <main className="flex-1 p-4 lg:p-8 pt-24 lg:pt-8 overflow-y-auto">
        <div className="max-w-3xl mx-auto lg:mx-0 lg:mr-auto">{children}</div>
      </main>
    </div>
  )
}

