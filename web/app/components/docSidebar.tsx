import Link from "next/link"
import { usePathname } from "next/navigation"

const sidebarItems = [
  { title: "Introduction", href: "/docs/introduction" },
  { title: "Installation", href: "/docs/installation" },
  { title: "Getting Started", href: "/docs/getting-started" },
  { title: "Features", href: "/docs/features" },
  { title: "API", href: "/docs/api" },
  { title: "FAQ", href: "/docs/faq" },
]

export default function DocSidebar() {
  const pathname = usePathname()

  return (
    <nav className="w-64 bg-gray-100 p-6">
      <h2 className="text-lg font-semibold mb-4">Documentation</h2>
      <ul className="space-y-2">
        {sidebarItems.map((item) => (
          <li key={item.href}>
            <Link
              href={item.href}
              className={`block p-2 rounded ${
                pathname === item.href ? "bg-blue-500 text-white" : "text-gray-700 hover:bg-gray-200"
              }`}
            >
              {item.title}
            </Link>
          </li>
        ))}
      </ul>
    </nav>
  )
}

