---

### `ui_guidelines.md`

```md
# UI Guidelines – PetSitterQR

The app should feel simple, friendly, and trustworthy.  
Think: “handing your pet to someone with a clear care card.”

---

## Visual Style

- Use primarily system look and feel.
- Use **semantic/system colors** only:
  - `.primary`, `.secondary`, `.accentColor`, `.foregroundStyle(.primary)`, etc.
- When a custom brand color is appropriate:

// TODO: Replace with custom brand color in asset catalog (added manually in Xcode).
.foregroundStyle(.accentColor)

Do not define color assets or hard-code brand hex colors.

Layout

Use NavigationStack as the main navigation container.

Use ScrollView + LazyVStack for lists of cards (e.g., pets).

Use GlassCard / card components for pet items and care summaries.

Example layout patterns:

Pet list:

Scrollable list of pet cards.

Each card: avatar, name, age, small badge for “Meds”/“No meds.”

Pet detail:

Pet avatar at the top.

Sections:

Basic Info (name, age)

Feeding

Medication

Extra Notes

QR actions (Generate QR)

Ensure spacing and padding are consistent.

Text & Microcopy

Be direct and friendly:

“Feeding instructions”

“Medications”

“Extra care notes”

“Scan this QR to see all of my care info.”

Avoid technical jargon in user-facing text.

Lists & Cards

Use card components from components.md where possible:

GlassCard

SectionHeader

EmptyStateView

For empty states:

Pet list:
“No pets yet” → encourage user to add their first pet.

For QR scan result:

Show a styled Care Card view:

Name & age

Feeds

Meds

Extra care notes

QR Generator & Scanner Screens
QR Generator

Show:

A card summarizing the pet’s info.

The QR code centered, with padding.

Short instructions like “Ask your sitter to scan this code using PetSitterQR.”

QR Scanner

Clear scan frame (if using overlay).

Simple text:

“Point the camera at a PetSitterQR code.”

Error state text for invalid codes:

“This code doesn’t seem to be a valid PetSitterQR card.”

Animations

Use subtle animations:

Smooth transitions on list changes.

Small fades for QR appearance.

Use .animation(\_, value:) or withAnimation {} with reasonable durations (0.2–0.3s).

Avoid overly flashy effects.

Accessibility & Dynamic Type

Ensure text resizes nicely with Dynamic Type.

Avoid fixed heights where possible.

Labels:

Provide accessibilityLabel for icons, especially in QR and pet cards.

Tap targets:

Buttons and interactive areas should be at least ~44x44.

Device Adaptivity

On larger screens (e.g., iPad), consider:

Two-column layout: list on the left, detail/care card on the right.

Use frame(maxWidth: .infinity, alignment: .leading) rather than fixed widths to keep content adaptive.

Alerts & Sheets

Use modern SwiftUI APIs:

.sheet(isPresented:)

.alert(\_, isPresented:)

Example uses:

Confirm deletion of pet.

Show warnings when QR payload cannot be decoded.

The overall feel should be: calm, clear, and sitter-friendly.

```

```
