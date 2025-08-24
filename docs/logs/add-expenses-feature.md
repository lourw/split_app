---
title: Adding Expenses Feature to SplitApp
date: 2025-08-24
time: 20:35:00
author: Claude
tags: [expenses, feature, money, liveview, associations]
---

# Adding Expenses Feature to SplitApp

## Overview
This document outlines the implementation of the Expenses feature, which allows users to create, track, and manage expenses. The feature integrates with the existing Groups system and includes proper money handling with multi-currency support.

## Database Changes

### 1. Expenses Table
Created a new `expenses` table with the following fields:
- `id` - Primary key
- `title` - String field for expense title (required)
- `description` - Text field for expense description (optional)
- `amount` - Map field storing Money type with amount and currency (required)
- `created_by_id` - Foreign key to users table (required)
- `inserted_at` - Timestamp
- `updated_at` - Timestamp

**Migration file:** `priv/repo/migrations/20250824203547_create_expenses.exs`

### 2. Expense Assignments Join Table
Created an `expense_assignments` join table for many-to-many relationship between expenses and users:
- `expense_id` - Foreign key to expenses table
- `user_id` - Foreign key to users table  
- `inserted_at` - Timestamp
- `updated_at` - Timestamp
- Composite unique index on `[expense_id, user_id]`

### 3. Expense Groups Join Table  
Created an `expense_groups` join table for many-to-many relationship between expenses and groups:
- `expense_id` - Foreign key to expenses table
- `group_id` - Foreign key to groups table
- `inserted_at` - Timestamp
- `updated_at` - Timestamp
- Composite unique index on `[expense_id, group_id]`

## Code Changes

### 1. Money Library Integration (`mix.exs`)
Added `money` library dependency for proper currency handling:
```elixir
{:money, "~> 1.12"}
```

### 2. Context and Schemas

#### Expenses Context (`lib/split_app/expenses.ex`)
Generated using Phoenix context generator with functions:
- `list_expenses/0` - List all expenses
- `list_expenses_by_user/1` - List expenses created by specific user
- `get_expense!/1` - Get a single expense
- `create_expense/1` - Create a new expense
- `update_expense/2` - Update an expense
- `delete_expense/1` - Delete an expense
- `change_expense/2` - Generate changeset for forms

#### Expense Schema (`lib/split_app/expenses/expense.ex`)
- Fields: `title`, `description`, `amount` (Money type)
- Associations:
  - `belongs_to :created_by` (User who created the expense)
  - `many_to_many :assigned_users` through `expense_assignments`
  - `many_to_many :groups` through `expense_groups`
- Custom validation for Money type ensuring:
  - Amount is greater than 0
  - Currency is present
  - Valid Money struct format

### 3. Web Layer

#### Expense LiveViews (Generated)
- `lib/split_app_web/live/expense_live/index.ex` - List user's expenses
- `lib/split_app_web/live/expense_live/show.ex` - Show single expense
- `lib/split_app_web/live/expense_live/form_component.ex` - Create/edit expenses
  - Custom money input handling
  - Currency selection support
  - Integration with current user context

#### Dashboard Updates (`lib/split_app_web/live/dashboard_live.ex`)
Enhanced dashboard to show user's recent expenses alongside groups.

#### Live Helpers (`lib/split_app_web/live/live_helpers.ex`)
Added utility functions for LiveView components and common patterns.

### 4. Router Updates (`lib/split_app_web/router.ex`)

Added authenticated routes for expenses:
```elixir
live "/expenses", ExpenseLive.Index, :index
live "/expenses/new", ExpenseLive.Index, :new
live "/expenses/:id/edit", ExpenseLive.Index, :edit
live "/expenses/:id", ExpenseLive.Show, :show
live "/expenses/:id/show/edit", ExpenseLive.Show, :edit
```

### 5. Group Integration

#### Group LiveViews Updates
Updated group show and index pages to display related expenses and provide links to create expenses within group context.

## Features Implemented

### Money Handling
- **Multi-Currency Support**: Uses Money library for proper currency handling
- **Validation**: Ensures positive amounts and valid currency codes  
- **Display**: Proper formatting of money amounts in UI
- **Input**: Custom form inputs for amount and currency selection

### Expense Management
- **Create Expenses**: Users can create expenses with title, description, and amount
- **Edit/Delete**: Full CRUD operations for user's own expenses
- **User Context**: Expenses are automatically associated with creator
- **Filtering**: Users see only their own expenses by default

### Associations
- **User Assignment**: Expenses can be assigned to multiple users (foundation for splitting)
- **Group Integration**: Expenses can be associated with groups
- **Creator Tracking**: System tracks who created each expense

### UI/UX Features
- **Expense List**: Clean table view of user's expenses with amounts, titles, and dates
- **Money Display**: Proper currency formatting (e.g., "$25.50 USD")
- **Form Validation**: Real-time validation of money amounts and required fields
- **Integration**: Seamless navigation between expenses, groups, and dashboard

## Testing

### Test Files Created
- `test/split_app/expenses/expense_test.exs` - Unit tests for Expense schema
- `test/split_app_web/live/expense_live_test.exs` - Integration tests for LiveViews
- `test/support/fixtures/expenses_fixtures.ex` - Test data fixtures

### Test Coverage
- Schema validations for Money type
- CRUD operations in context
- LiveView interactions and form submissions
- Money formatting and display

## Migration Commands

```bash
# Add money library
# (Added to mix.exs manually)

# Generate the Expenses context and schema
mix phx.gen.context Expenses Expense expenses title:string description:text amount:map created_by_id:references:users

# Generate LiveView pages  
mix phx.gen.live Expenses Expense expenses title:string description:text amount:map created_by_id:references:users --no-context --no-schema

# Run migrations
mix ecto.migrate

# Install new dependencies
mix deps.get
```

## Future Enhancements

This foundation enables future expense splitting functionality:
- **Expense Splitting**: Calculate splits between assigned users
- **Settlement Tracking**: Track who owes what to whom  
- **Group Expense Views**: Show all expenses within a group
- **Balance Calculations**: Calculate user balances across groups
- **Payment Tracking**: Mark when debts are settled
- **Expense Categories**: Categorize expenses (food, transport, etc.)
- **Receipt Uploads**: Attach receipt images to expenses
- **Recurring Expenses**: Support for recurring/scheduled expenses

## Technical Notes

### Money Type Implementation
The Money library stores currency amounts as a map in the database:
```elixir
%{amount: 2550, currency: :USD}  # Represents $25.50 USD
```

This ensures:
- Precise decimal arithmetic (no floating point errors)
- Multi-currency support 
- Consistent currency handling across the application
- Proper serialization/deserialization from database

### Performance Considerations
- Indexes on `created_by_id` for efficient user expense queries
- Composite unique indexes on join tables prevent duplicates
- Ordered queries for chronological expense display