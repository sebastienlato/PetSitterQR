//
//  QRGeneratorView.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import SwiftUI

struct QRGeneratorView: View {
    @StateObject private var viewModel: QRGeneratorViewModel

    @MainActor
    init(viewModel: QRGeneratorViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                summaryCard
                qrCard
                instructions
            }
            .padding()
        }
        .background(Color("NeutralBackground").ignoresSafeArea())
        .navigationTitle("Share Care Card")
    }

    private var summaryCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.pet.name)
                    .font(.title2)
                    .bold()

                Text(viewModel.pet.ageDescription)
                    .foregroundStyle(Color("NeutralTextSecondary"))

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader("Feeding")
                    Text(viewModel.pet.feedingInfo.summary)
                        .foregroundStyle(Color("NeutralText"))
                }

                if viewModel.pet.medicationInfo?.hasMeds == true {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader("Medications")
                        if let description = viewModel.pet.medicationInfo?.description {
                            Text(description)
                        }
                        if let dosage = viewModel.pet.medicationInfo?.dosage {
                            Text("Dosage: \(dosage)")
                                .foregroundStyle(Color("NeutralTextSecondary"))
                        }
                    }
                }
            }
        }
    }

    private var qrCard: some View {
        QRCodeCard(
            title: "Share this care card",
            message: "Ask your sitter to open PetSitterQR and scan this code."
        ) {
            qrImageView
        }
    }

    @ViewBuilder
    private var qrImageView: some View {
        if let image = viewModel.qrImage {
            Image(decorative: image, scale: 1, orientation: .up)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color("BrandPrimaryLight"), lineWidth: 2)
                )
        } else if let error = viewModel.errorMessage {
            VStack(spacing: 12) {
                Text(error)
                    .foregroundStyle(Color("BrandDanger"))

                PrimaryButton(title: "Try again") {
                    viewModel.generateCode()
                }
            }
        } else {
            ProgressView()
                .tint(Color("BrandPrimary"))
                .frame(width: 80, height: 80)
        }
    }

    private var instructions: some View {
        Text("Anyone with this code can see the read-only care card. Avoid sensitive info you wouldn't share broadly.")
            .font(.footnote)
            .foregroundStyle(Color("NeutralTextSecondary"))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        QRGeneratorView(viewModel: QRGeneratorViewModel(pet: .preview))
    }
}
