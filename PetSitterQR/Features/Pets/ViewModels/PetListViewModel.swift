//
//  PetListViewModel.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import Combine
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
        storageService: PetStorageServiceProtocol? = nil,
        initialPets: [Pet] = []
    ) {
        self.storageService = storageService ?? InMemoryPetStorageService(initialPets: initialPets)
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
        await refreshPetsFromStore()
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
                await refreshPetsFromStore()
                editorState = nil
                Haptics.success()
            } catch {
                state = .failed("Unable to save pet. Please try again.")
                Haptics.warning()
            }
        }
    }

    func delete(pet: Pet) {
        Task {
            do {
                try await storageService.deletePet(pet)
                await refreshPetsFromStore()
                Haptics.success()
            } catch {
                state = .failed("Unable to delete pet.")
                Haptics.warning()
            }
        }
    }

    func cancelEditing() {
        editorState = nil
    }
    
    private func refreshPetsFromStore() async {
        state = .loading
        do {
            let fetchedPets = try await storageService.fetchPets()
            pets = fetchedPets
            state = fetchedPets.isEmpty ? .idle : .loaded
            hasLoaded = true
#if DEBUG
            print("PetListViewModel loaded \(fetchedPets.count) pets from storage")
#endif
        } catch {
            state = .failed("Unable to load pets. Please try again.")
        }
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
