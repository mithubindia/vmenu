import fs from "fs"
import path from "path"

async function getChangelog() {
  const changelogPath = path.join(process.cwd(), "..", "CHANGELOG.md")
  try {
    const fileContents = fs.readFileSync(changelogPath, "utf8")

    // Asegurar que el contenido HTML no tiene espacios innecesarios
    return fileContents.trim()
  } catch (error) {
    console.error("Error reading changelog file:", error)
    return "<p>Changelog content not found.</p>"
  }
}

export default async function ChangelogPage() {
  const changelogContent = await getChangelog()

  return (
    <div className="bg-white text-gray-900 min-h-screen">
      <div className="container mx-auto px-4 py-16 max-w-4xl">
        <h1 className="text-4xl font-bold mb-8">Changelog</h1>
        {/* Eliminamos el recuadro, bordes y cualquier estilo que fuerce texto plano */}
        <div
          className="max-w-none"
          style={{
            whiteSpace: "normal", // Asegura que el HTML se renderice correctamente
            backgroundColor: "transparent", // Elimina cualquier fondo gris
            border: "none", // Elimina el borde del recuadro
            padding: "0", // Evita cualquier padding adicional
          }}
          dangerouslySetInnerHTML={{ __html: changelogContent }} // Renderiza HTML puro
        />
      </div>
    </div>
  )
}
