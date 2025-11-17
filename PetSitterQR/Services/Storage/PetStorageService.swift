//
//  PetStorageService.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import Foundation

protocol PetStorageServiceProtocol {
    func fetchPets() async throws -> [Pet]
    func savePet(_ pet: Pet) async throws
    func deletePet(_ pet: Pet) async throws
}

enum PetStorageServiceError: Error {
    case notFound
    case persistenceFailed
}
