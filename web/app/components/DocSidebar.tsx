"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import { useState } from "react"
import { Menu } from "lucide-react"

const sidebarItems = [
  { title: "Introduction", href: "/docs/introduction" },
  { title: "Installation", href: "/docs/installation" },
  { title: "Getting Started", href: "/docs/getting-started" },
  { title: "Features", href: "/docs/features" },
  { title: "API", href: "/docs/api" },
  { title: "Guides", href: "/guides" },
  { title: "FAQ", href: "/docs/faq" },
]

export default function DocSidebar() {
  const pathname = usePathname()
  const [isOpen, setIsOpen] = useState(false)

  return (
    <nav className="w-full md:w-64 bg-gray-100 p-4 md:p-6">
      <div className="flex justify-between items-center md:block">
        <h2 className="text-lg font-semibold mb-4 text-gray-900">Documentation</h2>
        <button className="md:hidden" onClick={() => setIsOpen(!isOpen)}>
          <Menu className="h-6 w-6" />
        </button>
      </div>
      <ul className={`space-y-2 ${isOpen ? "block" : "hidden"} md:block`}>
        {sidebarItems.map((item) => (
          <li key={item.href}>
            <Link
              href={item.href}
              className={`block p-2 rounded ${
                pathname === item.href
                  ? "bg-blue-500 text-white"
                  : "text-gray-700 hover:bg-gray-200 hover:text-gray-900"
              }`}
              onClick={() => setIsOpen(false)}
            >
              {item.title}
            </Link>
          </li>
        ))}
      </ul>
    </nav>
  )
}

