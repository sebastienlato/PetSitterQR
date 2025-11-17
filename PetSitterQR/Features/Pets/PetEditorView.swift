//
//  PetEditorView.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import SwiftUI

struct PetEditorView: View {
    let pet: Pet?

    var body: some View {
        Form {
            Section("Editor Placeholder") {
                Text("Form fields will live here.")
            }
        }
        .navigationTitle(pet == nil ? "Add Pet" : "Edit Pet")
    }
}

#Preview {
    NavigationStack {
        PetEditorView(pet: .preview)
    }
}
