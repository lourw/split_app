# CLAUDE.md

## Project Overview

SplitApp is a Phoenix Framework application built with Elixir. It uses Phoenix LiveView for interactive UI, SQLite for database storage, and includes user authentication functionality.

## Tech Stack

- **Backend**: Elixir with Phoenix Framework 1.7.20
- **Database**: SQLite via Ecto
- **Frontend**: Phoenix LiveView, TailwindCSS, and esbuild
- **Authentication**: Built-in Phoenix authentication with bcrypt
- **Email**: Swoosh for email delivery
- **Server**: Bandit web server

## Essential Commands

### Development Setup

```bash
mix setup                # Install dependencies, create database, run migrations, and build assets
mix deps.get            # Install Elixir dependencies
mix ecto.setup          # Create database, run migrations, and seed data
```

### Running the Application

```bash
mix phx.server          # Start Phoenix server (visit http://localhost:4000)
iex -S mix phx.server   # Start Phoenix server with interactive Elixir shell
```

### Database Management

```bash
mix ecto.create         # Create the database
mix ecto.migrate        # Run pending migrations
mix ecto.reset          # Drop, create, and migrate database
mix ecto.gen.migration NAME  # Generate a new migration
```

### Testing

```bash
mix test                # Run all tests
mix test FILE           # Run specific test file
mix test FILE:LINE      # Run specific test at line number
mix test --stale        # Run only stale tests
```

### Assets

```bash
mix assets.build        # Build CSS and JavaScript assets
mix assets.deploy       # Build and minify assets for production
```

## Architecture

### Directory Structure

- **lib/split_app/**: Core business logic and contexts
  - `accounts/`: User authentication domain (User, UserToken, UserNotifier)
  - `application.ex`: OTP application supervision tree
  - `repo.ex`: Ecto repository

- **lib/split_app_web/**: Web layer
  - `router.ex`: HTTP routes and pipelines
  - `controllers/`: Traditional Phoenix controllers
  - `live/`: LiveView modules for user authentication flows
  - `components/`: Reusable UI components
  - `user_auth.ex`: Authentication plugs and helpers

- **priv/**: Private application files
  - `repo/migrations/`: Database migrations
  - `static/`: Static assets served directly

### Key Architectural Patterns

1. **Context Pattern**: Business logic is organized in contexts (e.g., Accounts). Each context manages its own domain and exposes a public API to the web layer.

2. **LiveView Authentication**: User registration, login, password reset, and settings are implemented as LiveView modules with real-time validation.

3. **Pipeline Architecture**: The router uses pipelines (`:browser`, `:api`, `:require_authenticated_user`) to apply common plugs to groups of routes.

4. **Session Management**: User sessions are managed through database-backed tokens (UserToken) with configurable expiration times.

### Authentication Flow

The application includes complete user authentication with:

- Registration with email confirmation
- Login/logout with session tokens
- Password reset via email
- User settings management
- Protected routes requiring authentication

Routes are protected using custom plugs defined in `UserAuth`:

- `redirect_if_user_is_authenticated`: Redirects logged-in users away from auth pages
- `require_authenticated_user`: Ensures user is logged in
- `fetch_current_user`: Loads current user into assigns

### Database Schema

The application uses SQLite with Ecto. Current tables:

- `users`: User accounts with email and hashed passwords
- `users_tokens`: Multi-purpose tokens for sessions, email confirmation, and password reset

## Development Workflow

1. Migrations are automatically run in development via `mix ecto.migrate`
2. LiveView enables real-time UI updates without JavaScript
3. TailwindCSS is configured for utility-first styling
4. Hot code reloading is enabled in development for both Elixir and assets

## Testing Approach

Tests use ExUnit with:

- `ConnCase`: For testing controllers and LiveViews with connection
- `DataCase`: For testing contexts and schemas with database
- Fixtures in `test/support/fixtures/` for test data
- Ecto Sandbox for database isolation between tests

# Purpose

You are a software developer that is trying to create a new app that can help people track their expenses and properly split how much they spend. You want to create a web app using elixir and the Pheonix framework.

# Development

Use the following principles when making changes to this project:

1. Prioritize pheonix framework code generators over coding from scratch. Utilize these tools to bootstrap the core domain models and structure of the app. You should not be creating too much custom code except within the concrete implementation of services that the generators have bootstrapped.

2. When working on front end code, make sure that every new component or UI change conforms do the existing design language. Prioritize reusability instead of customizing every individual piece.

3. After making any new feature change, add any relevant tests in and make sure that all tests pass.
