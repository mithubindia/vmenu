/** @type {import('next').NextConfig} */
const nextConfig = {
  output: "export", // Forces static export for GitHub Pages
  trailingSlash: true, // Fixes route issues
  images: {
    unoptimized: true, // Fixes image loading issues on GitHub Pages
  },
  assetPrefix: process.env.NODE_ENV === "production" ? "/ProxMenux" : "",
}

module.exports = nextConfig
