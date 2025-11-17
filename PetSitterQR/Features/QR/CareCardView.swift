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
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(payload.name)
                        .font(.title2)
                        .bold()
                        .foregroundStyle(Color("NeutralText"))

                    Text(payload.ageDescription)
                        .font(.subheadline)
                        .foregroundStyle(Color("NeutralTextSecondary"))
                }

                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader("Feeding instructions")
                    Text(payload.feedingSummary)
                }

                if let medicationSummary = payload.medicationSummary {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader("Medications")
                        Text(medicationSummary)
                            .foregroundStyle(Color("NeutralTextSecondary"))
                    }
                }

                if let extraNotes = payload.extraNotes {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader("Extra care notes")
                        Text(extraNotes)
                            .foregroundStyle(Color("NeutralTextSecondary"))
                    }
                }
            }
        }
    }
}

#Preview {
    CareCardView(payload: .preview)
}
