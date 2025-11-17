//
//  PetDetailView.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import SwiftUI

struct PetDetailView: View {
    @StateObject private var viewModel: PetDetailViewModel

    init(viewModel: PetDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection

                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader("Feeding instructions", subtitle: viewModel.feedingSchedule)
                        Text(viewModel.pet.feedingInfo.summary)
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader("Medications")
                        medicationsContent
                    }
                }

                if let notes = viewModel.extraNotes, !notes.isEmpty {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            SectionHeader("Extra care notes")
                            Text(notes)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.pet.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    viewModel.editPet()
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
                PetAvatarView(size: 96)

                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.pet.name)
                        .font(.largeTitle)
                        .bold()

                    Text(viewModel.pet.ageDescription)
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    if viewModel.hasMedications {
                        TagPill(text: "Needs meds")
                    } else {
                        TagPill(text: "No meds")
                    }
                }
            }
        }
    }

    private var medicationsContent: some View {
        Group {
            if viewModel.hasMedications {
                VStack(alignment: .leading, spacing: 6) {
                    if let description = viewModel.medicationDescription {
                        Text(description)
                    }
                    if let dosage = viewModel.medicationDosage {
                        Text("Dosage: \(dosage)")
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Text("No medications required.")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview("Pet with meds") {
    let listVM = PetListViewModel(initialPets: PetSamples.mockPets)
    NavigationStack {
        if let detailVM = PetDetailViewModel(petID: PetSamples.mockPets[0].id, listViewModel: listVM) {
            PetDetailView(viewModel: detailVM)
        }
    }
}

#Preview("Pet without meds") {
    let pets = PetSamples.mockPets
    let listVM = PetListViewModel(initialPets: pets)
    NavigationStack {
        if let detailVM = PetDetailViewModel(petID: pets[1].id, listViewModel: listVM) {
            PetDetailView(viewModel: detailVM)
        }
    }
}
