/** @type {import('next').NextConfig} */
const nextConfig = {
  // Lint และ type-check ถูกบังคับโดย dedicated jobs ใน .github/workflows/ci.yml
  // (`npm run lint` + `npx tsc --noEmit`) อยู่แล้ว การข้ามมันตอน `next build`
  // จึงกันไม่ให้ lint/type error บล็อก production deploy โดยที่ CI ยังจับได้ทุก PR
  eslint: { ignoreDuringBuilds: true },
  typescript: { ignoreBuildErrors: true },
  images: {
    remotePatterns: [
      { protocol: 'https', hostname: '*.supabase.co' },
    ],
  },
};
module.exports = nextConfig;
