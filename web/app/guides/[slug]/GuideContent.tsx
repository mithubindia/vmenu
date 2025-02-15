"use client"

import { useState, useEffect } from "react"
import CopyableCode from "@/components/CopyableCode"

function processContent(content: string) {
  const codeBlockRegex = /<pre><code>([\s\S]*?)<\/code><\/pre>/g
  return content.replace(codeBlockRegex, (match, code) => {
    return `<CopyableCodePlaceholder code="${encodeURIComponent(code)}" />`
  })
}

export default function GuideContent({ content }: { content: string }) {
  const [processedContent, setProcessedContent] = useState<string>("")

  useEffect(() => {
    setProcessedContent(processContent(content))
  }, [content])

  useEffect(() => {
    const placeholders = document.querySelectorAll("CopyableCodePlaceholder")
    placeholders.forEach((placeholder, index) => {
      const code = decodeURIComponent(placeholder.getAttribute("code") || "")
      const codeElement = <CopyableCode key={index} code={code} />
      placeholder.replaceWith(codeElement)
    })
  }, []) // Removed unnecessary dependency: processedContent

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
      dangerouslySetInnerHTML={{ __html: processedContent }}
    />
  )
}
