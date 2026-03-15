import * as React from "react"
import { Slot } from "@radix-ui/react-slot"
import { cva, type VariantProps } from "class-variance-authority"
import { PanelLeft } from "lucide-react"
import { cn } from "@/lib/utils"

type SidebarContextValue = {
  openMobile: boolean
  setOpenMobile: React.Dispatch<React.SetStateAction<boolean>>
  toggleMobile: () => void
}

const SidebarContext = React.createContext<SidebarContextValue | null>(null)

function useSidebar() {
  const context = React.useContext(SidebarContext)

  if (!context) {
    throw new Error("Sidebar components must be used within SidebarProvider.")
  }

  return context
}

function SidebarProvider({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  const [openMobile, setOpenMobile] = React.useState(false)

  const toggleMobile = React.useCallback(() => {
    setOpenMobile((current) => !current)
  }, [])

  return (
    <SidebarContext.Provider value={{ openMobile, setOpenMobile, toggleMobile }}>
      {children}
    </SidebarContext.Provider>
  )
}

const Sidebar = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ children, className, ...props }, ref) => {
  const { openMobile, setOpenMobile } = useSidebar()

  return (
    <>
      <button
        aria-hidden={!openMobile}
        className={cn(
          "fixed inset-0 z-40 bg-slate-950/30 backdrop-blur-[2px] transition-opacity md:hidden",
          openMobile ? "opacity-100" : "pointer-events-none opacity-0"
        )}
        onClick={() => setOpenMobile(false)}
        tabIndex={openMobile ? 0 : -1}
        type="button"
      />

      <aside
        className={cn(
          "fixed inset-y-4 left-4 z-50 flex w-[calc(100vw-2rem)] max-w-80 flex-col rounded-[2rem] border border-white/70 bg-white/82 shadow-[0_32px_90px_-55px_rgba(15,23,42,0.75)] backdrop-blur-xl transition-transform duration-200 md:static md:inset-auto md:z-auto md:w-72 md:max-w-none md:translate-x-0 xl:w-80",
          openMobile ? "translate-x-0" : "-translate-x-[115%] md:translate-x-0",
          className
        )}
        ref={ref}
        {...props}
      >
        {children}
      </aside>
    </>
  )
})
Sidebar.displayName = "Sidebar"

const SidebarInset = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn("min-w-0 flex-1", className)} {...props} />
))
SidebarInset.displayName = "SidebarInset"

const SidebarHeader = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("flex flex-col gap-4 border-b border-slate-200/80 p-5", className)}
    {...props}
  />
))
SidebarHeader.displayName = "SidebarHeader"

const SidebarContent = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("flex min-h-0 flex-1 flex-col gap-5 overflow-y-auto p-5", className)}
    {...props}
  />
))
SidebarContent.displayName = "SidebarContent"

const SidebarFooter = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("border-t border-slate-200/80 p-5", className)}
    {...props}
  />
))
SidebarFooter.displayName = "SidebarFooter"

const SidebarGroup = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn("flex flex-col gap-3", className)} {...props} />
))
SidebarGroup.displayName = "SidebarGroup"

const SidebarGroupLabel = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLParagraphElement>
>(({ className, ...props }, ref) => (
  <p
    ref={ref}
    className={cn(
      "px-2 text-xs font-semibold uppercase tracking-[0.22em] text-slate-500",
      className
    )}
    {...props}
  />
))
SidebarGroupLabel.displayName = "SidebarGroupLabel"

const SidebarGroupContent = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn("flex flex-col gap-2", className)} {...props} />
))
SidebarGroupContent.displayName = "SidebarGroupContent"

const SidebarMenu = React.forwardRef<
  HTMLUListElement,
  React.HTMLAttributes<HTMLUListElement>
>(({ className, ...props }, ref) => (
  <ul ref={ref} className={cn("flex flex-col gap-2", className)} {...props} />
))
SidebarMenu.displayName = "SidebarMenu"

const SidebarMenuItem = React.forwardRef<
  HTMLLIElement,
  React.HTMLAttributes<HTMLLIElement>
>(({ className, ...props }, ref) => (
  <li ref={ref} className={cn("list-none", className)} {...props} />
))
SidebarMenuItem.displayName = "SidebarMenuItem"

const sidebarMenuButtonVariants = cva(
  "flex w-full items-start gap-3 rounded-2xl border border-transparent px-4 py-3 text-left text-sm transition-all outline-hidden",
  {
    variants: {
      isActive: {
        true: "border-slate-950 bg-slate-950 text-white shadow-lg shadow-slate-900/15 [&_[data-slot=icon]]:text-emerald-300 [&_[data-slot=label]]:text-white [&_[data-slot=meta]]:text-slate-300",
        false:
          "bg-transparent text-slate-700 hover:bg-slate-50/90 [&_[data-slot=icon]]:text-emerald-600 [&_[data-slot=meta]]:text-slate-500 [&_[data-slot=label]]:text-slate-700",
      },
      size: {
        default: "",
        sm: "px-3 py-2",
      },
    },
    defaultVariants: {
      isActive: false,
      size: "default",
    },
  }
)

type SidebarMenuButtonProps = React.ButtonHTMLAttributes<HTMLButtonElement> &
  VariantProps<typeof sidebarMenuButtonVariants> & {
    asChild?: boolean
  }

const SidebarMenuButton = React.forwardRef<
  HTMLButtonElement,
  SidebarMenuButtonProps
>(({ asChild = false, className, isActive, size, ...props }, ref) => {
  const Comp = asChild ? Slot : "button"

  return (
    <Comp
      className={cn(sidebarMenuButtonVariants({ isActive, size }), className)}
      ref={ref}
      {...props}
    />
  )
})
SidebarMenuButton.displayName = "SidebarMenuButton"

const SidebarTrigger = React.forwardRef<
  HTMLButtonElement,
  React.ButtonHTMLAttributes<HTMLButtonElement>
>(({ className, ...props }, ref) => {
  const { toggleMobile } = useSidebar()

  return (
    <button
      className={cn(
        "inline-flex h-10 w-10 items-center justify-center rounded-2xl border border-slate-200 bg-white text-slate-700 shadow-sm transition-colors hover:bg-slate-50 md:hidden",
        className
      )}
      onClick={toggleMobile}
      ref={ref}
      type="button"
      {...props}
    >
      <PanelLeft className="h-4 w-4" />
      <span className="sr-only">Open sidebar</span>
    </button>
  )
})
SidebarTrigger.displayName = "SidebarTrigger"

export {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarHeader,
  SidebarInset,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarProvider,
  SidebarTrigger,
  useSidebar,
}
