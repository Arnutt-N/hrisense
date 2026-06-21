/**
 * Mask a Thai national ID (เลขบัตรประชาชน) for display, showing only the last
 * 4 digits. Defense-in-depth against shoulder-surfing / screenshots — the
 * complete fix is role-based masking in the DB view so the full value never
 * reaches the client (see docs/SECURITY_AUDIT.md H1).
 *
 * @example maskCitizenId('1234567890123') // 'X-XXXX-XXXXX-X0-123' -> '•••• •••• •0123'
 */
export function maskCitizenId(id?: string | null): string {
  if (!id) return '—'
  const digits = id.replace(/\D/g, '')
  if (digits.length <= 4) return '••••'
  return `•••• •••• •${digits.slice(-4)}`
}
