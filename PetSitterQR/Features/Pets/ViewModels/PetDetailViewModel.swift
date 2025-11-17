//
//  PetDetailViewModel.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import Combine
import SwiftUI

@MainActor
final class PetDetailViewModel: ObservableObject {
    @Published private(set) var pet: Pet

    private let listViewModel: PetListViewModel
    private let petID: UUID
    private var cancellables = Set<AnyCancellable>()

    init?(petID: UUID, listViewModel: PetListViewModel) {
        guard let currentPet = listViewModel.pets.first(where: { $0.id == petID }) else {
            return nil
        }

        self.petID = petID
        self.listViewModel = listViewModel
        self.pet = currentPet

        listViewModel.$pets
            .sink { [weak self] pets in
                guard let self else { return }
                if let updatedPet = pets.first(where: { $0.id == petID }) {
                    self.pet = updatedPet
                }
            }
            .store(in: &cancellables)
    }

    var hasMedications: Bool {
        pet.medicationInfo?.hasMeds == true
    }

    var feedingSchedule: String? {
        pet.feedingInfo.schedule
    }

    var medicationDescription: String? {
        pet.medicationInfo?.description
    }

    var medicationDosage: String? {
        pet.medicationInfo?.dosage
    }

    var extraNotes: String? {
        pet.careNotes?.extraNotes
    }

    func editPet() {
        listViewModel.edit(pet: pet)
    }
}
