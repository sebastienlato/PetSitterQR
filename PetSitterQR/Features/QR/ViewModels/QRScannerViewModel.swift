//
//  QRScannerViewModel.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import Combine
import SwiftUI

@MainActor
final class QRScannerViewModel: ObservableObject {
    enum ScanState: Equatable {
        case scanning
        case decoded(PetQRCodePayload)
        case failed(String)
    }

    @Published private(set) var state: ScanState = .scanning

    private let qrService: QRCodeServiceProtocol

    init(qrService: QRCodeServiceProtocol? = nil) {
        self.qrService = qrService ?? DefaultQRCodeService()
    }

    var decodedPayload: PetQRCodePayload? {
        if case .decoded(let payload) = state {
            return payload
        }
        return nil
    }

    var instructions: String {
        "Point the camera at a PetSitterQR code."
    }

    func handleScannedString(_ string: String) {
        guard case .scanning = state else { return }
        do {
            let payload = try qrService.parsePayload(from: string)
            state = .decoded(payload)
        } catch {
            state = .failed("This code is not a valid PetSitterQR card.")
        }
    }

    func retry() {
        state = .scanning
    }

    func handleCameraError() {
        state = .failed("Unable to access the camera. Please check permissions and try again.")
    }
}

#if DEBUG
extension QRScannerViewModel {
    func setPreviewState(_ state: ScanState) {
        self.state = state
    }
}
#endif
