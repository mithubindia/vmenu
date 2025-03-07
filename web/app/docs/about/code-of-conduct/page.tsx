import fs from "fs"
import path from "path"
import { remark } from "remark"
import html from "remark-html"
import * as gfm from "remark-gfm"
import dynamic from "next/dynamic"
import React from "react"
import parse from "html-react-parser"
import Footer from "@/components/footer"

const CopyableCode = dynamic(() => import("@/components/CopyableCode"), { ssr: false })

async function getCodeOfConductContent() {
  try {
    const codeOfConductPath = path.join(process.cwd(), "..", "CODE_OF_CONDUCT.md")

    if (!fs.existsSync(codeOfConductPath)) {
      console.error("❌ Archivo CODE_OF_CONDUCT.md no encontrado.")
      return "<p class='text-red-600'>Error: No se encontró el archivo CODE_OF_CONDUCT.md</p>"
    }

    const fileContents = fs.readFileSync(codeOfConductPath, "utf8")

    const result = await remark()
      .use(gfm.default || gfm)
      .use(html)
      .process(fileContents)

    return result.toString()
  } catch (error) {
    console.error("❌ Error al leer el archivo CODE_OF_CONDUCT.md", error)
    return "<p class='text-red-600'>Error: No se pudo cargar el contenido del Código de Conducta.</p>"
  }
}

function cleanInlineCode(content: string) {
  return content.replace(/<code>(.*?)<\/code>/g, (_, codeContent) => {
    return `<code class="bg-gray-200 text-gray-900 px-1 rounded">${codeContent.replace(/^`|`$/g, "")}</code>`
  })
}

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

export default async function CodeOfConductPage() {
  const codeOfConductContent = await getCodeOfConductContent()
  const cleanedInlineCode = cleanInlineCode(codeOfConductContent)
  const parsedContent = wrapCodeBlocksWithCopyable(cleanedInlineCode)

  return (
    <div className="min-h-screen bg-white text-gray-900">
      <div className="container mx-auto px-4 py-16" style={{ maxWidth: "980px" }}>
        <h1 className="text-4xl font-bold mb-8">Code of Conduct</h1>
        <div className="prose max-w-none text-[16px]">{parsedContent}</div>
      </div>
      <Footer />
    </div>
  )
}