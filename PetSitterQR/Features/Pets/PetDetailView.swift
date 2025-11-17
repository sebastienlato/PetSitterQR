//
//  PetDetailView.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import SwiftUI

struct PetDetailView: View {
    @Binding var pet: Pet
    let onEdit: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection

                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader("Feeding instructions", subtitle: pet.feedingInfo.schedule)
                        Text(pet.feedingInfo.summary)
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader("Medications")
                        medicationsContent
                    }
                }

                if let notes = pet.careNotes?.extraNotes, !notes.isEmpty {
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
        .navigationTitle(pet.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    onEdit()
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
                PetAvatarView(size: 96)

                VStack(alignment: .leading, spacing: 8) {
                    Text(pet.name)
                        .font(.largeTitle)
                        .bold()

                    Text(pet.ageDescription)
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    if pet.medicationInfo?.hasMeds == true {
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
            if pet.medicationInfo?.hasMeds == true {
                VStack(alignment: .leading, spacing: 6) {
                    if let description = pet.medicationInfo?.description {
                        Text(description)
                    }
                    if let dosage = pet.medicationInfo?.dosage {
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
    NavigationStack {
        PetDetailView(
            pet: .constant(.preview),
            onEdit: {}
        )
    }
}

#Preview("Pet without meds") {
    NavigationStack {
        PetDetailView(
            pet: .constant(.previewNoMeds),
            onEdit: {}
        )
    }
}
