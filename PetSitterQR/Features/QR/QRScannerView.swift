//
//  QRScannerView.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import AVFoundation
import SwiftUI
import UIKit

struct QRScannerView: View {
    @StateObject private var viewModel: QRScannerViewModel
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @State private var isScannerVisible = false

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
            scannerLayer
            overlayContent
        }
        .background(Color("NeutralBackgroundDark").ignoresSafeArea())
        .navigationTitle("Scan QR")
        .task {
            await viewModel.prepareScanner()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task { await viewModel.prepareScanner() }
            }
        }
        .onAppear {
            isScannerVisible = true
        }
        .onDisappear {
            isScannerVisible = false
        }
    }

    @ViewBuilder
    private var scannerLayer: some View {
        if viewModel.scannerAvailability == .ready {
            QRAVScannerView(
                viewModel: viewModel,
                isActive: isScannerVisible
            )
            .ignoresSafeArea()
        } else {
            Color("NeutralBackground").ignoresSafeArea()
        }
    }

    @ViewBuilder
    private var overlayContent: some View {
        VStack {
            Group {
                switch viewModel.scannerAvailability {
                case .checking:
                    ProgressView("Preparing camera…")
                        .foregroundStyle(Color("NeutralText"))
                        .tint(Color("BrandPrimary"))
                        .accessibilityLabel("Preparing camera")
                case .notSupported(let message):
                    scannerMessageView(
                        title: "Scanner unavailable",
                        message: message,
                        actions: [
                            ("Retry", { Task { await viewModel.prepareScanner() } })
                        ]
                    )
                case .permissionDenied:
                    scannerMessageView(
                        title: "Camera access needed",
                        message: "Enable camera permissions in Settings to scan QR codes.",
                        actions: [
                            ("Open Settings", { openSettings() })
                        ]
                    )
                case .unavailable(let message):
                    scannerMessageView(
                        title: "Camera busy",
                        message: message,
                        actions: [
                            ("Retry", { Task { await viewModel.prepareScanner() } })
                        ]
                    )
                case .ready:
                    VStack(spacing: 4) {
                        Text(viewModel.instructions)
                            .font(.subheadline)
                            .foregroundStyle(Color("NeutralText"))
                            .padding(.top, 24)
                            .padding(.horizontal)
                            .accessibilityAddTraits(.isHeader)

                        if let debug = viewModel.debugMessage {
                            Text(debug)
                                .font(.caption2)
                                .foregroundStyle(Color("NeutralTextSecondary"))
                        }
                    }
                }
            }

            Spacer()

            if viewModel.scannerAvailability == .ready {
                scanningStateContent
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.state)
        .animation(.easeInOut(duration: 0.25), value: viewModel.scannerAvailability)
    }

    @ViewBuilder
    private var scanningStateContent: some View {
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
                        Color("NeutralBackgroundDark").opacity(0.95),
                        Color("NeutralBackground").opacity(0.8)
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
                    PrimaryButton(title: "Retry scanning") {
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

    private func scannerMessageView(
        title: String,
        message: String,
        actions: [(title: String, action: () -> Void)]
    ) -> some View {
        GlassCard(background: Color("NeutralCard")) {
            VStack(spacing: 12) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color("NeutralText"))
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color("NeutralTextSecondary"))
                    .multilineTextAlignment(.center)
                    .accessibilityLabel(message)
                ForEach(actions.indices, id: \.self) { index in
                    PrimaryButton(title: actions[index].title, action: actions[index].action)
                }
            }
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
    }

    private func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(settingsURL)
    }
}

private struct QRAVScannerView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: QRScannerViewModel
    let isActive: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    func makeUIViewController(context: Context) -> CameraScannerViewController {
        CameraScannerViewController(
            viewModel: viewModel,
            coordinator: context.coordinator
        )
    }

    func updateUIViewController(_ controller: CameraScannerViewController, context: Context) {
        controller.updateCaptureState(
            shouldRun: viewModel.scannerAvailability == .ready && isActive,
            scanState: viewModel.state
        )
    }

    static func dismantleUIViewController(_ controller: CameraScannerViewController, coordinator: Coordinator) {
        controller.stopSession()
    }

    final class Coordinator: NSObject {
        let viewModel: QRScannerViewModel

        init(viewModel: QRScannerViewModel) {
            self.viewModel = viewModel
        }
    }
}

private final class CameraScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    private let viewModel: QRScannerViewModel
    private weak var coordinator: QRAVScannerView.Coordinator?
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "qr.scanner.session")
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var isConfigured = false
    private var isRunning = false

    init(viewModel: QRScannerViewModel, coordinator: QRAVScannerView.Coordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "NeutralBackgroundDark") ?? .black
        configureSessionIfNeeded()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    func updateCaptureState(shouldRun: Bool, scanState: QRScannerViewModel.ScanState) {
        switch scanState {
        case .scanning:
            if shouldRun {
                startSession()
            } else {
                stopSession()
            }
        case .decoded, .failed:
            stopSession()
        }
    }

    func stopSession() {
        guard isRunning else { return }
        sessionQueue.async {
            self.session.stopRunning()
            self.isRunning = false
        }
    }

    private func startSession() {
        configureSessionIfNeeded()
        guard !isRunning else { return }
        sessionQueue.async {
            guard !self.session.isRunning else { return }
            self.session.startRunning()
            self.isRunning = true
        }
    }

    private func configureSessionIfNeeded() {
        guard !isConfigured else { return }
        isConfigured = true
        session.beginConfiguration()

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            viewModel.handleCameraError()
            session.commitConfiguration()
            return
        }
        session.addInput(input)

        let metadataOutput = AVCaptureMetadataOutput()
        guard session.canAddOutput(metadataOutput) else {
            viewModel.handleCameraError()
            session.commitConfiguration()
            return
        }
        session.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
        session.commitConfiguration()
    }

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard case .scanning = viewModel.state else { return }
        guard let metadata = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              metadata.type == .qr,
              let value = metadata.stringValue else { return }
        viewModel.recordDetection(sourceDescription: "AVFoundation", payload: value)
        viewModel.handleScannedString(value)
        stopSession()
    }
}

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
