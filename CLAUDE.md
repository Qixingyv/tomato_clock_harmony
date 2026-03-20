# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Pomodoro Timer application built for HarmonyOS using ArkTS and ArkUI framework. The app helps users improve productivity through the Pomodoro Technique with task management, countdown timer, and statistics tracking.

## Technology Stack

- **Language**: ArkTS (TypeScript variant for HarmonyOS)
- **UI Framework**: ArkUI (declarative UI)
- **Target Platform**: HarmonyOS (API 21+)
- **Build System**: Hvigor
- **Package Manager**: ohpm

## Common Commands

### Building the Project
```bash
# Build the project (via DevEco Studio or command line)
hvigor build
```

### Running Tests
```bash
# Run local unit tests
hvigor test --module entry --test-type ohosTest

# Run device tests
# Use DevEco Studio's test runner
```

### Code Quality
```bash
# Run linter (configured in code-linter.json5)
# Linting is automatically performed during build
```

## Project Structure

```
entry/src/main/ets/
├── pages/           # Page components (entry points for navigation)
│   ├── Index.ets              # Login/welcome page
│   ├── MainPage.ets           # Main tab container
│   ├── CountDownTimer.ets     # Timer page
│   └── TaskEdit.ets           # Task creation/editing
├── view/            # Reusable view components
│   ├── ToDoList.ets           # Task list display
│   ├── Statistics.ets         # Statistics page
│   └── Profile.ets            # User profile page
├── viewmodel/       # Data models and business logic
│   ├── ToDoListClass.ets      # Core task data model
│   ├── TaskType.ets           # Task type enum
│   └── TaskStatus.ets         # Task status enum
├── common/          # Shared utilities
│   ├── GlobalNavStack.ets     # Global navigation stack
│   ├── DateUtils.ets          # Date utilities
│   └── network/               # Network utilities
└── entryability/    # Application lifecycle
    └── EntryAbility.ets       # App entry point
```

## Architecture

### Navigation System
- Uses `NavPathStack` for page navigation with a global instance in `GlobalNavStack.ets`
- Routes are configured in `entry/src/main/resources/base/profile/route_map.json`
- Each page exports a Builder function (e.g., `MainPageBuilder()`) for route registration

### Data Model
- `ToDoListClass` is the core data model supporting two task modes:
  - **Todo Mode (mode=1)**: One-time tasks with target tomato count
  - **Long-term Mode (mode=2)**: Daily recurring tasks with daily target count
- Task states are managed through `TaskStatus` enum (Working/Rest)
- Task types are managed through `TaskType` enum

### Page Flow
1. `Index.ets` (Login) → `MainPage.ets` (Main Tab Navigation)
2. `MainPage.ets` contains 3 tabs: ToDoList, Statistics, Profile
3. From ToDoList → `CountDownTimer.ets` (Timer) or `TaskEdit.ets` (Edit)

### Component Patterns
- Pages use `@Component` decorator with `NavDestination` wrapper
- Export Builder functions for navigation: `@Builder export function PageNameBuilder()`
- Use `@Prop` for received parameters, `@State` for local state

## Resource References

- Strings: `$r("app.string.string_name")`
- Colors: `$r("app.color.color_name")`
- Media: `$r("app.media.image_name")`
- Resources defined in `entry/src/main/resources/base/element/`

## Code Style Guidelines

Follow the conventions in `constitution.md`:
- Use ArkTS strictly - no `any` types
- Prefer `const` over `let`
- All async operations must be try-catch wrapped
- Use `@Extend` for reusable component styles
- Font sizes in `fp` units, spacing in `vp` units

## Key Files

- `build-profile.json5` - Project build configuration
- `entry/src/main/module.json5` - Module metadata and permissions
- `entry/build-profile.json5` - Entry module build settings
- `oh-package.json5` - Dependency management
- `code-linter.json5` - Linting rules and file patterns
- `route_map.json` - Navigation route configuration
- `constitution.md` - Development standards and conventions

## Device Types Supported

The app supports: phone, tablet, 2in1, wearable (configured in `module.json5`)

## Permissions Required

- `ohos.permission.INTERNET` - For future API calls
- `ohos.permission.GET_NETWORK_INFO` - Network status checking
