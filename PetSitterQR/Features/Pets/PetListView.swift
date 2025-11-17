//
//  PetListView.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import SwiftUI

struct PetListView: View {
    @StateObject private var viewModel: PetListViewModel

    @MainActor
    init(viewModel: PetListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    @MainActor
    init() {
        _viewModel = StateObject(wrappedValue: PetListViewModel())
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                switch viewModel.state {
                case .loading:
                    ProgressView("Loading pets…")
                        .padding(.top, 80)
                case .failed(let message):
                    EmptyStateView(
                        title: "Something went wrong",
                        message: message,
                        actionTitle: "Retry",
                        action: { Task { await viewModel.reload() } }
                    )
                    .padding(.top, 80)
                default:
                    contentList
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
        .sheet(item: $viewModel.editorState) { state in
            NavigationStack {
                PetEditorView(
                    pet: state.pet,
                    onSave: { viewModel.save(pet: $0) }
                )
            }
        }
        .task {
            await viewModel.loadPetsIfNeeded()
        }
    }

    @ViewBuilder
    private var contentList: some View {
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
                if let detailVM = PetDetailViewModel(petID: pet.id, listViewModel: viewModel) {
                    NavigationLink {
                        PetDetailView(viewModel: detailVM)
                    } label: {
                        PetRowView(
                            pet: pet,
                            editAction: { viewModel.edit(pet: pet) }
                        )
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.delete(pet: pet)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .accessibilityLabel("Delete \(pet.name)")
                    }
                }
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
                        .foregroundStyle(Color("NeutralTextSecondary"))

                    if pet.medicationInfo?.hasMeds == true {
                        TagPill(text: "Has meds")
                    } else {
                        TagPill(text: "No meds")
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(Color("NeutralTextSecondary"))
            }
        }
        .contextMenu {
            Button("Edit", systemImage: "pencil", action: editAction)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(pet.name), \(pet.ageDescription). \(pet.medicationInfo?.hasMeds == true ? "Has medications" : "No medications").")
    }
}

#if DEBUG
#Preview("Multiple pets") {
    NavigationStack {
        PetListView(viewModel: PetListViewModel(initialPets: PetSamples.mockPets))
    }
}
#endif
