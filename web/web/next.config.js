const path = require("path")

/** @type {import('next').NextConfig} */
const nextConfig = {
  output: "export",
  images: {
    unoptimized: true,
  },
  assetPrefix: "/ProxMenux/",
  basePath: "/ProxMenux",
  webpack: (config, { isServer }) => {
    config.resolve.alias["@guides"] = path.join(__dirname, "..", "guides")
    config.resolve.alias["@changelog"] = path.join(__dirname, "..", "CHANGELOG.md")
    return config
  },
}

module.exports = nextConfig

