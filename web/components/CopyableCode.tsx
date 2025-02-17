"use client"

import type React from "react"
import { useState } from "react"
import { Copy, Check } from "lucide-react"
import { cn } from "@/lib/utils"

interface CopyableCodeProps {
  code: string
  language?: string
  className?: string
}

const CopyableCode: React.FC<CopyableCodeProps> = ({ code, language, className }) => {
  const [isCopied, setIsCopied] = useState(false)

  const copyToClipboard = async () => {
    try {
      await navigator.clipboard.writeText(decodeURIComponent(code))
      setIsCopied(true)
      setTimeout(() => setIsCopied(false), 2000)
    } catch (err) {
      console.error("Failed to copy text: ", err)
    }
  }

  return (
    <div className={cn("relative w-full", className)}>
      <pre
        className={cn(
          "bg-gray-100 p-2 sm:p-3 md:p-4 rounded-md overflow-x-auto",
          "text-xs sm:text-sm md:text-base",
          "max-w-full",
          language ? `language-${language}` : "",
        )}
      >
        <code className="whitespace-pre">{decodeURIComponent(code)}</code>
      </pre>
      <button
        onClick={copyToClipboard}
        className="absolute top-1 right-1 sm:top-2 sm:right-2 p-1 sm:p-2 bg-white rounded-md shadow-sm hover:bg-gray-100 transition-colors"
        aria-label="Copy code"
      >
        {isCopied ? (
          <Check className="h-3 w-3 sm:h-4 sm:w-4 text-green-500" />
        ) : (
          <Copy className="h-3 w-3 sm:h-4 sm:w-4 text-gray-500" />
        )}
      </button>
    </div>
  )
}

export default CopyableCode
