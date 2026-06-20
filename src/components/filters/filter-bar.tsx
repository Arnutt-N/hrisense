'use client'

import { useState, useEffect, useCallback } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { cn } from '@/lib/utils/cn'
import { Filter, X, Search } from 'lucide-react'

interface FilterOption {
  value: string
  label: string
}

interface FilterConfig {
  id: string
  label: string
  type: 'select' | 'search' | 'date' | 'multiselect'
  options?: FilterOption[]
  placeholder?: string
  paramKey?: string
}

interface FilterBarProps {
  filters: FilterConfig[]
  className?: string
}

export function FilterBar({ filters, className }: FilterBarProps) {
  const router = useRouter()
  const searchParams = useSearchParams()
  const [isOpen, setIsOpen] = useState(false)
  const [filterValues, setFilterValues] = useState<Record<string, string | string[]>>({})

  const closePanel = useCallback(() => setIsOpen(false), [])

  // Close on Escape when the panel is open
  useEffect(() => {
    if (!isOpen) return
    const onKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') closePanel()
    }
    document.addEventListener('keydown', onKeyDown)
    return () => document.removeEventListener('keydown', onKeyDown)
  }, [isOpen, closePanel])

  // Initialize filter values from URL params
  useEffect(() => {
    const initialValues: Record<string, string | string[]> = {}
    filters.forEach(filter => {
      const paramKey = filter.paramKey || filter.id
      const value = searchParams.get(paramKey)
      if (value) {
        if (filter.type === 'multiselect') {
          initialValues[filter.id] = value.split(',')
        } else {
          initialValues[filter.id] = value
        }
      }
    })
    setFilterValues(initialValues)
  }, [searchParams, filters])

  const handleFilterChange = (id: string, value: string | string[]) => {
    setFilterValues(prev => ({ ...prev, [id]: value }))
  }

  const buildQueryString = (values: Record<string, string | string[]>): string => {
    const params = new URLSearchParams(searchParams.toString())

    filters.forEach(filter => {
      const paramKey = filter.paramKey || filter.id
      const value = values[filter.id]

      if (value === undefined || value === '' || (Array.isArray(value) && value.length === 0)) {
        params.delete(paramKey)
      } else if (Array.isArray(value)) {
        params.set(paramKey, value.join(','))
      } else {
        params.set(paramKey, value)
      }
    })

    const queryString = params.toString()
    return queryString ? `?${queryString}` : ''
  }

  const handleApply = () => {
    const queryString = buildQueryString(filterValues)
    router.push(`${window.location.pathname}${queryString}`)
    setIsOpen(false)
  }

  const handleReset = () => {
    setFilterValues({})
    // Remove all filter params from URL
    const params = new URLSearchParams(searchParams.toString())
    filters.forEach(filter => {
      const paramKey = filter.paramKey || filter.id
      params.delete(paramKey)
    })
    const queryString = params.toString()
    router.push(`${window.location.pathname}${queryString ? `?${queryString}` : ''}`)
    setIsOpen(false)
  }

  const activeFilterCount = Object.keys(filterValues).filter(key => {
    const value = filterValues[key]
    if (Array.isArray(value)) return value.length > 0
    return value !== '' && value !== undefined
  }).length

  return (
    <div className={cn('relative', className)}>
      {/* Filter Toggle Button */}
      <button
        type="button"
        onClick={() => setIsOpen(!isOpen)}
        aria-expanded={isOpen}
        aria-haspopup="true"
        aria-controls="filter-panel"
        className={cn(
          'flex items-center gap-2 px-3 py-2 rounded-lg text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring',
          activeFilterCount > 0
            ? 'bg-primary/10 text-primary border border-primary/20'
            : 'bg-muted text-muted-foreground hover:bg-muted/80 border border-transparent',
        )}
      >
        <Filter className="w-4 h-4" />
        <span>ตัวกรอง</span>
        {activeFilterCount > 0 && (
          <span className="flex items-center justify-center w-5 h-5 rounded-full bg-primary text-white text-xs font-bold" aria-hidden="true">
            {activeFilterCount}
          </span>
        )}
      </button>

      {/* Filter Panel */}
      {isOpen && (
        <>
          {/* Backdrop */}
          <div
            className="fixed inset-0 z-40 bg-black/20 backdrop-blur-sm"
            onClick={closePanel}
            aria-hidden="true"
          />

          {/* Panel */}
          <div
            id="filter-panel"
            role="group"
            aria-label="ตัวกรองข้อมูล"
            className="absolute right-0 top-full mt-2 z-50 w-80 bg-card border rounded-lg shadow-lg p-4 space-y-4"
          >
            <div className="flex items-center justify-between">
              <h3 className="font-semibold text-sm">ตัวกรองข้อมูล</h3>
              <button
                type="button"
                onClick={closePanel}
                className="p-1 rounded hover:bg-muted transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
                aria-label="ปิดตัวกรอง"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="space-y-3 max-h-96 overflow-y-auto">
              {filters.map(filter => {
                const fieldId = `filter-${filter.id}`
                return (
                <div key={filter.id} className="space-y-1.5">
                  <label htmlFor={fieldId} className="text-xs font-medium text-muted-foreground">
                    {filter.label}
                  </label>
                  {filter.type === 'select' && (
                    <select
                      id={fieldId}
                      value={(filterValues[filter.id] as string) || ''}
                      onChange={(e) => handleFilterChange(filter.id, e.target.value)}
                      className="w-full px-3 py-2 rounded-lg border bg-card text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
                    >
                      <option value="">ทั้งหมด</option>
                      {filter.options?.map(opt => (
                        <option key={opt.value} value={opt.value}>
                          {opt.label}
                        </option>
                      ))}
                    </select>
                  )}
                  {filter.type === 'search' && (
                    <div className="relative">
                      <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" aria-hidden="true" />
                      <input
                        id={fieldId}
                        type="text"
                        value={(filterValues[filter.id] as string) || ''}
                        onChange={(e) => handleFilterChange(filter.id, e.target.value)}
                        placeholder={filter.placeholder || 'ค้นหา...'}
                        className="w-full pl-9 pr-3 py-2 rounded-lg border bg-card text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
                      />
                    </div>
                  )}
                  {filter.type === 'date' && (
                    <input
                      id={fieldId}
                      type="date"
                      value={(filterValues[filter.id] as string) || ''}
                      onChange={(e) => handleFilterChange(filter.id, e.target.value)}
                      className="w-full px-3 py-2 rounded-lg border bg-card text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
                    />
                  )}
                  {filter.type === 'multiselect' && (
                    <div
                      id={fieldId}
                      role="group"
                      aria-label={filter.label}
                      className="flex flex-wrap gap-2"
                    >
                      {filter.options?.map(opt => {
                        const currentValues = (filterValues[filter.id] as string[]) || []
                        const isSelected = currentValues.includes(opt.value)
                        return (
                          <button
                            key={opt.value}
                            type="button"
                            aria-pressed={isSelected}
                            onClick={() => {
                              const newValues = isSelected
                                ? currentValues.filter(v => v !== opt.value)
                                : [...currentValues, opt.value]
                              handleFilterChange(filter.id, newValues)
                            }}
                            className={cn(
                              'px-3 py-1.5 rounded-lg text-xs font-medium transition-colors border focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring',
                              isSelected
                                ? 'bg-primary text-primary-foreground border-primary'
                                : 'bg-card text-muted-foreground border-border hover:bg-muted',
                            )}
                          >
                            {opt.label}
                          </button>
                        )
                      })}
                    </div>
                  )}
                </div>
                )
              })}
            </div>

            <div className="flex gap-2 pt-2 border-t">
              <button
                type="button"
                onClick={handleReset}
                className="flex-1 px-3 py-2 rounded-lg text-sm font-medium text-muted-foreground bg-muted hover:bg-muted/80 transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
              >
                ล้างตัวกรอง
              </button>
              <button
                type="button"
                onClick={handleApply}
                className="flex-1 px-3 py-2 rounded-lg text-sm font-medium text-primary-foreground bg-primary hover:bg-primary/90 transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
              >
                ใช้ตัวกรอง
              </button>
            </div>
          </div>
        </>
      )}
    </div>
  )
}
