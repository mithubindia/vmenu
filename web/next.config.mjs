/** @type {import('next').NextConfig} */
const nextConfig = {
  output: "export",
  images: {
    unoptimized: true,
  },
  assetPrefix: "/ProxMenux/",
  basePath: "/ProxMenux",
  staticPageGenerationTimeout: 180, // Aumentamos el tiempo de espera a 180 segundos
  webpack: (config, { isServer }) => {
    const path = require("path")
    config.resolve.alias["@guides"] = path.join(__dirname, "..", "guides")
    config.resolve.alias["@changelog"] = path.join(__dirname, "..", "CHANGELOG.md")
    return config
  },
}

module.exports = nextConfig


