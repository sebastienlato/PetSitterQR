# Components – PetSitterQR

Reusable components for the PetSitterQR app.  
Codex should prefer using or extending these instead of reinventing them.

---

## PetAvatarView

Displays a pet picture (or placeholder if missing).

```swift
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

NOTE: The actual image loading mechanism (from disk or photo picker) is handled elsewhere.

GlassCard

A generic card used across the app (pet list items, summaries, care card sections).

struct GlassCard<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}


Styling may be updated; keep it semantic, relying on system materials and colors.

PrimaryButton

A primary action button, typically full-width.

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

SectionHeader

Reusable header for sections like Feeding, Medications, Extra Notes.

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

TagPill

Used for labels like “Has meds”, “No meds”, “Special care”.

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

EmptyStateView

Standard empty-state component.

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
        .multilineTextAlignment(.center)
    }
}

QRCodeCard

Container for displaying QR codes with a short description.

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
                    .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
```
