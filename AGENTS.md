# Repository Guidelines

## Project Structure & Module Organization
Source lives under `PetSitterQR/`, with `PetSitterQRApp.swift` bootstrapping the SwiftUI + MVVM stack. Follow `architecture.md`: `AppEntry` for wiring, `Features/<Feature>/` for views and view models, `Services/` for storage + QR helpers, and `DesignSystem/Components/` for shared UI. Keep previews, mocks, and sample data beside their feature folders; shared models stay under `Models/`. Use `Assets.xcassets` only for human-provided assets—no new entries without approval.

## Build, Test, and Development Commands
- `open PetSitterQR.xcodeproj` – open the workspace in Xcode 16+ (target iOS 26).  
- `xcodebuild -scheme PetSitterQR -destination 'platform=iOS Simulator,name=iPhone 15' build` – CI-friendly build smoke test.  
- `xcodebuild test -scheme PetSitterQR -destination 'platform=iOS Simulator,name=iPhone 15'` – runs unit/UI tests once they exist.  
- `swiftlint` (if installed locally) – lint Swift style from the repo root.

## Coding Style & Naming Conventions
Use Swift 5.10 defaults: 4-space indentation, trailing commas for multiline literals, and explicit access control. Name every type with its role (`PetListViewModel`, `LocalPetStorageService`). Keep files scoped to one main type and group them by feature directory. Inject dependencies via initializers (`init(viewModel:)`) and mark view models `@MainActor final`. Add comments only when noting assumptions from `workflow_rules.md`.

## Testing Guidelines
Place tests under `PetSitterQRTests/` mirroring the feature folders; name specs `<Type>Tests` and helper fakes `<Type>Mock`. Cover view models and services with deterministic fixtures—previews are not tests. When QR scanning touches hardware, rely on protocol abstractions and inject stubs. Run `xcodebuild test …` before requesting review; we track meaningful coverage, not a numeric quota.

## Commit & Pull Request Guidelines
Commits so far are short and imperative, so keep concise summaries plus optional scope, e.g., `feat(pets): add QR generator view`. Bundle related files only; split multi-phase work by feature or layer. PRs should include a problem statement, bullet list of changes, screenshots or recordings for UI differences, and call out any Info.plist or asset work that the human must perform. Link backlog issues and note follow-ups explicitly.

## Agent-Specific Notes
Per `workflow_rules.md`, never edit Info.plist, entitlements, signing, or asset catalogs; instead, leave `// NOTE` reminders for required human action (camera usage, branding, etc.). Avoid introducing third-party packages unless explicitly asked. When making assumptions about data models or services, document them inline and sync major shifts back into `architecture.md`.
