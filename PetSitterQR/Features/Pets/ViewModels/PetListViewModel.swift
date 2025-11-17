//
//  PetListViewModel.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import SwiftUI

@MainActor
final class PetListViewModel: ObservableObject {
    @Published private(set) var pets: [Pet]
    @Published var editorState: EditorState?

    init(pets: [Pet] = PetSamples.mockPets) {
        self.pets = pets
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
        if let index = pets.firstIndex(where: { $0.id == pet.id }) {
            pets[index] = pet
        } else {
            pets.append(pet)
        }
        editorState = nil
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
