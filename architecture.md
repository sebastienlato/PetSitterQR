---

### `architecture.md`

```md
# Architecture – PetSitterQR

## Overview

PetSitterQR is built using **SwiftUI + MVVM + services**, targeting **iOS 26**.

Every feature should be:

- Structured by **feature modules**.
- Backed by **ViewModels**.
- Using **services** for persistence, QR generation, and scanning.

---

## Project Structure

Preferred structure:

```text
App/
  AppEntry/
    PetSitterQRApp.swift
    RootView.swift

  Features/
    Pets/
      PetListView.swift
      PetListViewModel.swift
      PetDetailView.swift
      PetDetailViewModel.swift
      PetEditorView.swift
      PetEditorViewModel.swift
      PetModels.swift
    QR/
      QRGeneratorView.swift
      QRScannerView.swift
      QRScannerViewModel.swift
      QRModels.swift
    CareCard/
      CareCardView.swift
      CareCardViewModel.swift

  Services/
    Storage/
      PetStorageServiceProtocol.swift
      LocalPetStorageService.swift
      MockPetStorageService.swift
    QRCode/
      QRCodeServiceProtocol.swift
      DefaultQRCodeService.swift
      MockQRCodeService.swift

  Models/
    Pet.swift
    FeedingInfo.swift
    MedicationInfo.swift
    CareNotes.swift
    PetQRCodePayload.swift

  DesignSystem/
    Components/
      GlassCard.swift
      PrimaryButton.swift
      SectionHeader.swift
      EmptyStateView.swift
      PetAvatarView.swift
    Layout/

  Utilities/
    Extensions/
Core Models

Pet

id (UUID)

name (String)

age (Int or String)

imageIdentifier (String? or data reference)

feedingInfo (FeedingInfo)

medicationInfo (MedicationInfo?)

careNotes (CareNotes?)

FeedingInfo

summary (String)

schedule (String?)

MedicationInfo

hasMeds (Bool)

description (String?)

dosage (String?)

CareNotes

extraNotes (String)

PetQRCodePayload

A subset of Pet fields suitable for QR:

name

age

feeding summary

meds summary

extra notes

Note: For QR payloads, avoid heavy binary data like full images. Use text-based info only.
```

View Layer

Each feature has Views responsible for:

Layout

Displaying formatted data

Handling user gestures and calling ViewModel intent methods

Patterns:

Use NavigationStack.

Use TabView only if needed (e.g., Pets / Scan).

Views declare dependencies on ViewModels via initializers:

struct PetListView: View {
@StateObject private var viewModel: PetListViewModel

    init(viewModel: PetListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        // ...
    }

}

ViewModel Layer

ViewModels:

@MainActor

Conform to ObservableObject

Keep UI state and expose actions/intents

Example:
@MainActor
final class PetListViewModel: ObservableObject {
@Published var pets: [Pet] = []
@Published var isLoading: Bool = false
@Published var errorMessage: String?

    private let storageService: PetStorageServiceProtocol

    init(storageService: PetStorageServiceProtocol) {
        self.storageService = storageService
    }

    func loadPets() async {
        isLoading = true
        defer { isLoading = false }

        do {
            pets = try await storageService.fetchPets()
        } catch {
            errorMessage = "Unable to load pets."
        }
    }

}
Services
Pet Storage Service

Protocol:

protocol PetStorageServiceProtocol {
func fetchPets() async throws -> [Pet]
func savePet(_ pet: Pet) async throws
func deletePet(_ pet: Pet) async throws
}

Implementation:

LocalPetStorageService backed by SwiftData or Core Data.

MockPetStorageService with in-memory pets for previews/tests.

QR Code Service

Protocol:

protocol QRCodeServiceProtocol {
func generateQRCodeImage(from payload: PetQRCodePayload) throws -> CGImage
func parsePayload(from string: String) throws -> PetQRCodePayload
}

Implementation:

Use JSON encoding for PetQRCodePayload.

Use system QR generation APIs.

Navigation

Use a root NavigationStack:

Entry point: Pet list.

From pet list:

Navigate to Pet detail.

Navigate to QR generator.

QR scanner can be accessed via:

A tab

Or a toolbar button (e.g., “Scan QR”)

Use identifiable navigation and simple route enums if needed.
Error Handling

ViewModels hold user-facing error strings or flags.

Views display friendly error states and retries.

QR scanner must handle “invalid QR” gracefully with a clear message.

Previews

Every View should have at least one Preview.

Use mock services and sample pets.

Show important states:

No pets

One pet

Multiple pets

Pet with meds vs no meds

QR code generated state

QR scanner error state (if applicable)
