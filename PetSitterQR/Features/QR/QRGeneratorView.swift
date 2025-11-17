//
//  QRGeneratorView.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import SwiftUI

struct QRGeneratorView: View {
    let pet: Pet

    var body: some View {
        VStack(spacing: 24) {
            Text("QR Generator")
                .font(.title2)
                .bold()

            Text("A QR code for \(pet.name) will render here.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("Share Care Card")
    }
}

#Preview {
    NavigationStack {
        QRGeneratorView(pet: .preview)
    }
}
