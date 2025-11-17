//
//  QRCodeService.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import CoreGraphics

protocol QRCodeServiceProtocol {
    func generateQRCodeImage(from payload: PetQRCodePayload) throws -> CGImage
    func parsePayload(from string: String) throws -> PetQRCodePayload
}

enum QRCodeServiceError: Error {
    case encodingFailed
    case decodingFailed
    case invalidPayload
}
