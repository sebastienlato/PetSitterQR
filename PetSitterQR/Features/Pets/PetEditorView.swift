//
//  PetEditorView.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import SwiftUI

struct PetEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: PetEditorViewModel
    let onSave: (Pet) -> Void

    @MainActor
    init(pet: Pet?, onSave: @escaping (Pet) -> Void) {
        _viewModel = StateObject(wrappedValue: PetEditorViewModel(pet: pet))
        self.onSave = onSave
    }

    var body: some View {
        Form {
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
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    onSave(viewModel.buildPet())
                    Haptics.success()
                    dismiss()
                }
                .disabled(!viewModel.canSave)
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
