//
//  QRGeneratorViewModel.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import Combine
import CoreGraphics
import SwiftUI

@MainActor
final class QRGeneratorViewModel: ObservableObject {
    let pet: Pet
    private let qrService: QRCodeServiceProtocol

    @Published private(set) var qrImage: CGImage?
    @Published private(set) var errorMessage: String?

    init(
        pet: Pet,
        qrService: QRCodeServiceProtocol? = nil
    ) {
        self.pet = pet
        self.qrService = qrService ?? DefaultQRCodeService()
        generateCode()
    }

    var payload: PetQRCodePayload {
        PetQRCodePayload(pet: pet)
    }

    func generateCode() {
        do {
            qrImage = try qrService.generateQRCodeImage(from: payload)
            errorMessage = nil
        } catch {
            errorMessage = "Unable to generate QR code right now."
            qrImage = nil
        }
    }
}
