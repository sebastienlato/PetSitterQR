//
//  RootView.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import SwiftData
import SwiftUI

struct RootView: View {
    @State private var selectedTab: RootTab = .pets
    @StateObject private var petListViewModel: PetListViewModel
    @StateObject private var scannerViewModel: QRScannerViewModel

    init(modelContext: ModelContext) {
        let storageService = LocalPetStorageService(context: modelContext)
        _petListViewModel = StateObject(wrappedValue: PetListViewModel(storageService: storageService))
        _scannerViewModel = StateObject(wrappedValue: QRScannerViewModel())
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                PetListView(viewModel: petListViewModel)
            }
            .tabItem {
                Label("Pets", systemImage: "pawprint")
            }
            .tag(RootTab.pets)

            NavigationStack {
                QRScannerView(viewModel: scannerViewModel)
            }
            .tabItem {
                Label("Scan", systemImage: "qrcode.viewfinder")
            }
            .tag(RootTab.scanner)
        }
    }
}

private enum RootTab {
    case pets
    case scanner
}

#if DEBUG
#Preview {
    let previewService = LocalPetStorageService.previewService(with: PetSamples.mockPets)
    return RootViewPreviewWrapper(storageService: previewService)
}

private struct RootViewPreviewWrapper: View {
    @StateObject var listViewModel: PetListViewModel
    @StateObject var scannerViewModel = QRScannerViewModel()

    init(storageService: PetStorageServiceProtocol) {
        _listViewModel = StateObject(wrappedValue: PetListViewModel(storageService: storageService))
    }

    var body: some View {
        TabView {
            NavigationStack {
                PetListView(viewModel: listViewModel)
            }
            NavigationStack {
                QRScannerView(viewModel: scannerViewModel)
            }
        }
    }
}
#endif
