import fs from "fs"
import path from "path"
import { remark } from "remark"
import html from "remark-html"
import * as gfm from "remark-gfm" // ✅ Asegura la correcta importación de `remark-gfm`
import dynamic from "next/dynamic"
import React from "react"
import parse from "html-react-parser"

// 🔹 Importamos `CopyableCode` dinámicamente para evitar problemas de SSR
const CopyableCode = dynamic(() => import("@/components/CopyableCode"), { ssr: false })

const guidesDirectory = path.join(process.cwd(), "..", "guides")

async function getGuideContent(slug: string) {
  try {
    const guidePath = path.join(guidesDirectory, `${slug}.md`)

    if (!fs.existsSync(guidePath)) {
      console.error(`❌ Archivo ${slug}.md no encontrado en guides/`)
      return "<p class='text-red-600'>Error: No se encontró la guía solicitada.</p>"
    }

    const fileContents = fs.readFileSync(guidePath, "utf8")

    // ✅ Agregamos `remark-gfm` para permitir imágenes, tablas y otros elementos avanzados de Markdown
    const result = await remark()
      .use(gfm.default || gfm) // ✅ Manejo seguro de `remark-gfm`
      .use(html)
      .process(fileContents)

    return result.toString()
  } catch (error) {
    console.error(`❌ Error al leer la guía ${slug}.md`, error)
    return "<p class='text-red-600'>Error: No se pudo cargar la guía.</p>"
  }
}

// 🔹 Asegura que `generateStaticParams()` esté presente para `output: export`
export async function generateStaticParams() {
  try {
    if (fs.existsSync(guidesDirectory)) {
      const guideFiles = fs.readdirSync(guidesDirectory)
      return guideFiles.map((file) => ({
        slug: file.replace(/\.md$/, ""),
      }))
    } else {
      console.warn("⚠ No se encontró el directorio guides/. No se generarán rutas estáticas.")
      return []
    }
  } catch (error) {
    console.error("❌ Error al generar las rutas estáticas para guides:", error)
    return []
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
      <div className="container mx-auto px-4 py-16" style={{ maxWidth: "980px" }}> {/* 📌 Ajuste exacto como GitHub */}
        <div className="prose max-w-none text-[16px]">{parsedContent}</div> {/* 📌 Texto ajustado a 16px */}
      </div>
    </div>
  )
}
