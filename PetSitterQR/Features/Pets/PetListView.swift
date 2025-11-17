//
//  PetListView.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import SwiftUI

struct PetListView: View {
    @StateObject private var viewModel = PetListViewModel()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.pets.isEmpty {
                    EmptyStateView(
                        title: "No pets yet",
                        message: "Add your first pet to generate a care card and QR code.",
                        actionTitle: "Add pet",
                        action: { viewModel.addPetTapped() }
                    )
                    .padding(.top, 80)
                } else {
                    ForEach(viewModel.pets) { pet in
                        if let binding = viewModel.binding(for: pet) {
                            NavigationLink {
                                PetDetailView(
                                    pet: binding,
                                    onEdit: { viewModel.edit(pet: binding.wrappedValue) }
                                )
                            } label: {
                                PetRowView(
                                    pet: pet,
                                    editAction: { viewModel.edit(pet: pet) }
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 24)
        }
        .navigationTitle("My Pets")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.addPetTapped()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add pet")
            }
        }
        .sheet(item: $viewModel.editorState, onDismiss: {
            viewModel.cancelEditing()
        }) { state in
            NavigationStack {
                PetEditorView(
                    pet: state.pet,
                    onSave: { viewModel.save(pet: $0) }
                )
            }
        }
    }
}

private struct PetRowView: View {
    let pet: Pet
    let editAction: () -> Void

    var body: some View {
        GlassCard {
            HStack(spacing: 12) {
                PetAvatarView(size: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text(pet.name)
                        .font(.headline)

                    Text(pet.ageDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if pet.medicationInfo?.hasMeds == true {
                        TagPill(text: "Has meds")
                    } else {
                        TagPill(text: "No meds")
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }
        .contextMenu {
            Button("Edit", systemImage: "pencil", action: editAction)
        }
    }
}

#Preview("Multiple pets") {
    NavigationStack {
        PetListView()
    }
}
