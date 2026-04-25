# UI Development Methodology (React + MUI)

Canonical, tool-agnostic playbook for frontend UI development. Referenced by
`config/opencode/agent/ui-dev.md` and `config/claude/agents/ui-dev.md`.

---

## React Best Practices

- Write functional components using React hooks (useState, useEffect, useCallback, useMemo)
- Implement proper component composition; avoid unnecessary prop drilling
- Use React.memo for performance optimization when appropriate
- Follow React naming conventions: PascalCase for components, camelCase for functions/handlers
- Implement error boundaries for component subtrees that may fail
- Use TypeScript for type safety when available — always define prop interfaces

---

## Material-UI (MUI) Conventions

- Use MUI components as the building blocks; avoid reimplementing what MUI provides
- Implement responsive layouts with MUI's `Grid`, `Stack`, and `Box`
- Apply theming via `ThemeProvider` and `createTheme`; never hardcode design tokens
- Use the `sx` prop for component-specific one-off styles
- Use `styled()` from `@mui/material/styles` for reusable styled components
- Use `theme.spacing()` for all spacing — never raw pixel values
- Follow MUI's color palette system (`primary`, `secondary`, `error`, `warning`, `success`, `info`)
- Import icons from `@mui/icons-material`

---

## Component Structure

- **Single responsibility**: each component does one thing well
- **Presentational vs container**: separate data-fetching/logic from rendering
- **Reusable components**: place shared components in a `components/` directory
- **Co-location**: keep component-specific hooks, styles, and types close to the component
- **File size**: components over ~200 lines warrant splitting
- **Prop documentation**: always document props via TypeScript interfaces, not PropTypes

---

## Figma-to-Code Workflow

When implementing from a Figma design:

1. **Extract design tokens** — colors, spacing, typography, border radius, shadows
2. **Map to theme** — verify extracted tokens match or can be added to the MUI theme
3. **Break down hierarchy** — identify the component tree from the design
4. **Identify reusable components** — anything appearing more than once should be abstracted
5. **Implement responsively** — verify the design has breakpoint specifications; ask if missing
6. **Verify breakpoints** — test at xs, sm, md, lg, xl viewports
7. **Pixel-check** — compare rendered output against design; flag deviations > 4px

---

## Responsive Design

- Use MUI's breakpoint system (`xs`, `sm`, `md`, `lg`, `xl`) consistently
- Prefer `Grid` and `Stack` over manual `flex`/`grid` CSS for layout
- Test at mobile (375px), tablet (768px), and desktop (1280px+) as a minimum
- Use `useMediaQuery` for conditional logic that depends on viewport

---

## Accessibility

- Every interactive element needs an accessible name (label, aria-label, or aria-labelledby)
- Heading hierarchy must be logical (h1 → h2 → h3, no skipping)
- Use semantic HTML elements (`<button>`, `<nav>`, `<main>`, `<aside>`)
- Ensure keyboard navigation works: Tab to focus, Enter/Space to activate, Escape to close
- Verify focus indicators are visible (MUI handles this but custom styles can break it)
- Provide alt text for informational images; empty alt for decorative ones

---

## Styling Approach

1. `sx` prop → one-off, component-specific styles
2. `styled()` → reusable, named styled components
3. Theme overrides → global component style changes
4. CSS modules / global CSS → last resort, avoid if possible

Never use inline `style=` objects in production code — they defeat React optimization and theming.

---

## Implementation Checklist

Before marking any UI task done:
- [ ] Component renders correctly at all breakpoints
- [ ] TypeScript types defined for all props
- [ ] Accessibility attributes in place
- [ ] Theme tokens used (no hardcoded colors or spacing)
- [ ] No console errors or warnings
- [ ] Tested with keyboard navigation
- [ ] Matches design within acceptable tolerance
