"use client"

import type React from "react"
import CopyableCode from "@/components/CopyableCode"

function processContent(content: string): React.ReactNode[] {
  const parts = content.split(/(```[\s\S]*?```|`[^`\n]+`)/g)
  return parts.map((part, index) => {
    if (part.startsWith("```") && part.endsWith("```")) {
      const code = part.slice(3, -3).trim()
      return <CopyableCode key={index} code={code} />
    } else if (part.startsWith("`") && part.endsWith("`")) {
      return (
        <code key={index} className="bg-gray-100 text-gray-800 px-1 rounded">
          {part.slice(1, -1)}
        </code>
      )
    }
    return <span key={index} dangerouslySetInnerHTML={{ __html: part }} />
  })
}

export default function GuideContent({ content }: { content: string }) {
  const processedContent = processContent(content)

  return (
    <div
      className="prose max-w-none text-gray-900
      [&>h1]:text-3xl [&>h1]:font-bold [&>h1]:mb-6 [&>h1]:text-gray-900
      [&>h2]:text-2xl [&>h2]:font-semibold [&>h2]:mt-8 [&>h2]:mb-4 [&>h2]:text-gray-900
      [&>h3]:text-xl [&>h3]:font-semibold [&>h3]:mt-6 [&>h3]:mb-3 [&>h3]:text-gray-900
      [&>p]:mb-4 [&>p]:text-gray-700
      [&>ul]:list-disc [&>ul]:pl-5 [&>ul]:mb-4
      [&>ul>li]:text-gray-700 [&>ul>li]:mb-2
      [&>ol]:list-decimal [&>ol]:pl-5 [&>ol]:mb-4
      [&>ol>li]:text-gray-700 [&>ol>li]:mb-2
      [&>a]:text-blue-600 [&>a:hover]:underline
      [&>strong]:font-bold [&>strong]:text-gray-900"
    >
      {processedContent}
    </div>
  )
}

