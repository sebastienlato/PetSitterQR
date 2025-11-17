//
//  PetModels.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import Foundation

struct Pet: Identifiable, Codable, Equatable {
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

struct FeedingInfo: Codable, Equatable {
    var summary: String
    var schedule: String?
}

struct MedicationInfo: Codable, Equatable {
    var hasMeds: Bool
    var description: String?
    var dosage: String?
}

struct CareNotes: Codable, Equatable {
    var extraNotes: String
}

struct PetQRCodePayload: Codable, Equatable {
    var name: String
    var ageDescription: String
    var feedingSummary: String
    var medicationSummary: String?
    var extraNotes: String?
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
#endif
