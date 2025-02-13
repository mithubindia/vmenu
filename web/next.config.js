/** @type {import('next').NextConfig} */
const nextConfig = {
  output: "export",
  images: {
    unoptimized: true,
  },
  assetPrefix: "/ProxMenux/",
  basePath: "/ProxMenux",
  distDir: "out",
}

module.exports = nextConfig

