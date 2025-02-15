"use client"

import type React from "react"
import { useState } from "react"
import { Copy, Check } from "lucide-react"

interface CopyableCodeProps {
  code: string
}

const CopyableCode: React.FC<CopyableCodeProps> = ({ code }) => {
  const [isCopied, setIsCopied] = useState(false)

  const copyToClipboard = async () => {
    try {
      await navigator.clipboard.writeText(code)
      setIsCopied(true)
      setTimeout(() => setIsCopied(false), 2000)
    } catch (err) {
      console.error("Failed to copy text: ", err)
    }
  }

  return (
    <div className="relative my-4">
      <pre className="bg-gray-100 text-gray-800 p-4 rounded-md overflow-x-auto">
        <code className="text-sm">{code}</code>
      </pre>
      <button
        onClick={copyToClipboard}
        className="absolute top-2 right-2 p-2 bg-white rounded-md shadow-sm hover:bg-gray-200 transition-colors"
        aria-label="Copy to clipboard"
      >
        {isCopied ? <Check className="h-5 w-5 text-green-500" /> : <Copy className="h-5 w-5 text-gray-500" />}
      </button>
    </div>
  )
}

export default CopyableCode


