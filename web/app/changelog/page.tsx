import fs from "fs"
import path from "path"
import { remark } from "remark"
import html from "remark-html"
import gfm from "remark-gfm" // 🔹 Agregamos soporte para imágenes y tablas
import dynamic from "next/dynamic"
import React from "react"
import parse from "html-react-parser"

// 🔹 Importamos `CopyableCode` dinámicamente para evitar problemas de SSR
const CopyableCode = dynamic(() => import("@/components/CopyableCode"), { ssr: false })

async function getGuideContent(slug: string) {
  try {
    const guidePath = path.join(process.cwd(), "..", "guides", `${slug}.md`)
    const fileContents = fs.readFileSync(guidePath, "utf8")

    const result = await remark().use(gfm).use(html).process(fileContents) // 🔹 Se añade `remark-gfm`
    return result.toString()
  } catch (error) {
    console.error(`❌ Error al leer el archivo: ${slug}.md`, error)
    return "<p class='text-red-600'>Error: No se pudo cargar el contenido de la guía.</p>"
  }
}

// 🔹 Limpia las comillas invertidas en fragmentos de código en línea
function cleanInlineCode(content: string) {
  return content.replace(/<code>(.*?)<\/code>/g, (_, codeContent) => {
    return `<code class="bg-gray-200 text-gray-900 px-1 rounded">${codeContent.replace(/^`|`$/g, "")}</code>`
  })
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

export default async function GuidePage({ params }: { params: { slug: string } }) {
  const guideContent = await getGuideContent(params.slug)
  const cleanedInlineCode = cleanInlineCode(guideContent) // 🔹 Primero limpiamos código en línea
  const parsedContent = wrapCodeBlocksWithCopyable(cleanedInlineCode) // 🔹 Luego aplicamos JSX a bloques de código

  return (
    <div className="min-h-screen bg-white text-gray-900">
      <div className="container mx-auto px-4 py-16 max-w-4xl">
        <div className="prose max-w-none text-[16px]">{parsedContent}</div> {/* 📌 Ahora con imágenes */}
      </div>
    </div>
  )
}
