import {
  mockPersonnel, mockOrgDashboard, mockRetirementTimeline,
  mockVacancyAnalysis, mockHighRiskPersonnel, mockActiveAlerts,
  mockWorkforceComposition, mockOrganizations,
} from './data'

class MockQueryBuilder {
  private table: string
  private filters: Record<string, any> = {}
  private orderByField: string | null = null
  private orderByAsc = true
  private limitCount: number | null = null
  private singleMode = false

  constructor(table: string) { this.table = table }
  select(fields: string = '*') { return this }
  eq(field: string, value: any) { this.filters[field] = value; return this }
  order(field: string, opts?: { ascending?: boolean }) { this.orderByField = field; this.orderByAsc = opts?.ascending ?? true; return this }
  limit(count: number) { this.limitCount = count; return this }
  single() { this.singleMode = true; return this }

  async then(resolve: (value: any) => void) {
    let result = this.getData()
    for (const [field, value] of Object.entries(this.filters)) {
      result = result.filter((item: any) => item[field] === value)
    }
    if (this.orderByField) {
      const field = this.orderByField
      const asc = this.orderByAsc
      result = [...result].sort((a: any, b: any) => {
        const va = a[field] ?? 0
        const vb = b[field] ?? 0
        return asc ? va - vb : vb - va
      })
    }
    if (this.limitCount) result = result.slice(0, this.limitCount)
    resolve({ data: this.singleMode ? (result[0] || null) : result, error: null })
  }

  private getData(): any[] {
    const map: Record<string, any[]> = {
      'v_personnel_overview': mockPersonnel,
      'v_org_dashboard': mockOrgDashboard,
      'v_retirement_timeline': mockRetirementTimeline,
      'v_vacancy_analysis': mockVacancyAnalysis,
      'v_high_risk_personnel': mockHighRiskPersonnel,
      'v_active_alerts': mockActiveAlerts,
      'v_workforce_composition': mockWorkforceComposition,
      'organizations': mockOrganizations,
      'personnel': mockPersonnel,
      'alerts': mockActiveAlerts,
      'profiles': [{ id: 'user-1', role: 'admin', department_id: 'org-5', first_name_th: 'Admin', last_name_th: 'User', language: 'th', created_at: '2024-01-01' }],
    }
    return map[this.table] || []
  }
}

class MockSupabaseClient {
  auth = {
    async getUser() { return { data: { user: { id: 'user-1', email: 'admin@moj.go.th' } }, error: null } },
    async signInWithPassword({ email }: { email: string; password: string }) { return { data: { user: { id: 'user-1', email } }, error: null } },
    async signOut() { return { error: null } },
    async exchangeCodeForSession() { return { error: null } },
  }
  channel() { return { on: () => ({ subscribe: () => ({}) }), subscribe: () => ({}) } }
  removeChannel() {}
  from(table: string) { return new MockQueryBuilder(table) }
}

let mockClient: MockSupabaseClient | null = null
export function createMockClient() { if (!mockClient) mockClient = new MockSupabaseClient(); return mockClient }
export function createMockServerClient() { return new MockSupabaseClient() }
