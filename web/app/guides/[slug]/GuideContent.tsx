"use client"

import type React from "react"
import { useState, useEffect } from "react"
import CopyableCode from "@/components/CopyableCode"

function processContent(content: string): React.ReactNode[] {
  const parts = content.split(/(```[\s\S]*?```)/g)
  return parts.map((part, index) => {
    if (part.startsWith("```") && part.endsWith("```")) {
      const code = part.slice(3, -3).trim()
      return <CopyableCode key={index} code={code} />
    }
    return <div key={index} dangerouslySetInnerHTML={{ __html: part }} />
  })
}

export default function GuideContent({ content }: { content: string }) {
  const [processedContent, setProcessedContent] = useState<React.ReactNode[]>([])

  useEffect(() => {
    setProcessedContent(processContent(content))
  }, [content])

  return (
    <div
      className="prose prose-gray max-w-none
      [&>h1]:text-3xl [&>h1]:sm:text-4xl [&>h1]:font-bold [&>h1]:mb-6
      [&>h2]:text-2xl [&>h2]:font-semibold [&>h2]:mt-8 [&>h2]:mb-4
      [&>h3]:text-xl [&>h3]:font-medium [&>h3]:mt-6 [&>h3]:mb-3
      [&>p]:mb-4 [&>p]:text-gray-600
      [&>ul]:list-disc [&>ul]:pl-5 [&>ul]:mb-4
      [&>ul>li]:text-gray-600 [&>ul>li]:mb-2
      [&>ol]:list-decimal [&>ol]:pl-5 [&>ol]:mb-4
      [&>ol>li]:text-gray-600 [&>ol>li]:mb-2
      [&>a]:text-blue-600 [&>a:hover]:underline"
    >
      {processedContent}
    </div>
  )
}

