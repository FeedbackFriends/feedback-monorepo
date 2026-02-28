/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_LETSGROW_EARLY_ACCESS_URL?: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}

declare module '*.png' {
  const value: string
  export default value
}

declare module '*.svg' {
  const content: string
  export default content
}
