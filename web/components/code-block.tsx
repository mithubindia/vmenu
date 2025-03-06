"use client"

interface CodeBlockProps {
  code: string
}

export default function CodeBlock({ code }: CodeBlockProps) {
  return (
    <div className="relative bg-gray-100 text-gray-800 p-4 rounded-md overflow-x-auto mb-6 border border-gray-300">
      <pre className="whitespace-pre-wrap text-sm">{code}</pre>
      <button
        className="absolute top-2 right-2 p-1 bg-white rounded-md shadow-sm hover:bg-gray-200 transition-colors"
        onClick={() => {
          navigator.clipboard.writeText(code)
          // You could add a toast notification here
        }}
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          className="h-5 w-5 text-gray-600"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"
          />
        </svg>
      </button>
    </div>
  )
}

