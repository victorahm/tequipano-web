# Tequipano-Web — Rails 8.1 Monolith

**Tequipano-Web** is the central application of the Tequipano project: a single monolithic Ruby on Rails application that serves the backend, the server-rendered Hotwire web interface, the versioned JSON API, and the mobile experience (a Progressive Web App).

> **Project Management**: Issues, Kanban board, and workflow for this application are tracked in its Redmine project: <https://redmine.obsidianasystems.com/projects/tequipano-web>

## Features

- **Hotwire UI** — Server-rendered HTML with Turbo Drive navigation, Turbo Frames for inline editing/modals, and Turbo Streams for real-time updates over ActionCable.
- **REST / JSON API** — Versioned `/api/v1/` endpoints consumed by **Tequipano-CLI** and **Tequipano-Desktop**.
- **Mobile PWA** — Rails 8.1 built-in PWA (`rails pwa`) with Service Workers, Web Push notifications, and offline support.
- **ActiveStorage** — File attachments with MIME type and size constraint validation.
- **ActionCable** — Real-time task updates broadcast to all connected web clients.
- **Solid Queue / Solid Cache / Solid Cable** — PostgreSQL-backed background jobs, caching, and WebSocket pub/sub (no Redis required).
- **Auth-ready** — `User` (bcrypt) and `ApiToken` (bearer tokens for CLI and AI agents).

## Tech Stack

- **Ruby**: 4.0.7
- **Rails**: 8.1.3.1
- **Database**: PostgreSQL 18+
- **Frontend**: Hotwire (Turbo 8, Stimulus) + Vanilla CSS / Design Tokens
- **Mobile**: Rails 8.1 PWA (`rails pwa`)
- **Jobs/Cache/ActionCable**: Solid Queue, Solid Cache, Solid Cable
- **Deployment**: Kamal 2 (Thruster proxy)
- **DevOps**: DevContainers (`.devcontainer`) + GitHub Actions CI

## Domain Models

- `User` — Authentication (bcrypt), time zone preference
- `ApiToken` — Bearer token auth for CLI and AI agents
- `List` — Task containers with color and position
- `Task` — Core entity with status state machine (`todo`, `doing`, `done`, `paused`, `blocked`)
- `Tag` / `TaskTag` — Categorization system
- `Comment` — Task-level discussions

## Status State Machine

```
todo → doing → done
todo → done (direct completion)
doing → paused → doing
doing → blocked → doing
done → todo (reopened)
```

## Quickstart

### Using DevContainers (Recommended)

1. Open this folder in VS Code or Antigravity IDE.
2. Select **Reopen in Container** when prompted — the DevContainer provisions Ruby 4.0.7, PostgreSQL 18, and the Rails toolchain.
3. The `postCreateCommand` runs `bin/setup --skip-server` (installs gems and prepares the database).
4. Start the local server:
   ```bash
   mise run server
   ```
5. Access the application at `http://localhost:3000`.

### Manual setup (outside a container)

```bash
bundle install
bin/rails db:prepare
mise run server
```

## Testing & Lint

```bash
mise run test       # bin/rails test
mise run lint       # bin/rubocop
bin/brakeman -q -w3 # security scanner
bin/bundler-audit   # vulnerable gem check
```

## Deployment

Deployment uses **Kamal 2**. See `config/deploy.yml` and the CI workflow in `.github/workflows/ci.yml`.

## Companion Applications

The `/api/v1/` JSON API is consumed by the two companion applications in this repository:

- **Tequipano-CLI** (`../tequipano-cli/`) — Ruby CLI for humans, scripts, and AI agents.
- **Tequipano-Desktop** (`../tequipano-desktop/`) — Native Ruby GTK4 / Libadwaita Linux desktop client.