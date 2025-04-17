"use client"

import Link from "next/link"
import { ChevronLeft, ChevronRight } from "lucide-react"
import { usePathname } from "next/navigation"
import { sidebarItems } from "@/components/DocSidebar"

interface DocNavigationProps {
  className?: string
}

export function DocNavigation({ className }: DocNavigationProps) {
  const pathname = usePathname()

  const flattenSidebarItems = () => {
    const flatItems: Array<{ title: string; href: string; section?: string }> = []

    sidebarItems.forEach((item) => {
      if (item.href) {
        flatItems.push({ title: item.title, href: item.href })
      }

      if (item.submenu) {
        item.submenu.forEach((subItem) => {
          flatItems.push({
            title: subItem.title,
            href: subItem.href,
            section: item.title, 
          })
        })
      }
    })

    return flatItems
  }

  const allPages = flattenSidebarItems()

  const currentPageIndex = allPages.findIndex((page) => page.href === pathname)

  const prevPage = currentPageIndex > 0 ? allPages[currentPageIndex - 1] : null
  const nextPage = currentPageIndex < allPages.length - 1 ? allPages[currentPageIndex + 1] : null

  if (!prevPage && !nextPage) return null

  return (
    <div className={`mt-16 ${className || ""}`}>

      <div className="w-full h-0.5 bg-gray-300 mb-8"></div>

      <div className="flex flex-col sm:flex-row justify-between gap-4">
        {prevPage ? (
          <Link
            href={prevPage.href}
            className="flex items-center p-4 border-2 border-gray-300 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition-all duration-200 group w-full sm:w-[calc(50%-0.5rem)] sm:max-w-[calc(50%-0.5rem)]"
          >
            <ChevronLeft className="h-5 w-5 mr-2 text-gray-500 group-hover:text-blue-500 flex-shrink-0" />
            <div className="min-w-0 overflow-hidden">
              <div className="text-sm text-gray-500 group-hover:text-blue-600 truncate">
                {prevPage.section ? `${prevPage.section}: ` : ""}Previous
              </div>
              <div className="font-medium group-hover:text-blue-700 truncate">{prevPage.title}</div>
            </div>
          </Link>
        ) : (
          <div className="hidden sm:block sm:w-[calc(50%-0.5rem)]"></div> 
        )}

        {nextPage ? (
          <Link
            href={nextPage.href}
            className="flex items-center justify-end p-4 border-2 border-gray-300 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition-all duration-200 group sm:text-right w-full sm:w-[calc(50%-0.5rem)] sm:max-w-[calc(50%-0.5rem)] ml-auto"
          >
            <div className="min-w-0 overflow-hidden">
              <div className="text-sm text-gray-500 group-hover:text-blue-600 truncate">
                {nextPage.section ? `${nextPage.section}: ` : ""}Next
              </div>
              <div className="font-medium group-hover:text-blue-700 truncate">{nextPage.title}</div>
            </div>
            <ChevronRight className="h-5 w-5 ml-2 text-gray-500 group-hover:text-blue-500 flex-shrink-0" />
          </Link>
        ) : (
          <div className="hidden sm:block sm:w-[calc(50%-0.5rem)]"></div> 
        )}
      </div>
    </div>
  )
}
