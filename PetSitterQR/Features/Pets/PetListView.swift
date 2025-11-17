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
                VStack(alignment: .leading, spacing: 24) {
                    header
                    ProgressView("Loading pets…")
                        .tint(Color("BrandPrimary"))
                        .foregroundStyle(Color("NeutralTextSecondary"))
                        .padding(.top, 32)
                }
                .padding(.horizontal, 16)
            case .failed(let message):
                VStack(alignment: .leading, spacing: 24) {
                    header
                    EmptyStateView(
                        title: "Something went wrong",
                        message: message,
                        iconName: "exclamationmark.triangle.fill",
                        actionTitle: "Retry",
                        action: { Task { await viewModel.reload() } }
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            default:
                petList
            }
        }
        .background(Color("NeutralBackground").ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
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
        VStack(alignment: .leading, spacing: 16) {
            header

            if viewModel.pets.isEmpty {
                EmptyStateView(
                    title: "No pets yet",
                    message: "Add your first pet to generate a care card and QR code.",
                    iconName: "pawprint.fill",
                    actionTitle: "Add a pet",
                    action: { viewModel.addPetTapped() }
                )
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            } else {
                List {
                    ForEach(viewModel.pets) { pet in
                        if PetDetailViewModel(petID: pet.id, listViewModel: viewModel) != nil {
                            Button {
                                selectedPet = pet
                            } label: {
                                PetRowView(
                                    pet: pet,
                                    editAction: { viewModel.edit(pet: pet) },
                                    deleteAction: { viewModel.delete(pet: pet) }
                                )
                                .padding(.horizontal, 16)
                                .padding(.vertical, 4)
                                .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .listRowInsets(EdgeInsets())
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
        .padding(.top, 12)
    }

    private var header: some View {
        Text("My Pets")
            .font(.largeTitle)
            .bold()
            .foregroundStyle(Color("NeutralText"))
            .padding(.horizontal, 16)
            .padding(.top, 8)
    }
}

#if DEBUG
#Preview("Multiple pets") {
    NavigationStack {
        PetListView(viewModel: PetListViewModel(initialPets: PetSamples.mockPets))
    }
}
#endif
