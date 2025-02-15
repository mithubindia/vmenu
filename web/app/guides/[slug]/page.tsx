import fs from "fs"
import path from "path"
import { remark } from "remark"
import html from "remark-html"
import * as gfm from "remark-gfm"
import dynamic from "next/dynamic"
import React from "react"
import parse from "html-react-parser"

const CopyableCode = dynamic(() => import("@/components/CopyableCode"), { ssr: false })

const guidesDirectory = path.join(process.cwd(), "..", "guides")

// 🔹 Función para buscar archivos Markdown dentro de subdirectorios
function findMarkdownFiles(dir: string, basePath = "") {
  let files: { slug: string; path: string }[] = []

  fs.readdirSync(dir, { withFileTypes: true }).forEach((entry) => {
    const fullPath = path.join(dir, entry.name)
    const relativePath = path.join(basePath, entry.name)

    if (entry.isDirectory()) {
      files = files.concat(findMarkdownFiles(fullPath, relativePath))
    } else if (entry.isFile() && entry.name.endsWith(".md")) {
      files.push({
        slug: relativePath.replace(/\.md$/, ""), // 🔹 Quitamos la extensión .md
        path: fullPath,
      })
    }
  })

  return files
}

async function getGuideContent(slug: string) {
  try {
    const markdownFiles = findMarkdownFiles(guidesDirectory)
    const guideFile = markdownFiles.find((file) => file.slug === slug)

    if (!guideFile) {
      console.error(`❌ No se encontró la guía: ${slug}`)
      return "<p class='text-red-600'>Error: No se encontró la guía solicitada.</p>"
    }

    const fileContents = fs.readFileSync(guideFile.path, "utf8")

    const result = await remark()
      .use(gfm.default || gfm)
      .use(html)
      .process(fileContents)

    return result.toString()
  } catch (error) {
    console.error(`❌ Error al leer la guía ${slug}`, error)
    return "<p class='text-red-600'>Error: No se pudo cargar la guía.</p>"
  }
}

// 🔹 Generamos rutas estáticas incluyendo subdirectorios
export async function generateStaticParams() {
  try {
    const markdownFiles = findMarkdownFiles(guidesDirectory)
    return markdownFiles.map((file) => ({ slug: file.slug }))
  } catch (error) {
    console.error("❌ Error al generar las rutas estáticas para guides:", error)
    return []
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

export default async function GuidePage({ params }: { params: { slug: string } }) {
  const guideContent = await getGuideContent(params.slug)
  const cleanedInlineCode = cleanInlineCode(guideContent)
  const parsedContent = wrapCodeBlocksWithCopyable(cleanedInlineCode)

  return (
    <div className="min-h-screen bg-white text-gray-900">
      <div className="container mx-auto px-4 py-16" style={{ maxWidth: "980px" }}>
        <div className="prose max-w-none text-[16px]">{parsedContent}</div>
      </div>
    </div>
  )
}
