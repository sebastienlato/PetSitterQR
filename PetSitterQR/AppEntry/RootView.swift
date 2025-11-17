//
//  RootView.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import SwiftUI

struct RootView: View {
    @State private var selectedTab: RootTab = .pets

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                PetListView()
            }
            .tabItem {
                Label("Pets", systemImage: "pawprint")
            }
            .tag(RootTab.pets)

            NavigationStack {
                QRScannerView()
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

#Preview {
    RootView()
}
