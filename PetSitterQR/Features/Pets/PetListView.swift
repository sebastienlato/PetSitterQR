//
//  PetListView.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import SwiftUI

struct PetListView: View {
    @StateObject private var viewModel: PetListViewModel
    @State private var selectedPet: Pet?

    @MainActor
    init(viewModel: PetListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    @MainActor
    init() {
        _viewModel = StateObject(wrappedValue: PetListViewModel())
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading pets…")
                    .tint(Color("BrandPrimary"))
                    .foregroundStyle(Color("NeutralTextSecondary"))
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
                petList
            }
        }
        .background(Color("NeutralBackground").ignoresSafeArea())
        .navigationTitle("My Pets")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.addPetTapped()
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color("BrandPrimary"))
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
        .navigationDestination(item: $selectedPet) { pet in
            if let detailVM = PetDetailViewModel(petID: pet.id, listViewModel: viewModel) {
                PetDetailView(viewModel: detailVM)
            }
        }
        .task {
            await viewModel.loadPetsIfNeeded()
        }
    }

    @ViewBuilder
    private var petList: some View {
        if viewModel.pets.isEmpty {
            EmptyStateView(
                title: "No pets yet",
                message: "Add your first pet to generate a care card and QR code.",
                actionTitle: "Add pet",
                action: { viewModel.addPetTapped() }
            )
            .padding(.top, 80)
        } else {
            List {
                ForEach(viewModel.pets) { pet in
                    if let detailVM = PetDetailViewModel(petID: pet.id, listViewModel: viewModel) {
                        Button {
                            selectedPet = pet
                        } label: {
                            PetRowView(
                                pet: pet,
                                showsChevron: false,
                                editAction: { viewModel.edit(pet: pet) },
                                deleteAction: { viewModel.delete(pet: pet) }
                            )
                            .listRowInsets(EdgeInsets())
                        }
                        .buttonStyle(.plain)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color("NeutralBackground"))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.delete(pet: pet)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(Color("BrandDanger"))
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color("NeutralBackground"))
        }
    }

}

private struct PetRowView: View {
    let pet: Pet
    let showsChevron: Bool
    let editAction: () -> Void
    let deleteAction: () -> Void

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

                if showsChevron {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color("NeutralTextSecondary"))
                }
            }
        }
        .contextMenu {
            Button("Edit", systemImage: "pencil", action: editAction)
            Button(role: .destructive) {
                deleteAction()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(Color("BrandDanger"))
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
