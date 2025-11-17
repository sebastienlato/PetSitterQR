//
//  InMemoryPetStorageService.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import Foundation

actor InMemoryPetStorageService: PetStorageServiceProtocol {
    private var storage: [UUID: Pet]

    init(initialPets: [Pet] = []) {
        self.storage = Dictionary(uniqueKeysWithValues: initialPets.map { ($0.id, $0) })
    }

    func fetchPets() async throws -> [Pet] {
        storage.values.sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })
    }

    func savePet(_ pet: Pet) async throws {
        storage[pet.id] = pet
    }

    func deletePet(_ pet: Pet) async throws {
        guard storage.removeValue(forKey: pet.id) != nil else {
            throw PetStorageServiceError.notFound
        }
    }
}
