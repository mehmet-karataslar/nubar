/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'cdn.nubar.app',
        pathname: '/**',
      },
    ],
  },
};

module.exports = nextConfig;
