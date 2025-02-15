import fs from "fs"
import path from "path"
import { remark } from "remark"
import html from "remark-html"
import * as gfm from "remark-gfm"
import matter from "gray-matter"
import dynamic from "next/dynamic"
import React from "react"
import parse from "html-react-parser"

const CopyableCode = dynamic(() => import("@/components/CopyableCode"), { ssr: false })

const guidesDirectory = path.join(process.cwd(), "..", "guides")

// 🔹 Encuentra todos los archivos Markdown dentro de `/guides`
function getMarkdownFiles() {
  return fs
    .readdirSync(guidesDirectory)
    .filter((file) => file.endsWith(".md"))
    .map((file) => ({
      slug: file.replace(/\.md$/, ""), // 🔹 Quitamos la extensión .md
      path: path.join(guidesDirectory, file),
    }))
}

// 🔹 Obtiene el contenido de una guía específica
async function getGuideContent(slug: string) {
  try {
    const markdownFiles = getMarkdownFiles()
    const guideFile = markdownFiles.find((file) => file.slug === slug)

    if (!guideFile) {
      console.error(`❌ No se encontró la guía: ${slug}`)
      return { content: "<p class='text-red-600'>Error: No se encontró la guía solicitada.</p>", metadata: null }
    }

    const fileContents = fs.readFileSync(guideFile.path, "utf8")
    const { content, data } = matter(fileContents) // 🔹 Extrae metadata y contenido del `.md`

    // 🔹 Convertimos el Markdown a HTML con soporte para imágenes y tablas
    const result = await remark()
      .use(gfm.default || gfm)
      .use(html)
      .process(content)

    return { content: result.toString(), metadata: data }
  } catch (error) {
    console.error(`❌ Error al leer la guía ${slug}`, error)
    return { content: "<p class='text-red-600'>Error: No se pudo cargar la guía.</p>", metadata: null }
  }
}

// 🔹 Generamos rutas estáticas asegurando que Next.js las acepte
export async function generateStaticParams() {
  try {
    const markdownFiles = getMarkdownFiles()
    return markdownFiles.map((file) => ({ slug: file.slug }))
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

// 🔹 Envuelve los bloques de código en `<CopyableCode />`
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

// 🔹 Página principal de cada guía
export default async function GuidePage({ params }: { params: { slug: string } }) {
  const { content, metadata } = await getGuideContent(params.slug)
  const cleanedInlineCode = cleanInlineCode(content)
  const parsedContent = wrapCodeBlocksWithCopyable(cleanedInlineCode)

  return (
    <div className="min-h-screen bg-white text-gray-900">
      <div className="container mx-auto px-4 py-16" style={{ maxWidth: "980px" }}>
        {metadata?.title && <h1 className="text-4xl font-bold mb-4">{metadata.title}</h1>}
        {metadata?.description && <p className="text-lg text-gray-700 mb-8">{metadata.description}</p>}
        <div className="prose max-w-none text-[16px]">{parsedContent}</div>
      </div>
    </div>
  )
}
