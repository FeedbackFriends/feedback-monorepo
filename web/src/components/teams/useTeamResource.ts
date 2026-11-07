"use client"

import { useCallback, useEffect, useRef, useState } from "react"
import { APIHTTPError, apiErrorPresentation } from "@/lib/api/client"

/** One ordered request lifecycle per screen resource. No shared user-data cache. */
export function useTeamResource<T>(load: (signal: AbortSignal) => Promise<T>) {
  const [data, setData] = useState<T | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [busy, setBusy] = useState(false)
  const [accessDenied, setAccessDenied] = useState(false)
  const active = useRef<AbortController | null>(null)
  const mutating = useRef(false)

  const execute = useCallback(
    async (action: (signal: AbortSignal) => Promise<T>, mutation: boolean) => {
      // A synchronous lock also covers two submissions before React re-renders.
      if (mutating.current) return
      active.current?.abort()
      const controller = new AbortController()
      active.current = controller
      mutating.current = mutation
      setBusy(true)
      setError(null)
      try {
        const next = await action(controller.signal)
        if (controller.signal.aborted) return
        setAccessDenied(false)
        setData(next)
        return next
      } catch (cause) {
        if (controller.signal.aborted) return
        if (
          cause instanceof APIHTTPError &&
          [401, 403, 404].includes(cause.status)
        ) {
          setData(null)
          setAccessDenied(true)
        }
        setError(
          apiErrorPresentation(cause, "da")?.message ??
            "Noget gik galt. Prøv igen.",
        )
      } finally {
        if (active.current === controller && !controller.signal.aborted) {
          mutating.current = false
          setBusy(false)
          setLoading(false)
        }
      }
    },
    [],
  )

  useEffect(() => {
    mutating.current = false
    void execute(load, false)
    return () => {
      active.current?.abort()
      active.current = null
      mutating.current = false
    }
  }, [load, execute])

  const refresh = useCallback(() => execute(load, false), [execute, load])
  const mutate = useCallback(
    (action: (signal: AbortSignal) => Promise<T>) => execute(action, true),
    [execute],
  )
  return { data, error, loading, busy, accessDenied, refresh, mutate, setError }
}
