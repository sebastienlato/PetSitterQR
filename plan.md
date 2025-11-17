# Plan – PetSitterQR

## Project

- Name: PetSitterQR (rename if needed)
- Platform: iOS 26+
- IDE: Xcode 26
- UI: SwiftUI
- Architecture: SwiftUI + MVVM + services
- Concurrency: async/await

## Concept

PetSitterQR is an app that simplifies handing off pet care to friends, family, or sitters.

- The owner creates **pet profiles** with:
  - Pet picture
  - Name
  - Age
  - Feeding info
  - Medication info (if any)
  - Extra care notes
- The app generates a **QR code** for each pet.
- A sitter can **scan the QR code** to quickly see all care instructions on their device.

This app is about **quick sharing of critical care details** via QR codes.

## Constraints

- I always create the Xcode project myself and push it to GitHub.
  - Never tell Codex to “create a new project” or “run Xcode templates.”
  - Assume the project already exists.
- Do NOT modify:
  - Info.plist
  - entitlements
  - signing & capabilities
- Do NOT define:
  - Color assets
  - App icons
  - Image assets
- I will configure these manually in Xcode.

---

## Core Features (High-Level)

1. **Pet List**
   - List of pets with photo, name, and quick status (e.g., “Has meds”).
2. **Pet Detail & Editing**
   - Screen to view/edit:
     - Picture
     - Name
     - Age
     - Feeding instructions
     - Medication instructions
     - Extra care notes
3. **QR Code Generator**
   - Generates a QR code encoding the pet’s care info in a safe format (e.g., JSON).
   - Designed to be scanned by the same app (or a future companion app).
4. **QR Code Scanner**
   - SwiftUI-based scanner screen to detect QR codes.
   - On success: parses the payload into a **read-only view** of care info.
5. **Local Persistence**
   - Stores pet profiles on-device (e.g., SwiftData or Core Data).
   - Allows editing, deletion, and re-using pet cards.

---

## Phase 0 – Structure & Models

**Goal:** Define the project structure and core models for the app.

- [ ] Propose folder structure for:
  - App entry
  - Features (Pets, QR, Sharing)
  - Services (Storage, QR)
  - Models
  - Design system components
- [ ] Define core models:
  - `Pet`
  - `FeedingInfo`
  - `MedicationInfo`
  - `CareNotes`
  - `PetQRCodePayload`
- [ ] Define service protocols:
  - `PetStorageServiceProtocol`
  - `QRCodeServiceProtocol`
- [ ] Create placeholder Views (empty or simple text) for:
  - Pet list
  - Pet detail
  - Pet edit form
  - QR generator screen
  - QR scanner screen

**Deliverables:**

- Compiling project with placeholder types and minimal views.
- No real logic yet, just scaffolding.

---

## Phase 1 – Pet List & Detail UI

**Goal:** Make the app show and navigate between pets using mock data.

- [ ] Implement Pet list UI with mock pets.
- [ ] Implement Pet detail UI showing:
  - Picture placeholder
  - Name
  - Age
  - Feeding info
  - Meds info
  - Extra notes
- [ ] Add simple edit/create flows using in-memory data.
- [ ] Add SwiftUI previews for:
  - Pet list (multiple pets)
  - Pet detail (example pet with meds / no meds)

**Deliverables:**

- Pet list and detail screens with mock data.
- Navigation wired (e.g., `NavigationStack` from home to detail/edit).

---

## Phase 2 – ViewModels & State Management

**Goal:** Introduce MVVM and centralize state.

- [ ] Create ViewModels:
  - `PetListViewModel`
  - `PetDetailViewModel`
  - `PetEditorViewModel`
- [ ] Use `@MainActor` and `ObservableObject` for ViewModels.
- [ ] Manage pet collection in ViewModels (in-memory for now).
- [ ] Move business logic (add/edit/delete) out of Views and into ViewModels.

**Deliverables:**

- Views bound to ViewModels with published properties.
- Previews using mock ViewModels.

---

## Phase 3 – QR Code Generator & Scanner

**Goal:** Make QR-based sharing work end-to-end with local data.

- [ ] Implement `QRCodeServiceProtocol`:
  - Encode `PetQRCodePayload` into QR image data.
  - Decode from scanned string to `PetQRCodePayload`.
- [ ] Build QR generator UI:
  - Show QR code for the selected pet.
  - Clearly label what the QR contains.
- [ ] Build QR scanner UI:
  - Scan QR codes using modern iOS 26 APIs (Vision / camera).
  - Parse QR payload and show a **read-only care sheet** (no editing).
- [ ] Handle invalid QR codes gracefully.

**Deliverables:**

- Scanning and generating QR codes for pet profiles.
- Read-only “Pet Care Card” view from scanned QR.

---

## Phase 4 – Persistence & Polishing

**Goal:** Persist pet data locally and refine the UX.

- [ ] Implement `PetStorageServiceProtocol` using SwiftData or Core Data.
- [ ] Load pets at app launch and persist edits.
- [ ] Add empty states:
  - No pets yet.
  - No internet required (offline app, but mention if needed).
- [ ] Improve visual polish:
  - Card-like pet rows.
  - Clear tags for “Has meds”, “Special care”.

**Deliverables:**

- Persistent pet list.
- Polished UI with better layouts and microcopy.

---

## Phase 5 – Hardening & Extras

**Goal:** Clean up, make robust, and add nice-to-have details.

- [ ] Add optional features if time:
  - Share/export a pet’s care card as an image or PDF (design-only stubs if needed).
  - Sort pets (by name, species, etc.).
- [ ] Improve accessibility and Dynamic Type handling.
- [ ] Add tests for critical logic (e.g., QR encoding/decoding, storage service).

**Deliverables:**

- Stable app with core features solid.
- Suggested tests and future enhancements.

---

## Phase Rules

- Codex must **follow phases in order** and wait for my explicit “OK” before starting the next phase.
- At the end of each phase, Codex must:
  - Summarize changes.
  - List new/modified files.
  - Suggest a multi-line commit message for me to use manually.
