"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import { useState } from "react"
import { ChevronDown, ChevronRight } from "lucide-react"

interface SubMenuItem {
  title: string
  href: string
}

interface MenuItem {
  title: string
  href?: string
  submenu?: SubMenuItem[]
}

const sidebarItems: MenuItem[] = [
  { title: "Introduction", href: "/docs/introduction" },
  { title: "Installation", href: "/docs/installation" },
  {
    title: "Hardware: GPUs and Coral",
    submenu: [
      { title: "HW iGPU acceleration to an LXC", href: "/docs/hardware/igpu-acceleration-lxc" },
      { title: "Coral TPU to an LXC", href: "/docs/hardware/coral-tpu-lxc" },
      { title: "Install Coral TPU on the Host", href: "/docs/hardware/install-coral-tpu-host" },
    ],
  },
  {
    title: "Storage",
    submenu: [
      { title: "Disk Passthrough to a VM", href: "/docs/storage/disk-passthrough-vm" },
      { title: "Import Disk Image to a VM", href: "/docs/storage/import-disk-image-vm" },
    ],
  },
]

export default function DocSidebar() {
  const pathname = usePathname()
  const [openSections, setOpenSections] = useState<{ [key: string]: boolean }>({})

  const toggleSection = (title: string) => {
    setOpenSections((prev) => ({ ...prev, [title]: !prev[title] }))
  }

  const renderMenuItem = (item: MenuItem) => {
    if (item.submenu) {
      const isOpen = openSections[item.title] || false
      return (
        <li key={item.title} className="mb-2">
          <button
            onClick={() => toggleSection(item.title)}
            className="flex items-center justify-between w-full text-left p-2 rounded hover:bg-gray-200"
          >
            <span>{item.title}</span>
            {isOpen ? <ChevronDown className="h-4 w-4" /> : <ChevronRight className="h-4 w-4" />}
          </button>
          {isOpen && (
            <ul className="ml-4 mt-2 space-y-2">
              {item.submenu.map((subItem) => (
                <li key={subItem.href}>
                  <Link
                    href={subItem.href}
                    className={`block p-2 rounded ${
                      pathname === subItem.href
                        ? "bg-blue-500 text-white"
                        : "text-gray-700 hover:bg-gray-200 hover:text-gray-900"
                    }`}
                  >
                    {subItem.title}
                  </Link>
                </li>
              ))}
            </ul>
          )}
        </li>
      )
    } else {
      return (
        <li key={item.href}>
          <Link
            href={item.href!}
            className={`block p-2 rounded ${
              pathname === item.href ? "bg-blue-500 text-white" : "text-gray-700 hover:bg-gray-200 hover:text-gray-900"
            }`}
          >
            {item.title}
          </Link>
        </li>
      )
    }
  }

  return (
    <nav className="w-full md:w-64 bg-gray-100 p-4 md:p-6">
      <h2 className="text-lg font-semibold mb-4 text-gray-900">Documentation</h2>
      <ul className="space-y-2">{sidebarItems.map(renderMenuItem)}</ul>
    </nav>
  )
}

