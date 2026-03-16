import * as React from "react"
import { Slot } from "@radix-ui/react-slot"
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"

const sidebarMenuButtonVariants = cva(
  "flex w-full items-center gap-3 rounded-none px-0 py-2.5 text-left text-sm font-medium transition-colors outline-hidden focus-visible:ring-2 focus-visible:ring-ring/50",
  {
    variants: {
      active: {
        true: "bg-transparent text-slate-950",
        false: "bg-transparent text-slate-500 hover:text-slate-950",
      },
    },
    defaultVariants: {
      active: false,
    },
  }
)

function SidebarProvider({
  children,
  className,
}: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn("flex min-h-screen w-full flex-col lg:flex-row", className)}
      data-slot="sidebar-provider"
    >
      {children}
    </div>
  )
}

const Sidebar = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <aside
      ref={ref}
      className={cn(
        "w-full shrink-0 border-b border-slate-200 bg-[#fafaf8] lg:sticky lg:top-0 lg:h-screen lg:w-72 lg:border-b-0 lg:border-r",
        className
      )}
      data-slot="sidebar"
      {...props}
    />
  )
)
Sidebar.displayName = "Sidebar"

const SidebarHeader = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn("px-4 py-5 sm:px-5 lg:px-5 lg:pt-6 lg:pb-2", className)}
      data-slot="sidebar-header"
      {...props}
    />
  )
)
SidebarHeader.displayName = "SidebarHeader"

const SidebarContent = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn("flex flex-1 flex-col gap-8 px-4 pb-4 sm:px-5 lg:px-5", className)}
      data-slot="sidebar-content"
      {...props}
    />
  )
)
SidebarContent.displayName = "SidebarContent"

const SidebarFooter = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn("mt-auto border-t border-slate-200 px-4 pb-5 pt-5 sm:px-5 lg:px-5 lg:pb-6", className)}
      data-slot="sidebar-footer"
      {...props}
    />
  )
)
SidebarFooter.displayName = "SidebarFooter"

const SidebarGroup = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn(
        "p-0",
        className
      )}
      data-slot="sidebar-group"
      {...props}
    />
  )
)
SidebarGroup.displayName = "SidebarGroup"

const SidebarGroupLabel = React.forwardRef<HTMLParagraphElement, React.HTMLAttributes<HTMLParagraphElement>>(
  ({ className, ...props }, ref) => (
    <p
      ref={ref}
      className={cn(
        "text-xs font-medium uppercase tracking-[0.18em] text-slate-400",
        className
      )}
      data-slot="sidebar-group-label"
      {...props}
    />
  )
)
SidebarGroupLabel.displayName = "SidebarGroupLabel"

const SidebarGroupContent = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn("mt-2", className)}
      data-slot="sidebar-group-content"
      {...props}
    />
  )
)
SidebarGroupContent.displayName = "SidebarGroupContent"

const SidebarMenu = React.forwardRef<HTMLUListElement, React.HTMLAttributes<HTMLUListElement>>(
  ({ className, ...props }, ref) => (
    <ul
      ref={ref}
      className={cn("grid gap-2", className)}
      data-slot="sidebar-menu"
      {...props}
    />
  )
)
SidebarMenu.displayName = "SidebarMenu"

const SidebarMenuItem = React.forwardRef<HTMLLIElement, React.HTMLAttributes<HTMLLIElement>>(
  ({ className, ...props }, ref) => (
    <li
      ref={ref}
      className={cn("list-none", className)}
      data-slot="sidebar-menu-item"
      {...props}
    />
  )
)
SidebarMenuItem.displayName = "SidebarMenuItem"

type SidebarMenuButtonProps = React.ButtonHTMLAttributes<HTMLButtonElement> &
  VariantProps<typeof sidebarMenuButtonVariants> & {
    asChild?: boolean
  }

const SidebarMenuButton = React.forwardRef<HTMLButtonElement, SidebarMenuButtonProps>(
  ({ active, asChild = false, className, ...props }, ref) => {
    const Comp = asChild ? Slot : "button"

    return (
      <Comp
        ref={ref}
        className={cn(sidebarMenuButtonVariants({ active, className }))}
        data-slot="sidebar-menu-button"
        {...props}
      />
    )
  }
)
SidebarMenuButton.displayName = "SidebarMenuButton"

const SidebarInset = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <main
      ref={ref}
      className={cn("flex-1 bg-slate-50", className)}
      data-slot="sidebar-inset"
      {...props}
    />
  )
)
SidebarInset.displayName = "SidebarInset"

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
}
