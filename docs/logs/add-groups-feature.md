---
title: Adding Groups Feature to SplitApp
date: 2025-08-24
time: 17:28:00
author: Claude
tags: [groups, feature, authentication, liveview]
---

# Adding Groups Feature to SplitApp

## Overview
This document outlines the implementation of the Groups feature, which allows users to organize themselves into groups for expense tracking. Users can create groups, join groups, and view all groups they belong to on a dashboard landing page.

## Database Changes

### 1. Groups Table
Created a new `groups` table with the following fields:
- `id` - Primary key
- `name` - String field for group name
- `description` - Text field for group description
- `inserted_at` - Timestamp
- `updated_at` - Timestamp

**Migration file:** `priv/repo/migrations/20250824171051_create_groups.exs`

### 2. User-Groups Join Table
Created a `user_groups` join table to establish many-to-many relationship:
- `user_id` - Foreign key to users table
- `group_id` - Foreign key to groups table
- `inserted_at` - Timestamp
- `updated_at` - Timestamp
- Composite unique index on `[user_id, group_id]`
- Individual indexes on `user_id` and `group_id`

**Migration file:** `priv/repo/migrations/20250824171107_create_user_groups.exs`

## Code Changes

### 1. Context and Schemas

#### Groups Context (`lib/split_app/groups.ex`)
Generated using Phoenix context generator with additional functions:
- `list_groups/0` - List all groups
- `get_group!/1` - Get a single group
- `create_group/1` - Create a new group
- `update_group/2` - Update a group
- `delete_group/1` - Delete a group
- `list_user_groups/1` - List all groups for a specific user
- `add_user_to_group/2` - Add a user to a group
- `remove_user_from_group/2` - Remove a user from a group

#### Group Schema (`lib/split_app/groups/group.ex`)
- Basic fields: `name`, `description`
- Association: `many_to_many :users` through `UserGroup`

#### UserGroup Schema (`lib/split_app/groups/user_group.ex`)
Join table schema with:
- Belongs to both User and Group
- Timestamps for tracking when users joined groups

#### User Schema Updates (`lib/split_app/accounts/user.ex`)
Added association: `many_to_many :groups` through `UserGroup`

### 2. Web Layer

#### Dashboard LiveView (`lib/split_app_web/live/dashboard_live.ex`)
Custom landing page that:
- Displays welcome message with user email
- Shows all groups the user belongs to in card format
- Provides empty state when user has no groups
- Links to create new groups and browse all groups

#### Group LiveViews (Generated)
- `lib/split_app_web/live/group_live/index.ex` - List all groups
- `lib/split_app_web/live/group_live/show.ex` - Show single group
- `lib/split_app_web/live/group_live/form_component.ex` - Create/edit groups
  - Modified to automatically add creator to new groups

### 3. Router Updates (`lib/split_app_web/router.ex`)

Added authenticated routes:
```elixir
live "/dashboard", DashboardLive, :index
live "/groups", GroupLive.Index, :index
live "/groups/new", GroupLive.Index, :new
live "/groups/:id/edit", GroupLive.Index, :edit
live "/groups/:id", GroupLive.Show, :show
live "/groups/:id/show/edit", GroupLive.Show, :edit
```

### 4. Authentication Updates (`lib/split_app_web/user_auth.ex`)

Changed `signed_in_path/1` to redirect authenticated users to `/dashboard` instead of home page.

## UI/UX Features

### Dashboard Page
- **Welcome Header**: Personalized greeting with user email
- **Group Cards**: Each group displayed as a card with:
  - Group icon
  - Group name
  - Group description (or placeholder if none)
  - Hover effects for better interactivity
  - Click to navigate to group details
- **Empty State**: When user has no groups:
  - Informative icon and message
  - Call-to-action button to create first group
- **Actions**: 
  - "Create New Group" button in header
  - "Browse All Groups" link at bottom

### Group Management
- Create new groups with name and description
- Creator automatically added as member
- List view of all groups with edit/delete actions
- Individual group pages (ready for future expense tracking features)

## Test Data (`priv/repo/seeds.exs`)

Created sample data for testing:

**Users:**
- user1@example.com (password: password12345)
  - Member of: Weekend Trip, Monthly Groceries
- user2@example.com (password: password12345)  
  - Member of: Weekend Trip, Birthday Party

**Groups:**
- Weekend Trip - "Expenses for our weekend getaway"
- Monthly Groceries - "Shared grocery expenses for the apartment"
- Birthday Party - "Planning and expenses for Sarah's birthday"

## Migration Commands

```bash
# Generate the Groups context
mix phx.gen.context Groups Group groups name:string description:text

# Generate LiveView pages (without context/schema)
mix phx.gen.live Groups Group groups name:string description:text --no-context --no-schema

# Generate user_groups migration
mix ecto.gen.migration create_user_groups

# Run migrations
mix ecto.migrate

# Reset database and run seeds
mix ecto.reset
```

## Future Enhancements

This foundation sets up the groups feature for future expense tracking functionality:
- Add expenses to groups
- Track who paid for what
- Calculate splits and balances
- Show group activity/history
- Invite users to groups via email
- Group member management and permissions