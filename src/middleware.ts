import { type NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  // In mock mode, no auth check
  if (process.env.USE_MOCK === 'true') return undefined
  return undefined
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|.*\.(?:svg|png|jpg|jpeg|gif|webp)$).*)'],
}
