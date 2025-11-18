//
//  PetDetailView.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import UIKit
import SwiftUI

struct PetDetailView: View {
    @StateObject private var viewModel: PetDetailViewModel
    @State private var avatarImage: UIImage?

    init(viewModel: PetDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroSection

                infoCard(
                    iconName: "fork.knife",
                    title: "Feeding",
                    subtitle: viewModel.feedingSchedule
                ) {
                    Text(viewModel.pet.feedingInfo.summary)
                        .foregroundStyle(Color("NeutralTextSecondary"))
                        .multilineTextAlignment(.leading)
                }

                infoCard(iconName: "pills", title: "Medications") {
                    medicationsContent
                }

                if let notes = viewModel.extraNotes, !notes.isEmpty {
                    infoCard(iconName: "note.text", title: "Extra care") {
                        Text(notes)
                            .foregroundStyle(Color("NeutralTextSecondary"))
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(Color("NeutralBackground").ignoresSafeArea())
        .navigationTitle(viewModel.pet.name)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                NavigationLink {
                    QRGeneratorView(viewModel: QRGeneratorViewModel(pet: viewModel.pet))
                } label: {
                    Image(systemName: "qrcode")
                }
                .tint(Color("BrandPrimary"))
                .accessibilityLabel("Share care card")

                Button("Edit") {
                    viewModel.editPet()
                }
                .foregroundStyle(Color("BrandPrimary"))
            }
        }
        .onAppear(perform: loadImage)
    }

    private var heroSection: some View {
        GlassCard(background: Color("NeutralCard")) {
            VStack(alignment: .center, spacing: 10) {
                PetAvatarView(
                    image: avatarImage.map { Image(uiImage: $0) },
                    size: 80,
                    showsEditBadge: true
                )
                .onTapGesture {
                    viewModel.editPet()
                }
                .accessibilityLabel("Edit pet photo")
                .accessibilityAddTraits(.isButton)

                Text(viewModel.pet.name)
                    .font(.title)
                    .bold()
                    .foregroundStyle(Color("NeutralText"))
                    .frame(maxWidth: .infinity, alignment: .center)

                Text(viewModel.pet.ageDescription)
                    .font(.subheadline)
                    .foregroundStyle(Color("NeutralTextSecondary"))
                    .frame(maxWidth: .infinity, alignment: .center)

                medsTag
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var medicationsContent: some View {
        Group {
            if viewModel.hasMedications {
                VStack(alignment: .leading, spacing: 8) {
                    if let description = viewModel.medicationDescription {
                        Text(description)
                            .foregroundStyle(medicationEmphasisColor(for: description))
                            .multilineTextAlignment(.leading)
                    }
                    if let dosage = viewModel.medicationDosage {
                        Text("Dosage: \(dosage)")
                            .foregroundStyle(Color("NeutralTextSecondary"))
                    }
                }
            } else {
                Text("No medications required.")
                    .foregroundStyle(Color("NeutralTextSecondary"))
            }
        }
    }

    private var medsTag: some View {
        if viewModel.hasMedications {
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

    private func medicationEmphasisColor(for text: String) -> Color {
        let lowercased = text.lowercased()
        if lowercased.contains("emergency") || lowercased.contains("alert") || lowercased.contains("critical") {
            return Color("BrandDanger")
        }
        if lowercased.contains("allerg") {
            return Color("BrandWarning")
        }
        return Color("NeutralText")
    }

    @ViewBuilder
    private func infoCard<Content: View>(
        iconName: String,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        GlassCard(background: Color("NeutralCard")) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: iconName)
                    .font(.title3)
                    .foregroundStyle(Color("BrandPrimary"))
                    .padding(10)
                    .background(
                        Circle()
                            .fill(Color("BrandPrimary").opacity(0.12))
                    )

                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title, subtitle: subtitle)
                    content()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func loadImage() {
        guard let identifier = viewModel.pet.imageIdentifier else {
            avatarImage = nil
            return
        }
        avatarImage = PetImageStore.shared.loadImage(for: identifier)
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
