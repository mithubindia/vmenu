import { Rss } from "lucide-react"
import Link from "next/link"

export default function RSSLink() {
  return (
    <div className="flex items-center justify-between mb-8 p-4 bg-orange-50 border border-orange-200 rounded-lg">
      <div>
        <h3 className="text-lg font-semibold text-orange-900">Stay Updated!</h3>
        <p className="text-orange-700">Subscribe to our RSS feed to get notified of new changes.</p>
      </div>
      <Link
        href="/api/rss"
        className="flex items-center space-x-2 px-4 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 transition-colors"
        target="_blank"
        rel="noopener noreferrer"
      >
        <Rss className="h-4 w-4" />
        <span>RSS Feed</span>
      </Link>
    </div>
  )
}
