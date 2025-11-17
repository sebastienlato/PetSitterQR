//
//  PetDetailView.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import SwiftUI

struct PetDetailView: View {
    let pet: Pet

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(pet.name)
                    .font(.largeTitle)
                    .bold()

                Text("Detail layout coming soon.")
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("Pet Details")
    }
}

#Preview {
    NavigationStack {
        PetDetailView(pet: .preview)
    }
}
