//
//  DefaultQRCodeService.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation

struct DefaultQRCodeService: QRCodeServiceProtocol {
    private let context = CIContext()
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.encoder = encoder
        self.decoder = decoder
    }

    func generateQRCodeImage(from payload: PetQRCodePayload) throws -> CGImage {
        let data = try encoder.encode(payload)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        filter.correctionLevel = "M"

        guard let ciImage = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 12, y: 12)) else {
            throw QRCodeServiceError.encodingFailed
        }

        let inverted = ciImage
            .applyingFilter("CIColorInvert")
            .applyingFilter("CIColorControls", parameters: [
                kCIInputBrightnessKey: 1.0,
                kCIInputContrastKey: 1.0
            ])
            .applyingFilter("CIColorInvert")

        guard let cgImage = context.createCGImage(inverted, from: inverted.extent) else {
            throw QRCodeServiceError.encodingFailed
        }

        return cgImage
    }

    func parsePayload(from string: String) throws -> PetQRCodePayload {
        guard let data = string.data(using: .utf8) else {
            throw QRCodeServiceError.decodingFailed
        }

        do {
            return try decoder.decode(PetQRCodePayload.self, from: data)
        } catch {
            throw QRCodeServiceError.invalidPayload
        }
    }
}
