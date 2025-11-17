//
//  PetRowView.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import SwiftUI

struct PetRowView: View {
    let pet: Pet
    let editAction: () -> Void
    let deleteAction: () -> Void

    private var hasMedications: Bool {
        pet.medicationInfo?.hasMeds == true
    }

    var body: some View {
        GlassCard(background: Color("NeutralCard")) {
            HStack(spacing: 12) {
                PetAvatarView(size: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text(pet.name)
                        .font(.title3)
                        .foregroundStyle(Color("NeutralText"))

                    Text(pet.ageDescription)
                        .font(.subheadline)
                        .foregroundStyle(Color("NeutralTextSecondary"))

                    medsTag
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .contextMenu {
            Button("Edit", systemImage: "pencil", action: editAction)
            Button(role: .destructive) {
                deleteAction()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(Color("BrandDanger"))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(pet.name), \(pet.ageDescription). \(hasMedications ? "Has medications" : "No medications").")
    }

    private var medsTag: some View {
        if hasMedications {
            TagPill(
                text: "Has meds",
                background: Color("BrandPrimary"),
                foreground: Color("NeutralCard")
            )
        } else {
            TagPill(
                text: "No meds",
                background: Color("NeutralTextSecondary").opacity(0.12),
                foreground: Color("NeutralTextSecondary")
            )
        }
    }
}

#if DEBUG
#Preview("Pet row") {
    PetRowView(
        pet: PetSamples.mockPets[0],
        editAction: {},
        deleteAction: {}
    )
    .padding()
    .background(Color("NeutralBackground"))
}
#endif
