//
//  PetListViewModel.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import SwiftUI

@MainActor
final class PetListViewModel: ObservableObject {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    @Published private(set) var pets: [Pet]
    @Published private(set) var state: LoadState
    @Published var editorState: EditorState?

    private let storageService: PetStorageServiceProtocol
    private var hasLoaded = false

    init(
        storageService: PetStorageServiceProtocol = InMemoryPetStorageService(initialPets: PetSamples.mockPets),
        initialPets: [Pet] = []
    ) {
        self.storageService = storageService
        self.pets = initialPets
        self.state = initialPets.isEmpty ? .idle : .loaded
        self.hasLoaded = !initialPets.isEmpty
    }

    func loadPetsIfNeeded() async {
        guard !hasLoaded else { return }
        await loadPets()
    }

    func reload() async {
        await loadPets(force: true)
    }

    private func loadPets(force: Bool = false) async {
        if force {
            hasLoaded = false
        }
        state = .loading
        do {
            let fetchedPets = try await storageService.fetchPets()
            pets = fetchedPets
            state = .loaded
            hasLoaded = true
        } catch {
            state = .failed("Unable to load pets. Please try again.")
        }
    }

    func binding(for pet: Pet) -> Binding<Pet>? {
        guard let index = pets.firstIndex(where: { $0.id == pet.id }) else {
            return nil
        }

        return Binding(
            get: { self.pets[index] },
            set: { self.pets[index] = $0 }
        )
    }

    func addPetTapped() {
        editorState = EditorState(mode: .add, pet: nil)
    }

    func edit(pet: Pet) {
        editorState = EditorState(mode: .edit, pet: pet)
    }

    func save(pet: Pet) {
        Task {
            do {
                try await storageService.savePet(pet)
                if let index = pets.firstIndex(where: { $0.id == pet.id }) {
                    pets[index] = pet
                } else {
                    pets.append(pet)
                }
                editorState = nil
                if state != .loaded {
                    state = .loaded
                }
            } catch {
                state = .failed("Unable to save pet. Please try again.")
            }
        }
    }

    func delete(pet: Pet) {
        Task {
            do {
                try await storageService.deletePet(pet)
                pets.removeAll(where: { $0.id == pet.id })
            } catch {
                state = .failed("Unable to delete pet.")
            }
        }
    }

    func cancelEditing() {
        editorState = nil
    }
}

extension PetListViewModel {
    struct EditorState: Identifiable {
        enum Mode {
            case add
            case edit
        }

        let id = UUID()
        let mode: Mode
        var pet: Pet?
    }
}
