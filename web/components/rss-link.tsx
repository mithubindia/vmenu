"use client"

import { Rss, Copy, Check } from "lucide-react"
import Link from "next/link"
import { useState } from "react"

export default function RSSLink() {
  const [copied, setCopied] = useState(false)
  const rssUrl = `${typeof window !== "undefined" ? window.location.origin : ""}/api/rss`

  const copyToClipboard = async () => {
    try {
      await navigator.clipboard.writeText(rssUrl)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    } catch (err) {
      console.error("Failed to copy: ", err)
    }
  }

  return (
    <div className="mb-8 p-4 bg-orange-50 border border-orange-200 rounded-lg">
      <div className="flex items-center justify-between">
        <div className="flex-1">
          <h3 className="text-lg font-semibold text-orange-900 mb-1">Stay Updated!</h3>
          <p className="text-orange-700 text-sm mb-3">
            Subscribe to our RSS feed to get notified of new changes. Copy the URL below or click the RSS button.
          </p>

          <div className="flex items-center gap-2 text-xs">
            <code className="bg-orange-100 text-orange-800 px-2 py-1 rounded flex-1 min-w-0 truncate">{rssUrl}</code>
            <button
              onClick={copyToClipboard}
              className="flex items-center gap-1 px-2 py-1 bg-gray-600 text-white rounded hover:bg-gray-700 transition-colors whitespace-nowrap"
              title="Copy RSS URL"
            >
              {copied ? <Check className="h-3 w-3" /> : <Copy className="h-3 w-3" />}
              {copied ? "Copied!" : "Copy"}
            </button>
          </div>
        </div>

        <Link
          href="/api/rss"
          className="ml-4 flex items-center space-x-2 px-4 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 transition-colors"
          target="_blank"
          rel="noopener noreferrer"
          title="Open RSS Feed"
        >
          <Rss className="h-4 w-4" />
          <span>RSS</span>
        </Link>
      </div>
    </div>
  )
}
