# 🏠 Family Todo App

A simple, shared todo app built with **Flutter** and **Supabase** — designed for me and my wife to keep track of family tasks. No sign-up, no passwords, just a family code to link devices. Available in English and Arabic.

## Why this exists

Me and my wife needed a dead-simple way to share household tasks without cluttering each other's personal todo lists or signing up for yet another service. This app is that: open it, pick a language, enter the family code, and start adding tasks that sync instantly to both devices.

## Features

- **Language selection** — Choose English or Arabic on first launch (persisted across restarts).
- **Add tasks** — Give it a title, description, and an optional due date.
- **Due dates** — Pick a due date (dd-mm-yy) when creating a task; overdue tasks are highlighted in red with a warning icon.
- **Mark as done** — Check off tasks when they're completed.
- **Delete tasks** — Remove tasks you no longer need.
- **Offline-first** — Tasks are cached locally in SQLite; the app works fully offline and syncs automatically when connectivity returns.
- **Real-time sync** — Changes appear instantly on all linked devices via Supabase Realtime.
- **Family code sharing** — One code links all devices to the same task list. No accounts needed.
- **Nickname-based attribution** — Each person picks a nickname on first launch so you can see who added or completed what.
- **Self-hostable** — Supabase is fully open-source. Run it on your own server via Docker, or use the free cloud tier.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter (Dart) |
| **State Management** | Provider (`provider` package) |
| **Localization** | Flutter l10n (ARB files + code generation) |
| **Local Storage** | `sembast` (cross-platform NoSQL) + `SharedPreferences` |
| **Connectivity** | `connectivity_plus` (network monitoring + auto-sync) |
| **Backend** | Supabase (PostgreSQL + Realtime) |
| **Auth** | Supabase Anonymous Auth (no-account device identity) |
| **Platforms** | Android, iOS |

## Architecture Overview

### Auth-less Sharing via Family Codes

Instead of requiring user accounts:

1. On first launch, the user picks a **language** (English or العربية), then a **nickname** (e.g., "Atef" or "Wife").
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
  done_at     TIMESTAMPTZ,
  due_at      TIMESTAMPTZ                         -- optional due date/time
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
  TO authenticated
  USING (true);

-- Anyone can insert a new family
CREATE POLICY "Anyone can create families"
  ON families FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Only members can update their family
CREATE POLICY "Members can update family"
  ON families FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- No one can delete families from the app
-- (delete is admin-only, done via the Supabase dashboard)

-- Tasks: anyone can read/write if they provide a valid family_code
CREATE POLICY "Anyone can read tasks"
  ON tasks FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Anyone can insert tasks"
  ON tasks FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Anyone can update tasks"
  ON tasks FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Anyone can delete tasks"
  ON tasks FOR DELETE
  TO authenticated
  USING (true);
```

> **Note on security:** The family code acts as the shared secret. This is intentionally simple — no passwords, no email verification. For production, you could add rate-limiting or integrate Supabase's built-in rate limiting to prevent brute-force code guessing.

### Localization

The app uses Flutter's built-in **l10n** code generation. Source strings are maintained as ARB files:

- `lib/l10n/app_en.arb` — English
- `lib/l10n/app_ar.arb` — Arabic

After editing ARB files, regenerate the Dart bindings:

```bash
flutter gen-l10n
```

The user's language choice is persisted with `SharedPreferences` and picked on first launch via a dedicated language selection screen.

### Offline & Syncing

The app uses an **offline-first** architecture:

1. **Local cache (SQLite):** All tasks are stored in a local SQLite database (`sqflite`). On launch, tasks load instantly from the cache.
2. **Immediate writes:** Every create/update/delete writes to the local DB first, then attempts the remote Supabase call.
3. **Pending queue:** If the device is offline (or the server call fails), the operation is tagged with a sync status (`pending_create`, `pending_update`, or `pending_delete`) and queued locally.
4. **Auto-sync on reconnect:** `connectivity_plus` monitors network state. When connectivity is restored, pending operations are replayed against the server in order, then a full pull reconciles the local cache with remote data.
5. **Real-time subscription:** When online, the app subscribes to Supabase Realtime for instant updates from other devices. Incoming changes are written straight to the local DB.
6. **Offline resume:** The family code is persisted in `SharedPreferences`, so reopening the app while offline shows the cached task list immediately.

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

2. **Add the `due_at` column to your Supabase tasks table**
   If your database was created before due dates were added, run:
   ```sql
   ALTER TABLE tasks ADD COLUMN due_at TIMESTAMPTZ;
   ```

3. **Create a Supabase project**
   - Go to [supabase.com](https://supabase.com) and create a new project
   - Once created, go to **Project Settings > API** to find your **Project URL** and **anon key**
   - Enable **Anonymous Sign-In** under **Authentication > Providers**
   - Open the **SQL Editor** and run the schema + RLS policies from the [Data Model](#data-model-postgresql) and [RLS](#row-level-security-rls) sections above

4. **Environment via JSON config file**  
   The app reads Supabase credentials at compile time via `String.fromEnvironment`. Create an `env.json` file in the project root (it's gitignored — see `env.example.json` for the template):
   ```json
   {
     "SUPABASE_URL": "https://your-project.supabase.co",
     "SUPABASE_ANON_KEY": "your-anon-key"
   }
   ```
   Then run or build without typing credentials every time:
   ```bash
   flutter run --dart-define-from-file=env.json
   ```
   For a release build:
   ```bash
   flutter build apk --dart-define-from-file=env.json
   ```

---

**Alternatively**, pass them inline (for CI/CD or one-off runs):
```bash
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

5. **Install dependencies**
   ```bash
   flutter pub get
   ```

6. **Generate localization bindings**
   ```bash
   flutter gen-l10n
   ```

7. **Run the app**
   ```bash
   flutter run --dart-define-from-file=env.json
   ```

### First-time setup for two users

1. **User 1 (Creator):** Launches the app → picks a language → picks a nickname → taps "Create Family" → gets a family code (e.g., `FAM123`).
2. **User 2 (Joiner):** Launches the app → picks a language → picks a nickname → taps "Join Family" → enters `FAM123` → both devices are now synced to the same task list.

## Folder Structure

```
lib/
├── main.dart                  # App entry point + Supabase initialization
├── app.dart                   # MaterialApp configuration + locale setup
├── l10n.yaml                  # Localization config
├── generated/                 # Auto-generated l10n Dart code
│   ├── app_localizations.dart
│   ├── app_localizations_en.dart
│   └── app_localizations_ar.dart
├── l10n/
│   ├── app_en.arb             # English strings
│   └── app_ar.arb             # Arabic strings
├── models/
│   ├── task.dart              # Task data model (includes dueAt)
│   └── family_member.dart     # Family member model
├── services/
│   ├── supabase_service.dart           # Supabase client & all DB operations
│   ├── local_database_service.dart     # Local cache (sembast document store)
│   ├── connectivity_service.dart       # Network monitoring + auto-sync trigger
│   ├── db_factory.dart                 # Conditional import facade (platform)
│   ├── db_factory_stub.dart            #   stub (fallback)
│   ├── db_factory_io.dart              #   IO implementation (mobile/desktop)
│   └── db_factory_web.dart             #   Web implementation (IndexedDB)
├── providers/
│   ├── task_provider.dart     # State management for tasks
│   └── language_provider.dart # Language preference persistence
├── screens/
│   ├── language_selection_screen.dart  # First-launch language picker
│   ├── setup_screen.dart      # Nickname + create/join family
│   ├── home_screen.dart       # Main task list
│   └── add_task_screen.dart   # Add task form (with due date picker)
└── widgets/
    ├── task_card.dart          # Single task widget (shows due/overdue)
    ├── empty_state.dart        # Empty list placeholder
    └── family_code_dialog.dart # Join family dialog
```

## Roadmap

- [x] Set up Flutter project with Supabase
- [x] Implement anonymous auth
- [x] Implement family code creation & joining
- [x] Build the task list UI with real-time sync (`stream()`)
- [x] Add task creation, completion, deletion
- [x] Add nickname-based attribution
- [x] Arabic / English localization with first-launch language picker
- [x] Due date / time support with overdue highlighting
- [x] Polish UI / dark mode
- [x] Add local SQLite caching for offline support
- [ ] Add task reassignment between family members
- [ ] Publish to Android (and iOS)

## License

MIT
