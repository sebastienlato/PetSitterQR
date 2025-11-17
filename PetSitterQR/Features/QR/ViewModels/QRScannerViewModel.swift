//
//  QRScannerViewModel.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import AVFoundation
import Combine
import SwiftUI

@MainActor
final class QRScannerViewModel: ObservableObject {
    enum ScanState: Equatable {
        case scanning
        case decoded(PetQRCodePayload)
        case failed(String)
    }

    enum ScannerAvailability: Equatable {
        case checking
        case ready
        case notSupported(String)
        case permissionDenied
        case unavailable(String)
    }

    @Published private(set) var scannerAvailability: ScannerAvailability = .checking
    @Published private(set) var state: ScanState = .scanning
    @Published var debugMessage: String?
    @Published private(set) var hasImportedCurrentPayload = false

    private let qrService: QRCodeServiceProtocol
    private var importHandler: ((PetQRCodePayload) -> Void)?

    init(
        qrService: QRCodeServiceProtocol? = nil,
        importHandler: ((PetQRCodePayload) -> Void)? = nil
    ) {
        self.qrService = qrService ?? DefaultQRCodeService()
        self.importHandler = importHandler
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
            Haptics.success()
            hasImportedCurrentPayload = false
        } catch {
            state = .failed("This code is not a valid PetSitterQR card.")
            Haptics.warning()
        }
    }

    func retry() {
        state = .scanning
        debugMessage = nil
        hasImportedCurrentPayload = false
    }

    func handleCameraError() {
        state = .failed("Unable to access the camera. Please check permissions and try again.")
        Haptics.warning()
    }

    func recordDetection(sourceDescription: String, payload: String?) {
#if DEBUG
        print("Detected barcode [\(sourceDescription)] payload: \(payload ?? "<none>")")
#endif
        debugMessage = "Last detected: \(payload ?? "n/a")"
    }

    func prepareScanner() async {
        scannerAvailability = .checking

        guard AVCaptureDevice.default(for: .video) != nil else {
            scannerAvailability = .notSupported("QR scanning requires a device with a camera.")
            return
        }

        let permissionGranted = await requestCameraAccessIfNeeded()
        guard permissionGranted else {
            scannerAvailability = .permissionDenied
            return
        }

        scannerAvailability = .ready
    }

    func importCurrentPayload() {
        guard case .decoded(let payload) = state, hasImportedCurrentPayload == false else { return }
        importHandler?(payload)
        hasImportedCurrentPayload = true
    }

    func setImportHandler(_ handler: @escaping (PetQRCodePayload) -> Void) {
        importHandler = handler
    }

    private func requestCameraAccessIfNeeded() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
}

#if DEBUG
extension QRScannerViewModel {
    func setPreviewState(_ state: ScanState) {
        self.state = state
    }
}
#endif
