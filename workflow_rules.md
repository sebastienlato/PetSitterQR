---

### `workflow_rules.md`

```md
# Workflow Rules – PetSitterQR

## My Responsibilities (Human Developer)

I will:

- Create and configure the Xcode 26 project for iOS 26.
- Create and manage the Git repository and GitHub repo.
- Add:
  - App icons and other image assets.
  - Color assets and brand theming.
  - Info.plist keys (permissions, descriptions, etc.).
  - Signing & capabilities.
- Perform all `git commit` and `git push` actions.

Codex must **never**:

- Suggest creating a new Xcode project.
- Initialize Git or create a GitHub repo.
- Modify Info.plist, entitlements, or signing settings.
- Add or modify asset catalogs.

---

## Codex Responsibilities

Codex should:

- Implement SwiftUI Views and ViewModels.
- Implement core logic for:
  - Pet CRUD operations.
  - QR code generation and parsing.
  - QR scanning UI.
- Implement services for:
  - Local storage (SwiftData/Core Data).
  - QR code generation/parsing.
- Propose reusable components and utilities.
- Respect the architecture and UI guidelines.

Codex should **not**:

- Introduce third-party dependencies unless I explicitly request them.
- Write shell commands for setting up the project (beyond small examples if I ask).

---

## Info.plist & Permissions

- For QR scanning (camera usage):
  - Use camera APIs as needed.
  - Do **not** add Info.plist entries.
  - Instead, include comments such as:

// NOTE: Requires NSCameraUsageDescription in Info.plist.
// The human will add this manually in Xcode.
Same rule applies for any future features that require permissions.

Colors & Assets

Use only system/semantic colors (.primary, .secondary, .accentColor, etc.).

If a brand-specific color or asset is needed:

// TODO: Replace with custom brand color or asset added in Xcode.

Do not reference non-existent asset names.

Phases & Commits

Follow the phase structure defined in plan.md.

At the end of each phase:

Summarize the work done.

List key files created/updated.

Propose a multi-line commit message, e.g.:

feat(pets): scaffold pet list and detail

- add Pet model and example data for previews
- implement PetListView with basic styling and navigation to PetDetailView
- add PetDetailView showing feeding, meds, and extra care notes

Wait for my explicit go-ahead before moving to the next phase.

Refactors & Error Handling

When something breaks:

Explain the root cause clearly.

Suggest the minimal fix first.

For larger refactors:

Explain the motivation.

Outline the new structure before altering many files.

Assumptions

When something is not specified:

Make a reasonable assumption.

Document it briefly in code comments.

Example:

// Assumption: pet age is stored as a simple integer number of years.

Do not block progress waiting for clarification unless the behavior is impossible to infer.

```

```
