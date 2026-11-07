# Web UI

Paths are relative to `web/` unless stated otherwise.

## UI Guidelines

- Keep operational/dashboard UI dense, calm, and easy to scan.
- Avoid nested cards, decorative gradient orbs, and one-note color palettes.
- Keep cards to individual repeated items, modals, or framed tools.
- Use stable dimensions for controls, boards, counters, tiles, and toolbars so state changes do not shift layout.

## shadcn setup and leader app policy

`web/components.json` configures the official registry, New York style, Tailwind
v4 stylesheet and `@/` aliases. The repository's shadcn MCP starts in `web/`;
registry discovery, component/block examples, and add commands are available.
Run CLI commands from `web/`, or explicitly pass `--cwd web` from the root:

```bash
npx shadcn@latest add @shadcn/sidebar-07 --cwd web
```

The leader app must use shadcn components wherever available. Product components
compose the primitives and own behavior; do not build replacement controls or
primitive styling. Prefer blocks for app-shell structure. `sidebar-07` supplies the leader shell composition in `DashboardShell.tsx`: a
collapsible desktop sidebar, mobile sheet, Teams/Medarbejdere navigation and account controls.
Keep navigation tied to implemented features rather than shipping placeholder sections.
Mobile sidebar buttons omit desktop tooltips so Escape dismisses the sheet directly.

Registry UI components live under `src/components/ui`, with the sidebar's mobile
hook in `src/hooks/use-mobile.ts`. The registry's `cn` and `radix-ui` dependencies
are installed. Sidebar theme tokens are registered in `globals.css`. Its provider
includes tooltip support. When overwriting shared primitives, inspect marketing
consumers too and rerun lint, production build, and affected browser journeys.


Leader navigation separates overview from actions. `/dashboard` lists teams and opens team creation in a registry Dialog. `/dashboard/teams/[teamId]` shows one team's membership and exposes invitation sharing through a Dialog. `/dashboard/employees` lists active employees and pending requests across authorized teams with status and membership actions. Keep unsupported profile fields and management actions out of the UI. The employee overview uses the existing team-management API in parallel after loading context; authorization remains on the backend.
