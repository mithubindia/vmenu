import fs from "fs"
import path from "path"

async function getChangelog() {
  const changelogPath = path.join(process.cwd(), "..", "CHANGELOG.md")
  try {
    const fileContents = fs.readFileSync(changelogPath, "utf8")

    // Asegurar que el contenido no tiene espacios innecesarios
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
        {/* Eliminamos clases innecesarias para evitar que el HTML se vea como texto */}
        <div
          className="max-w-none bg-gray-100 p-4 border border-gray-300 rounded-md"
          style={{ whiteSpace: "normal" }} // Esto evita que el HTML se muestre como texto plano
          dangerouslySetInnerHTML={{ __html: changelogContent }} // Renderiza el HTML correctamente
        />
      </div>
    </div>
  )
}
