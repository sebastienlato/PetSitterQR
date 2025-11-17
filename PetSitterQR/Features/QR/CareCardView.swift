//
//  CareCardView.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import SwiftUI

struct CareCardView: View {
    let payload: PetQRCodePayload

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(payload.name)
                .font(.title2)
                .bold()

            Text(payload.feedingSummary)
                .font(.body)

            if let medicationSummary = payload.medicationSummary {
                Text(medicationSummary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let extraNotes = payload.extraNotes {
                Text(extraNotes)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}

#Preview {
    CareCardView(
        payload: PetQRCodePayload(
            name: "Luna",
            ageDescription: "3 years",
            feedingSummary: "1 cup kibble twice daily",
            medicationSummary: "Allergy pill nightly",
            extraNotes: "Prefers ceramic bowls."
        )
    )
}
