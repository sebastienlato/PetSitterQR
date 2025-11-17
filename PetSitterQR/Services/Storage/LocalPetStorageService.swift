//
//  LocalPetStorageService.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import Foundation
import SwiftData

@Model
final class PersistedPet {
    @Attribute(.unique) var id: UUID
    var name: String
    var ageDescription: String
    var imageIdentifier: String?
    var feedingSummary: String
    var feedingSchedule: String?
    var hasMedications: Bool
    var medicationDescription: String?
    var medicationDosage: String?
    var extraNotes: String?

    init(
        id: UUID,
        name: String,
        ageDescription: String,
        imageIdentifier: String?,
        feedingSummary: String,
        feedingSchedule: String?,
        hasMedications: Bool,
        medicationDescription: String?,
        medicationDosage: String?,
        extraNotes: String?
    ) {
        self.id = id
        self.name = name
        self.ageDescription = ageDescription
        self.imageIdentifier = imageIdentifier
        self.feedingSummary = feedingSummary
        self.feedingSchedule = feedingSchedule
        self.hasMedications = hasMedications
        self.medicationDescription = medicationDescription
        self.medicationDosage = medicationDosage
        self.extraNotes = extraNotes
    }
}

extension PersistedPet {
    convenience init(pet: Pet) {
        self.init(
            id: pet.id,
            name: pet.name,
            ageDescription: pet.ageDescription,
            imageIdentifier: pet.imageIdentifier,
            feedingSummary: pet.feedingInfo.summary,
            feedingSchedule: pet.feedingInfo.schedule,
            hasMedications: pet.medicationInfo?.hasMeds ?? false,
            medicationDescription: pet.medicationInfo?.description,
            medicationDosage: pet.medicationInfo?.dosage,
            extraNotes: pet.careNotes?.extraNotes
        )
    }

    func update(from pet: Pet) {
        name = pet.name
        ageDescription = pet.ageDescription
        imageIdentifier = pet.imageIdentifier
        feedingSummary = pet.feedingInfo.summary
        feedingSchedule = pet.feedingInfo.schedule
        hasMedications = pet.medicationInfo?.hasMeds ?? false
        medicationDescription = pet.medicationInfo?.description
        medicationDosage = pet.medicationInfo?.dosage
        extraNotes = pet.careNotes?.extraNotes
    }

    func toDomain() -> Pet {
        Pet(
            id: id,
            name: name,
            ageDescription: ageDescription,
            imageIdentifier: imageIdentifier,
            feedingInfo: FeedingInfo(summary: feedingSummary, schedule: feedingSchedule),
            medicationInfo: hasMedications ? MedicationInfo(
                hasMeds: true,
                description: medicationDescription,
                dosage: medicationDosage
            ) : nil,
            careNotes: extraNotes.map { CareNotes(extraNotes: $0) }
        )
    }
}

@MainActor
final class LocalPetStorageService: PetStorageServiceProtocol {
    private let context: ModelContext
    private let imageStore: PetImageStore

    init(context: ModelContext, imageStore: PetImageStore = .shared) {
        self.context = context
        self.imageStore = imageStore
#if DEBUG
        print("LocalPetStorageService initialized with context \(context)")
#endif
    }

    func fetchPets() async throws -> [Pet] {
        let descriptor = FetchDescriptor<PersistedPet>(
            sortBy: [SortDescriptor(\PersistedPet.name, order: .forward)]
        )
        do {
            let results = try context.fetch(descriptor)
#if DEBUG
            print("LocalPetStorageService fetched \(results.count) pets")
#endif
            return results.map { $0.toDomain() }
        } catch {
            throw PetStorageServiceError.persistenceFailed
        }
    }

    func savePet(_ pet: Pet) async throws {
        do {
            if let existing = try fetchPersistedPet(by: pet.id) {
                let oldIdentifier = existing.imageIdentifier
                existing.update(from: pet)
                if let oldIdentifier, oldIdentifier != pet.imageIdentifier {
                    try? imageStore.deleteImage(for: oldIdentifier)
                }
            } else {
                context.insert(PersistedPet(pet: pet))
            }
            try context.save()
#if DEBUG
            print("LocalPetStorageService saved pet \(pet.name)")
#endif
        } catch {
            throw PetStorageServiceError.persistenceFailed
        }
    }

    func deletePet(_ pet: Pet) async throws {
        do {
            guard let existing = try fetchPersistedPet(by: pet.id) else {
                throw PetStorageServiceError.notFound
            }
            if let imageIdentifier = existing.imageIdentifier {
                try? imageStore.deleteImage(for: imageIdentifier)
            }
            context.delete(existing)
            try context.save()
#if DEBUG
            print("LocalPetStorageService deleted pet \(pet.name)")
#endif
        } catch let error as PetStorageServiceError {
            throw error
        } catch {
            throw PetStorageServiceError.persistenceFailed
        }
    }

    private func fetchPersistedPet(by id: UUID) throws -> PersistedPet? {
        let predicate = #Predicate<PersistedPet> { $0.id == id }
        var descriptor = FetchDescriptor<PersistedPet>(predicate: predicate)
        descriptor.fetchLimit = 1
        let results = try context.fetch(descriptor)
        return results.first
    }
}

#if DEBUG
extension LocalPetStorageService {
    static func previewService(with pets: [Pet] = []) -> LocalPetStorageService {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let schema = Schema([PersistedPet.self])
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        let service = LocalPetStorageService(context: container.mainContext)
        pets.forEach { pet in
            container.mainContext.insert(PersistedPet(pet: pet))
        }
        try? container.mainContext.save()
        return service
    }
}
#endif
