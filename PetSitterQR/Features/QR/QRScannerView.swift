//
//  QRScannerView.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import SwiftUI
#if canImport(Vision)
import Vision
#endif
#if canImport(VisionKit)
import VisionKit
#endif

struct QRScannerView: View {
    @StateObject private var viewModel: QRScannerViewModel

    @MainActor
    init(viewModel: QRScannerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    @MainActor
    init() {
        _viewModel = StateObject(wrappedValue: QRScannerViewModel())
    }

    var body: some View {
        ZStack {
            scannerContent
            overlayContent
        }
        .background(Color.black.opacity(0.8))
        .navigationTitle("Scan QR")
    }

    @ViewBuilder
    private var scannerContent: some View {
#if canImport(VisionKit)
        if #available(iOS 17.0, *) {
            if DataScannerViewController.isSupported {
                QRDataScannerView(viewModel: viewModel)
                    .ignoresSafeArea()
            } else {
                unsupportedScanner
            }
        } else {
            unsupportedScanner
        }
#else
        unsupportedScanner
#endif
    }

    private var unsupportedScanner: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.largeTitle)
                .foregroundStyle(Color("NeutralTextSecondary"))

            Text("QR scanning is not supported on this device.")
                .multilineTextAlignment(.center)
                .foregroundStyle(Color("NeutralTextSecondary"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("NeutralBackground"))
    }

    @ViewBuilder
    private var overlayContent: some View {
        VStack {
            Text(viewModel.instructions)
                .font(.subheadline)
                .foregroundStyle(.white)
                .padding(.top, 24)
                .padding(.horizontal)

            Spacer()

            switch viewModel.state {
            case .decoded(let payload):
                VStack(spacing: 16) {
                    CareCardView(payload: payload)
                    PrimaryButton(title: "Scan another code") {
                        viewModel.retry()
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.6),
                            Color.black.opacity(0.3)
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .ignoresSafeArea(edges: .bottom)
                )
            case .failed(let message):
                GlassCard(background: Color("NeutralCard")) {
                    VStack(spacing: 12) {
                        Text(message)
                            .foregroundStyle(Color("BrandDanger"))
                        PrimaryButton(title: "Try again") {
                            viewModel.retry()
                        }
                    }
                }
                .padding()
            case .scanning:
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color("BrandPrimaryLight"), lineWidth: 3)
                    .frame(width: 260, height: 260)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.clear)
                    )
                    .padding(.bottom, 120)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.state)
    }
}

#if canImport(VisionKit)
@available(iOS 17.0, *)
private struct QRDataScannerView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: QRScannerViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let controller = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.qr])],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true
        )
        controller.delegate = context.coordinator

        // NOTE: Requires NSCameraUsageDescription in Info.plist.
        // The human developer must add the camera permission copy in Xcode.
        try? controller.startScanning()
        return controller
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        switch viewModel.state {
        case .decoded, .failed:
            uiViewController.stopScanning()
        case .scanning:
            try? uiViewController.startScanning()
        }
    }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let parent: QRDataScannerView

        init(parent: QRDataScannerView) {
            self.parent = parent
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd recognizedItems: [RecognizedItem]) {
            for item in recognizedItems {
                guard case .barcode(let barcode) = item,
                      let payload = barcode.payloadStringValue else { continue }
                parent.viewModel.handleScannedString(payload)
            }
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didFailWithError error: Error) {
            parent.viewModel.handleCameraError()
        }
    }
}
#endif

#Preview("Scanning") {
    NavigationStack {
        QRScannerView(viewModel: QRScannerViewModel())
    }
}

#if DEBUG
#Preview("Decoded Payload") {
    let vm = QRScannerViewModel()
    vm.setPreviewState(.decoded(.preview))
    return NavigationStack {
        QRScannerView(viewModel: vm)
    }
}
#endif
