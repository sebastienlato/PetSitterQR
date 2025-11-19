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
                VStack(spacing: 24) {
                    ProgressView("Loading pets…")
                        .tint(Color("BrandPrimary"))
                        .foregroundStyle(Color("NeutralTextSecondary"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            case .failed(let message):
                VStack {
                    EmptyStateView(
                        title: "Something went wrong",
                        message: message,
                        iconName: "exclamationmark.triangle.fill",
                        actionTitle: "Retry",
                        action: { Task { await viewModel.reload() } }
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            default:
                petList
            }
        }
        .background(Color("NeutralBackground").ignoresSafeArea())
        .navigationTitle("My Pets")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.clear, for: .navigationBar)
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
        List {
            if viewModel.pets.isEmpty {
                EmptyStateView(
                    title: "No pets yet",
                    message: "Add your first pet to generate a care card and QR code.",
                    iconName: "pawprint.fill",
                    actionTitle: "Add a pet",
                    action: { viewModel.addPetTapped() }
                )
                .padding(.vertical, 48)
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color("NeutralBackground"))
            } else {
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
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color("NeutralBackground"))
    }

}
#if DEBUG
#Preview("Multiple pets") {
    NavigationStack {
        PetListView(viewModel: PetListViewModel(initialPets: PetSamples.mockPets))
    }
}
#endif
