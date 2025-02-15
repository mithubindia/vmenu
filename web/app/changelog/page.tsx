import fs from "fs"
import path from "path"
import { remark } from "remark"
import html from "remark-html"
import * as gfm from "remark-gfm" // ✅ Asegura la correcta importación de `remark-gfm`
import dynamic from "next/dynamic"
import React from "react"
import parse from "html-react-parser"
import Footer from "@/components/footer"

// 🔹 Importamos `CopyableCode` dinámicamente para evitar problemas de SSR
const CopyableCode = dynamic(() => import("@/components/CopyableCode"), { ssr: false })

async function getChangelogContent() {
  try {
    const changelogPath = path.join(process.cwd(), "..", "CHANGELOG.md")

    if (!fs.existsSync(changelogPath)) {
      console.error("❌ Archivo CHANGELOG.md no encontrado.")
      return "<p class='text-red-600'>Error: No se encontró el archivo CHANGELOG.md</p>"
    }

    const fileContents = fs.readFileSync(changelogPath, "utf8")

    // ✅ Agregamos `remark-gfm` para permitir imágenes, tablas y otros elementos avanzados de Markdown
    const result = await remark()
      .use(gfm.default || gfm) // ✅ Manejo seguro de `remark-gfm`
      .use(html)
      .process(fileContents)

    return result.toString()
  } catch (error) {
    console.error("❌ Error al leer el archivo CHANGELOG.md", error)
    return "<p class='text-red-600'>Error: No se pudo cargar el contenido del changelog.</p>"
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

export default async function ChangelogPage() {
  const changelogContent = await getChangelogContent()
  const cleanedInlineCode = cleanInlineCode(changelogContent) // 🔹 Primero limpiamos código en línea
  const parsedContent = wrapCodeBlocksWithCopyable(cleanedInlineCode) // 🔹 Luego aplicamos JSX a bloques de código

  return (
    <div className="min-h-screen bg-white text-gray-900">
      <div className="container mx-auto px-4 py-16" style={{ maxWidth: "980px" }}> {/* 📌 Ajuste exacto como GitHub */}
        <h1 className="text-4xl font-bold mb-8">Changelog</h1>
        <div className="prose max-w-none text-[16px]">{parsedContent}</div> {/* 📌 Texto ajustado a 16px */}
      </div>
      <Footer />
    </div>
  )
}
