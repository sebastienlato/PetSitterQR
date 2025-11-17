//
//  PetListView.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import SwiftUI

struct PetListView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Pet list will appear here.")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .navigationTitle("My Pets")
    }
}

#Preview {
    NavigationStack {
        PetListView()
    }
}
