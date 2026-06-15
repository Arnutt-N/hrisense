import { createBrowserClient } from '@supabase/ssr'
import type { Database } from '@/lib/types/database'
import { createMockClient } from '@/lib/mock/client'

export function createClient() {
  if (process.env.NEXT_PUBLIC_USE_MOCK === 'true') {
    return createMockClient() as any
  }

  return createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
