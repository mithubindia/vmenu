/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  images: {
    unoptimized: true,
  },
  assetPrefix: '/ProxMenux/',
  basePath: '/ProxMenux',
  trailingSlash: true,
};

module.exports = nextConfig;
