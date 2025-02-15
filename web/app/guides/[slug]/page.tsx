import fs from "fs"
import path from "path"
import { remark } from "remark"
import html from "remark-html"
import dynamic from "next/dynamic"
import React from "react"
import parse from "html-react-parser"

// Importamos `CopyableCode` de forma dinámica para evitar problemas de SSR
const CopyableCode = dynamic(() => import("@/components/CopyableCode"), { ssr: false })

async function getGuideContent(slug: string) {
  const guidePath = path.join(process.cwd(), "..", "guides", `${slug}.md`)
  const fileContents = fs.readFileSync(guidePath, "utf8")

  const result = await remark().use(html).process(fileContents)
  return result.toString()
}

export async function generateStaticParams() {
  const guideFiles = fs.readdirSync(path.join(process.cwd(), "..", "guides"))
  return guideFiles.map((file) => ({
    slug: file.replace(/\.md$/, ""),
  }))
}

// 🔹 Envuelve los bloques de código en <CopyableCode />
function wrapCodeBlocksWithCopyable(content: string) {
  return parse(content, {
    replace: (domNode: any) => {
      if (domNode.name === "pre" && domNode.children.length > 0) {
        const codeElement = domNode.children.find((child: any) => child.name === "code")
        if (codeElement) {
          const codeContent = codeElement.children[0]?.data?.trim() || ""
          return <CopyableCode code={codeContent} />
        }
      }
    }
  })
}

// 🔹 Elimina las comillas de los fragmentos de código en línea dentro de <code>
function cleanInlineCode(content: string) {
  return parse(content, {
    replace: (domNode: any) => {
      if (domNode.name === "code" && domNode.children.length > 0) {
        const codeContent = domNode.children[0].data?.trim().replace(/^`|`$/g, "") || "" // Elimina comillas inversas
        return <code className="bg-gray-200 text-gray-900 px-1 rounded">{codeContent}</code>
      }
    }
  })
}

export default async function GuidePage({ params }: { params: { slug: string } }) {
  const guideContent = await getGuideContent(params.slug)
  const contentWithCodeBlocks = wrapCodeBlocksWithCopyable(guideContent)
  const finalContent = cleanInlineCode(contentWithCodeBlocks) // 🔹 Limpiamos código en línea

  return (
    <div className="min-h-screen bg-white text-gray-900">
      <div className="container mx-auto px-4 py-16 max-w-3xl">
        <div className="prose max-w-none">{finalContent}</div>
      </div>
    </div>
  )
}
