//
//  QRScannerView.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import SwiftUI

struct QRScannerView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("QR Scanner")
                .font(.title3)
                .bold()

            Text("Point the camera at a PetSitterQR code.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            // NOTE: Requires NSCameraUsageDescription in Info.plist.
            // The human developer will configure permissions.
        }
        .padding()
        .navigationTitle("Scan QR")
    }
}

#Preview {
    NavigationStack {
        QRScannerView()
    }
}
