# SplitApp

SplitApp is a Phoenix Framework application for tracking expenses and splitting costs between users.

## Getting Started

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

### Code Generation

```bash
mix phx.gen.live Context Schema table field:type  # Generate LiveView CRUD
mix phx.gen.context Context Schema table field:type  # Generate context
mix phx.gen.schema Context.Schema table field:type   # Generate schema
```

### Linting and Formatting

```bash
mix format              # Format Elixir code
mix format --check-formatted  # Check if code is formatted
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix
