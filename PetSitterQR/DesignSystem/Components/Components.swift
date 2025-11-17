//
//  Components.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import SwiftUI

struct PetAvatarView: View {
    let image: Image?
    let size: CGFloat

    init(image: Image? = nil, size: CGFloat = 64) {
        self.image = image
        self.size = size
    }

    var body: some View {
        (image ?? Image(systemName: "pawprint.fill"))
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .strokeBorder(Color("NeutralTextSecondary").opacity(0.4), lineWidth: 1)
            )
            .shadow(color: Color("NeutralText").opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

struct GlassCard<Content: View>: View {
    let background: Color
    let content: () -> Content

    init(
        background: Color = Color("NeutralCard"),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.background = background
        self.content = content
    }

    var body: some View {
        content()
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color("BrandPrimary").opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color("BrandPrimary"))
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String?

    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color("NeutralTextSecondary"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TagPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color("NeutralBackground"))
            )
            .foregroundStyle(Color("NeutralTextSecondary"))
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.title3)
                .bold()
                .foregroundStyle(Color("NeutralText"))

            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color("NeutralTextSecondary"))

            if let actionTitle, let action {
                PrimaryButton(title: actionTitle, action: action)
                    .padding(.top, 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct QRCodeCard<Content: View>: View {
    let title: String
    let message: String
    let content: () -> Content

    init(
        title: String,
        message: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.message = message
        self.content = content
    }

    var body: some View {
        GlassCard {
            VStack(spacing: 12) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color("NeutralText"))

                Text(message)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color("NeutralTextSecondary"))

                content()
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
