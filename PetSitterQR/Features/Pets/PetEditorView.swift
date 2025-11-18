//
//  PetEditorView.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import PhotosUI
import UIKit
import SwiftUI

struct PetEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: PetEditorViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var avatarImage: UIImage?
    let onSave: (Pet) -> Void

    @MainActor
    init(pet: Pet?, onSave: @escaping (Pet) -> Void) {
        _viewModel = StateObject(wrappedValue: PetEditorViewModel(pet: pet))
        self.onSave = onSave
    }

    var body: some View {
        Form {
            Section {
                VStack(spacing: 12) {
                    PhotosPicker(
                        selection: $selectedPhotoItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        PetAvatarView(
                            image: avatarImage.map { Image(uiImage: $0) },
                            size: 96,
                            showsEditBadge: true
                        )
                            .frame(maxWidth: .infinity, alignment: .center)
                            .onTapGesture {
                                Haptics.light()
                            }
                    }
                    // NOTE: Ensure NSPhotoLibraryUsageDescription is set in Info settings.

                    if avatarImage != nil {
                        Button("Remove photo") {
                            removePhoto()
                        }
                        .foregroundStyle(Color("BrandDanger"))
                        .font(.subheadline)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowBackground(Color("NeutralBackground"))
            }

            Section("Pet info") {
                TextField("Name", text: $viewModel.name)
                TextField("Age description", text: $viewModel.ageDescription)
            }

            Section("Feeding") {
                TextField("Summary", text: $viewModel.feedingSummary, axis: .vertical)
                TextField("Schedule (optional)", text: $viewModel.feedingSchedule)
            }

            Section("Medications") {
                Toggle("Requires medication", isOn: $viewModel.hasMedications)
                if viewModel.hasMedications {
                    TextField("Medication description", text: $viewModel.medicationDescription, axis: .vertical)
                    TextField("Dosage / schedule", text: $viewModel.medicationDosage)
                }
            }

            Section("Extra care notes") {
                TextEditor(text: $viewModel.extraNotes)
                    .frame(minHeight: 120)
            }
        }
        .navigationTitle(viewModel.isEditing ? "Edit Pet" : "Add Pet")
        .tint(Color("BrandPrimary"))
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .background(Color("NeutralBackground"))
        .onAppear(perform: loadExistingImage)
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            handlePhotoSelection(item: newItem)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundStyle(Color("NeutralTextSecondary"))
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    onSave(viewModel.buildPet())
                    Haptics.success()
                    dismiss()
                }
                .disabled(!viewModel.canSave)
                .foregroundStyle(Color("BrandPrimary"))
            }
        }
    }
}

#Preview("Add pet") {
    NavigationStack {
        PetEditorView(pet: nil) { _ in }
    }
}

#Preview("Edit pet") {
    NavigationStack {
        PetEditorView(pet: .preview) { _ in }
    }
}

private extension PetEditorView {
    func loadExistingImage() {
        guard let identifier = viewModel.imageIdentifier else { return }
        avatarImage = PetImageStore.shared.loadImage(for: identifier)
    }

    func handlePhotoSelection(item: PhotosPickerItem) {
        Task {
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else {
                return
            }

            let resized = uiImage.downscaled(to: 512)
            let identifier = viewModel.imageIdentifier ?? UUID().uuidString

            do {
                if let oldIdentifier = viewModel.imageIdentifier, oldIdentifier != identifier {
                    try? PetImageStore.shared.deleteImage(for: oldIdentifier)
                }
                try PetImageStore.shared.saveImage(resized, for: identifier)
                await MainActor.run {
                    viewModel.updateImageIdentifier(identifier)
                    avatarImage = resized
                }
            } catch {
                // Intentionally silent for now; consider surfacing error UI later.
                return
            }
        }
    }

    func removePhoto() {
        if let identifier = viewModel.imageIdentifier {
            try? PetImageStore.shared.deleteImage(for: identifier)
        }
        viewModel.updateImageIdentifier(nil)
        avatarImage = nil
        selectedPhotoItem = nil
    }
}

private extension UIImage {
    func downscaled(to maxDimension: CGFloat) -> UIImage {
        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else { return self }

        let scale = maxDimension / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
