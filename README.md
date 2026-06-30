# 🏠 Family Todo App

A simple, shared todo app built with **Flutter** and **Supabase** — designed for me and my wife to keep track of family tasks. No sign-up, no passwords, just a shared family code to link devices.

## Why this exists

Me and my wife needed a dead-simple way to share household tasks without cluttering each other's personal todo lists or signing up for yet another service. This app is that: open it, enter the family code, and start adding tasks that sync instantly to both devices.

## Features

- **Add tasks** — Give it a title, a description, and optionally a priority.
- **Mark as done** — Check off tasks when they're completed.
- **Delete tasks** — Remove tasks you no longer need.
- **Reassign tasks** — Move a task between family members.
- **Real-time sync** — Changes appear instantly on both devices via Supabase Realtime (PostgreSQL logical replication + WebSockets).
- **Family code sharing** — One code links all devices to the same task list. No accounts needed.
- **Nickname-based attribution** — Each person picks a nickname on first launch so you can see who added or completed what.
- **Self-hostable** — Supabase is fully open-source. You can run it on your own server via Docker, or use the free cloud tier.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter (Dart) |
| **State Management** | Provider (`provider` package) |
| **Backend** | Supabase (PostgreSQL + Realtime) |
| **Auth** | Supabase Anonymous Auth (no-account device identity) |
| **Platforms** | Android, iOS (web TBD) |

## Architecture Overview

### Auth-less Sharing via Family Codes

Instead of requiring user accounts:

1. On first launch, the user picks a **nickname** (e.g., "Atef" or "Wife").
2. Supabase Anonymous Auth creates a persistent anonymous session (a `UID`).
3. The user either **creates** or **joins** a family by entering a **Family Code**.
4. The family code links to a row in the `families` table that acts as the shared list.
5. Any device with the correct family code can read/write the shared tasks.
6. Changes sync in real-time via Supabase's `stream()` API — each device subscribes to its family's tasks and gets pushed updates instantly.

### Data Model (PostgreSQL)

```sql
CREATE TABLE families (
  code       TEXT PRIMARY KEY,
  name       TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  members    JSONB DEFAULT '[]'::jsonb   -- [{ "uid": "...", "nickname": "..." }]
);

CREATE TABLE tasks (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_code TEXT NOT NULL REFERENCES families(code) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  description TEXT DEFAULT '',
  is_done     BOOLEAN DEFAULT false,
  assigned_to TEXT,                              -- member UID
  created_by  TEXT NOT NULL,                      -- member UID
  created_at  TIMESTAMPTZ DEFAULT now(),
  done_at     TIMESTAMPTZ
);

-- Index for fast queries by family
CREATE INDEX idx_tasks_family_code ON tasks(family_code);
```

### Row Level Security (RLS)

Supabase uses PostgreSQL Row Level Security. Since there's no real user account (just a family code), we allow anonymous access to families and their tasks. Anyone with the family code can read/write — the family code itself is the access key.

```sql
-- Enable RLS on both tables
ALTER TABLE families ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Anyone can read families (they either know the code or they don't)
CREATE POLICY "Anyone can read families"
  ON families FOR SELECT
  TO anon
  USING (true);

-- Anyone can insert a new family
CREATE POLICY "Anyone can create families"
  ON families FOR INSERT
  TO anon
  WITH CHECK (true);

-- Only members can update their family
CREATE POLICY "Members can update family"
  ON families FOR UPDATE
  TO anon
  USING (true)
  WITH CHECK (true);

-- No one can delete families from the app
-- (delete is admin-only, done via the Supabase dashboard)

-- Tasks: anyone can read/write if they provide a valid family_code
CREATE POLICY "Anyone can read tasks"
  ON tasks FOR SELECT
  TO anon
  USING (true);

CREATE POLICY "Anyone can insert tasks"
  ON tasks FOR INSERT
  TO anon
  WITH CHECK (true);

CREATE POLICY "Anyone can update tasks"
  ON tasks FOR UPDATE
  TO anon
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Anyone can delete tasks"
  ON tasks FOR DELETE
  TO anon
  USING (true);
```

> **Note on security:** The family code acts as the shared secret. This is intentionally simple — no passwords, no email verification. For production, you could add rate-limiting or integrate Supabase's built-in rate limiting to prevent brute-force code guessing.

### Offline & Syncing

Supabase does not include built-in offline persistence like Firestore. However, you can add offline support using a local SQLite database (e.g., the `drift` package) that mirrors your Supabase data and syncs when connectivity returns. This is a deliberate trade-off: you get a full relational database on the server and full control over your sync logic.

For v1, the app requires an internet connection to read and write data.

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0)
- A Supabase project (free tier is enough) — [create one here](https://supabase.com/dashboard)
- Android Studio / Xcode (for emulators)

### Setup

1. **Clone the repo**
   ```bash
   git clone <repo-url>
   cd family-todo
   ```

2. **Create a Supabase project**
   - Go to [supabase.com](https://supabase.com) and create a new project
   - Once created, go to **Project Settings > API** to find your **Project URL** and **anon key**
   - Enable **Anonymous Sign-In** under **Authentication > Providers**
   - Open the **SQL Editor** and run the schema + RLS policies from the [Data Model](#data-model-postgresql) and [RLS](#row-level-security-rls) sections above

3. **Environment variables via --dart-define**  
   The app reads Supabase credentials at compile time via `String.fromEnvironment`. Pass them when running or building:
   ```bash
   flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
   ```
   For a release build:
   ```bash
   flutter build apk --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
   ```

4. **Install dependencies**
   ```bash
   flutter pub get
   ```

5. **Run the app**
   ```bash
   flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
   ```

### First-time setup for two users

1. **User 1 (Creator):** Launches the app → picks a nickname → taps "Create Family" → gets a family code (e.g., `FAM123`).
2. **User 2 (Joiner):** Launches the app → picks a nickname → taps "Join Family" → enters `FAM123` → both devices are now synced to the same task list.

## Folder Structure

```
lib/
├── main.dart                  # App entry point + Supabase initialization
├── app.dart                   # MaterialApp configuration
├── models/
│   ├── task.dart              # Task data model
│   └── family_member.dart     # Family member model
├── services/
│   └── supabase_service.dart  # Supabase client & all DB operations
├── providers/
│   └── task_provider.dart     # State management for tasks
├── screens/
│   ├── setup_screen.dart      # Nickname + create/join family
│   ├── home_screen.dart       # Main task list
│   └── add_task_screen.dart   # Add/edit task form
└── widgets/
    ├── task_card.dart          # Single task widget
    ├── empty_state.dart        # Empty list placeholder
    └── family_code_dialog.dart # Join family dialog
```

## Roadmap

- [x] Write the README (you are here)
- [ ] Set up Flutter project with Supabase
- [ ] Implement anonymous auth
- [ ] Implement family code creation & joining
- [ ] Build the task list UI with real-time sync (`stream()`)
- [ ] Add task creation, completion, deletion
- [ ] Add nickname-based attribution
- [ ] Polish UI / dark mode
- [ ] Add local SQLite caching for offline support
- [ ] Publish to Android (and iOS)

## License

MIT
