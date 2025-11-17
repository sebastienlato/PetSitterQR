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
                    .strokeBorder(.secondary.opacity(0.3), lineWidth: 1)
            )
            .shadow(radius: 2)
    }
}

struct GlassCard<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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
                    .foregroundStyle(.secondary)
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
                    .fill(.secondary.opacity(0.15))
            )
            .foregroundStyle(.secondary)
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

            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

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

                Text(message)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                content()
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
