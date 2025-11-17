//
//  PetModels.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import Foundation

struct Pet: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var ageDescription: String
    var imageIdentifier: String?
    var feedingInfo: FeedingInfo
    var medicationInfo: MedicationInfo?
    var careNotes: CareNotes?

    init(
        id: UUID = UUID(),
        name: String,
        ageDescription: String,
        imageIdentifier: String? = nil,
        feedingInfo: FeedingInfo,
        medicationInfo: MedicationInfo? = nil,
        careNotes: CareNotes? = nil
    ) {
        self.id = id
        self.name = name
        self.ageDescription = ageDescription
        self.imageIdentifier = imageIdentifier
        self.feedingInfo = feedingInfo
        self.medicationInfo = medicationInfo
        self.careNotes = careNotes
    }
}

struct FeedingInfo: Codable, Equatable, Hashable {
    var summary: String
    var schedule: String?
}

struct MedicationInfo: Codable, Equatable, Hashable {
    var hasMeds: Bool
    var description: String?
    var dosage: String?
}

struct CareNotes: Codable, Equatable, Hashable {
    var extraNotes: String
}

struct PetQRCodePayload: Codable, Equatable, Hashable {
    var name: String
    var ageDescription: String
    var feedingSummary: String
    var medicationSummary: String?
    var extraNotes: String?

    init(
        name: String,
        ageDescription: String,
        feedingSummary: String,
        medicationSummary: String? = nil,
        extraNotes: String? = nil
    ) {
        self.name = name
        self.ageDescription = ageDescription
        self.feedingSummary = feedingSummary
        self.medicationSummary = medicationSummary
        self.extraNotes = extraNotes
    }

    init(pet: Pet) {
        let medicationSummary: String?
        if pet.medicationInfo?.hasMeds == true {
            var parts: [String] = []
            if let description = pet.medicationInfo?.description {
                parts.append(description)
            }
            if let dosage = pet.medicationInfo?.dosage {
                parts.append("Dosage: \(dosage)")
            }
            medicationSummary = parts.isEmpty ? "Requires medication." : parts.joined(separator: "\n")
        } else {
            medicationSummary = nil
        }

        let notes = pet.careNotes?.extraNotes.trimmingCharacters(in: .whitespacesAndNewlines)
        let extraNotes = notes?.isEmpty == false ? notes : nil

        var feedingSummary = pet.feedingInfo.summary
        if let schedule = pet.feedingInfo.schedule {
            feedingSummary += "\nSchedule: \(schedule)"
        }

        self.init(
            name: pet.name,
            ageDescription: pet.ageDescription,
            feedingSummary: feedingSummary,
            medicationSummary: medicationSummary,
            extraNotes: extraNotes
        )
    }
}

#if DEBUG
extension Pet {
    static var preview: Pet {
        Pet(
            name: "Luna",
            ageDescription: "3 years",
            feedingInfo: FeedingInfo(summary: "1 cup kibble twice a day", schedule: "8am / 6pm"),
            medicationInfo: MedicationInfo(hasMeds: true, description: "Allergy pill", dosage: "1 pill daily"),
            careNotes: CareNotes(extraNotes: "Loves gentle walks.")
        )
    }

    static var previewNoMeds: Pet {
        Pet(
            name: "Milo",
            ageDescription: "2 years",
            feedingInfo: FeedingInfo(summary: "Wet food in the morning", schedule: "7am"),
            medicationInfo: nil,
            careNotes: CareNotes(extraNotes: "Playtime every evening.")
        )
    }
}

enum PetSamples {
    static let mockPets: [Pet] = [
        .preview,
        .previewNoMeds,
        Pet(
            name: "Poppy",
            ageDescription: "6 months",
            feedingInfo: FeedingInfo(summary: "Puppy kibble three times per day", schedule: "7am / 12pm / 6pm"),
            medicationInfo: MedicationInfo(hasMeds: false, description: nil, dosage: nil),
            careNotes: CareNotes(extraNotes: "Still training – keep walks short.")
        )
    ]
}

extension PetQRCodePayload {
    static var preview: PetQRCodePayload {
        PetQRCodePayload(
            name: "Luna",
            ageDescription: "3 years",
            feedingSummary: "1 cup kibble twice daily",
            medicationSummary: "Allergy pill nightly",
            extraNotes: "Prefers ceramic bowls."
        )
    }
}
#endif
