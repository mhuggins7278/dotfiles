# Global Agent Guidelines

## Available Subagents

- **docs**: Documentation specialist for fetching library docs using Context7
- **browser**: Browser automation and web testing using Chrome DevTools
- **whois**: GLG employee directory lookup specialist
- **zenhub**: ZenHub project management specialist
- **deployment**: GLG Deployment System (GDS) infrastructure specialist
- **ui-dev**: Frontend UI development with React/Material-UI and Figma
- **review**: Code reviewer for catching bugs and issues before committing

## GLG Repositories

When working in any repository under `~/github/glg/`:

- **SQL Templates & DB Queries**: If the project references SQL files, epiquery templates, or database queries, always search `~/github/glg/epiquery-templates/` for the relevant templates. This central repository is the source of truth for database queries across all GLG projects.

## Code Style

- Use TypeScript with proper types when applicable
- Prefer const over let, modern ES syntax
- Include error handling, descriptive variable names
- Comments for complex logic only
- Format with language-specific tools (prettierd, stylua, etc.)

## Daily Notes Policy

When creating new daily notes:

- **Do not** carry forward completed TaskNotes items from previous days
- **Do not** auto-copy yesterday's Notes section into today's file
- Keep each day's Tasks and Notes focused on current/in-progress work only
- Leave summaries and completed items in their respective daily files
