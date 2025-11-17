//
//  PetEditorViewModel.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import Foundation

@MainActor
final class PetEditorViewModel: ObservableObject {
    @Published var name: String
    @Published var ageDescription: String
    @Published var feedingSummary: String
    @Published var feedingSchedule: String
    @Published var hasMedications: Bool
    @Published var medicationDescription: String
    @Published var medicationDosage: String
    @Published var extraNotes: String

    private let originalID: UUID?
    private let originalImageIdentifier: String?

    init(pet: Pet?) {
        self.originalID = pet?.id
        self.originalImageIdentifier = pet?.imageIdentifier

        self.name = pet?.name ?? ""
        self.ageDescription = pet?.ageDescription ?? ""
        self.feedingSummary = pet?.feedingInfo.summary ?? ""
        self.feedingSchedule = pet?.feedingInfo.schedule ?? ""

        let meds = pet?.medicationInfo
        self.hasMedications = meds?.hasMeds ?? false
        self.medicationDescription = meds?.description ?? ""
        self.medicationDosage = meds?.dosage ?? ""

        self.extraNotes = pet?.careNotes?.extraNotes ?? ""
    }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !feedingSummary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isEditing: Bool {
        originalID != nil
    }

    func buildPet() -> Pet {
        let feedingInfo = FeedingInfo(
            summary: feedingSummary,
            schedule: feedingSchedule.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : feedingSchedule
        )

        let medicationInfo: MedicationInfo?
        if hasMedications {
            medicationInfo = MedicationInfo(
                hasMeds: true,
                description: medicationDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : medicationDescription,
                dosage: medicationDosage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : medicationDosage
            )
        } else {
            medicationInfo = nil
        }

        let careNotes = extraNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : CareNotes(extraNotes: extraNotes)

        return Pet(
            id: originalID ?? UUID(),
            name: name,
            ageDescription: ageDescription,
            imageIdentifier: originalImageIdentifier,
            feedingInfo: feedingInfo,
            medicationInfo: medicationInfo,
            careNotes: careNotes
        )
    }
}
