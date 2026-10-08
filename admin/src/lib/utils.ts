import { useEffect, useState } from 'react'
import { useSearchParams } from 'react-router'
import { clsx, type ClassValue } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function useDebounced<T>(value: T, ms = 350): T {
  const [v, setV] = useState(value)
  useEffect(() => {
    const t = setTimeout(() => setV(value), ms)
    return () => clearTimeout(t)
  }, [value, ms])
  return v
}

/** Bộ lọc lưu trên URL (?page=&q=...). Đổi bộ lọc khác `page` thì quay về trang 1. */
export function useUrlFilters<K extends string>(keys: readonly K[]) {
  const [params, setParams] = useSearchParams()
  const values = Object.fromEntries(keys.map((k) => [k, params.get(k) ?? ''])) as Record<K, string>
  const page = Math.max(1, Number(params.get('page')) || 1)
  const set = (patch: Partial<Record<K | 'page', string | number>>) =>
    setParams(
      (prev) => {
        const next = new URLSearchParams(prev)
        for (const [k, v] of Object.entries(patch)) {
          if (v === '' || v === undefined || v === 'all') next.delete(k)
          else next.set(k, String(v))
        }
        if (!('page' in patch)) next.delete('page')
        if (next.get('page') === '1') next.delete('page')
        return next
      },
      { replace: true },
    )
  return { values, page, set }
}
