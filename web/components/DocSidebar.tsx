"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import { useState, useEffect } from "react"
import { ChevronDown, ChevronRight, Menu, X } from "lucide-react"

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
    title: "GPUs and Coral",
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
  {
    title: "Network",
    submenu: [
      { title: "Repair Network", href: "/docs/network/repair-network" },
      { title: "Verify Network", href: "/docs/network/verify-network" },
      { title: "Show IP Information", href: "/docs/network/show-ip-information" },
    ],
  },
  {
    title: "Settings ProxMenux",
    submenu: [
      { title: "Change Language", href: "/docs/settings/change-language" },
      { title: "Show Version Information", href: "/docs/settings/show-version-information" },
      { title: "Uninstall ProxMenux", href: "/docs/settings/uninstall-proxmenux" },
    ],
  },
]

export default function DocSidebar() {
  const pathname = usePathname()
  const [openSections, setOpenSections] = useState<{ [key: string]: boolean }>({})
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false)

  const toggleSection = (title: string) => {
    setOpenSections((prev) => ({ ...prev, [title]: !prev[title] }))
  }

  const toggleMobileMenu = () => {
    setIsMobileMenuOpen(!isMobileMenuOpen)
  }

  useEffect(() => {
    const handleResize = () => {
      if (window.innerWidth >= 768) {
        setIsMobileMenuOpen(false)
      }
    }

    window.addEventListener("resize", handleResize)
    return () => window.removeEventListener("resize", handleResize)
  }, [])

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
                    onClick={() => setIsMobileMenuOpen(false)}
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
            onClick={() => setIsMobileMenuOpen(false)}
          >
            {item.title}
          </Link>
        </li>
      )
    }
  }

  return (
    <>
      <button
        className="md:hidden fixed top-4 right-4 z-50 p-2 bg-gray-100 rounded-md"
        onClick={toggleMobileMenu}
        aria-label="Toggle menu"
      >
        {isMobileMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
      </button>
      <nav
        className={`fixed md:static top-16 left-0 w-full h-[calc(100vh-4rem)] md:h-auto md:w-64 bg-gray-100 p-4 md:p-6 transform ${
          isMobileMenuOpen ? "translate-x-0" : "-translate-x-full"
        } md:translate-x-0 transition-transform duration-300 ease-in-out overflow-y-auto z-40`}
      >
        <h2 className="text-lg font-semibold mb-4 text-gray-900">Documentation</h2>
        <ul className="space-y-2">{sidebarItems.map(renderMenuItem)}</ul>
      </nav>
    </>
  )
}
