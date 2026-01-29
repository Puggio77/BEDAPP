//
//  LoggingView.swift
//  BEDAPP
//
//  Created by Alberto Besne Cabrera on 27/01/26.
//

import SwiftUI

struct LoggingView: View {
    var episodeStartDate: Date = Date()
    var episodeEndDate: Date = Date()

    private var episodeDurationFormatted: String {
        let interval = episodeEndDate.timeIntervalSince(episodeStartDate)
        let minutes = max(0, Int(interval) / 60)
        let seconds = max(0, Int(interval) % 60)
        if minutes > 0 {
            return "\(minutes) min \(seconds) s"
        }
        return "\(seconds) s"
    }

    // Más emociones/sentimientos
    static let triggerOptions = [
        "Anxiety", "Boredom", "Sadness", "Stress", "Loneliness",
        "Anger", "Frustration", "Tiredness", "Overwhelm", "Social pressure",
        "Happiness", "Celebration", "Nervousness", "Worry", "Emptiness",
        "Guilt", "Shame", "Fear", "Restlessness", "Confusion",
        "Disappointment", "Jealousy", "Excitement", "Relief", "Numbness"
    ]
    static let locationOptions = ["Home", "Work", "Gym", "School", "Restaurant", "Car", "Street", "Friends' place", "Other"]

    // Urge to eat: single select, SF Symbols
    static let urgeToEatOptions: [(title: String, symbol: String)] = [
        ("Salty snacks", "cube.fill"),
        ("Sweet / candy", "birthday.cake.fill"),
        ("Junk food", "takeoutbag.and.cup.and.straw"),
        ("Fast food", "bag.fill"),
        ("Comfort food", "heart.fill"),
        ("Bread & carbs", "leaf.fill"),
        ("Nothing specific", "circle.slash"),
        ("Other", "ellipsis.circle.fill")
    ]

    // What did you eat: multi-select
    static let whatAteOptions: [(title: String, symbol: String)] = [
        ("I didn't eat", "xmark.circle.fill"),
        ("Salty snacks", "cube.fill"),
        ("Sweet / candy", "birthday.cake.fill"),
        ("Junk food", "takeoutbag.and.cup.and.straw"),
        ("Fast food", "bag.fill"),
        ("Leftovers", "refrigerator.fill"),
        ("Other", "ellipsis.circle.fill")
    ]

    @State private var selectedTriggers: Set<String> = []
    @State private var controlLevel: Double = 5.0
    @State private var selectedLocation: String?
    @State private var locationCustom = ""
    @State private var selectedUrgeToEat: String?
    @State private var selectedWhatAte: Set<String> = []
    @State private var isSaving = false
    @State private var saveMessage: String?
    @State private var showReportSummary = false
    @State private var didSave = false
    @Environment(\.dismiss) private var dismiss

    private var locationDisplay: String {
        guard let loc = selectedLocation else { return locationCustom.isEmpty ? "" : locationCustom }
        if loc == "Other" && !locationCustom.isEmpty { return locationCustom }
        if !locationCustom.isEmpty { return "\(loc) — \(locationCustom)" }
        return loc
    }

    private func controlSliderColor(_ value: Double) -> Color {
        let t = (value - 1) / 9
        return Color(
            red: 162/255 + (0.95 - 162/255) * t,
            green: 202/255 + (0.6 - 202/255) * t,
            blue: 228/255 + (0.3 - 228/255) * t
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 1. How are you feeling now?
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.text.square.fill")
                            .font(.title2)
                            .foregroundStyle(Color.bedPrimaryVivid)
                        Text("How are you feeling now?")
                            .font(.title2.bold())
                            .foregroundStyle(.primary)
                    }
                    Text("Select all that apply")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    FlowLayout(spacing: 8) {
                        ForEach(Self.triggerOptions, id: \.self) { trigger in
                            TriggerChip(title: trigger, isSelected: selectedTriggers.contains(trigger)) {
                                if selectedTriggers.contains(trigger) { selectedTriggers.remove(trigger) }
                                else { selectedTriggers.insert(trigger) }
                            }
                        }
                    }
                    if !selectedTriggers.isEmpty {
                        Text("Selected: \(selectedTriggers.sorted().joined(separator: ", "))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()

                // 2. Slider — más grande para apreciar el color
                VStack(alignment: .leading, spacing: 10) {
                    Text("How much did you control the episode?")
                        .font(.headline)
                    Text("Slide right if you managed to control it well.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(alignment: .center) {
                        Text("Little")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Slider(value: $controlLevel, in: 1...10, step: 1)
                            .tint(controlSliderColor(controlLevel))
                            .scaleEffect(y: 1.4)
                        Text("A lot")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 16)
                    Text("\(Int(controlLevel))/10")
                        .font(.subheadline.bold())
                        .foregroundStyle(controlSliderColor(controlLevel))
                }

                Divider()

                // 3. Where were you? — chips como emociones
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .font(.title3)
                            .foregroundStyle(Color.bedPrimaryVivid)
                        Text("Where were you?")
                            .font(.headline)
                    }
                    Text("Select one")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    FlowLayout(spacing: 8) {
                        ForEach(Self.locationOptions, id: \.self) { loc in
                            TriggerChip(
                                title: loc,
                                isSelected: selectedLocation == loc
                            ) {
                                selectedLocation = (selectedLocation == loc) ? nil : loc
                            }
                        }
                    }
                    if selectedLocation == "Other" || selectedLocation != nil {
                        TextField("Add details (e.g. kitchen, office)", text: $locationCustom)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                Divider()

                // 4. What did you have an urge to eat? — cards, single select
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .font(.title3)
                            .foregroundStyle(Color.bedPrimaryVivid)
                        Text("What did you have an urge to eat?")
                            .font(.headline)
                    }
                    Text("Select one")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(Self.urgeToEatOptions, id: \.title) { opt in
                            OptionCard(
                                title: opt.title,
                                symbol: opt.symbol,
                                isSelected: selectedUrgeToEat == opt.title
                            ) {
                                selectedUrgeToEat = (selectedUrgeToEat == opt.title) ? nil : opt.title
                            }
                        }
                    }
                }

                Divider()

                // 5. What did you eat during the episode? — cards, multi-select
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "fork.knife")
                            .font(.title3)
                            .foregroundStyle(Color.bedPrimaryVivid)
                        Text("What did you eat during the episode?")
                            .font(.headline)
                    }
                    Text("Select all that apply (if any)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(Self.whatAteOptions, id: \.title) { opt in
                            OptionCard(
                                title: opt.title,
                                symbol: opt.symbol,
                                isSelected: selectedWhatAte.contains(opt.title)
                            ) {
                                if selectedWhatAte.contains(opt.title) { selectedWhatAte.remove(opt.title) }
                                else { selectedWhatAte.insert(opt.title) }
                            }
                        }
                    }
                }

                Divider()

                // 6. Episode duration (desde "I'm having an urge" hasta "I'm ready to reflect")
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .font(.title3)
                            .foregroundStyle(Color.bedPrimaryVivid)
                        Text("Episode duration")
                            .font(.headline)
                    }
                    Text("Time from urge to reflection")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(episodeDurationFormatted)
                        .font(.title2.bold())
                        .foregroundStyle(Color.bedSecondary)
                }

                Spacer(minLength: 40)
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                if let message = saveMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(message.contains("saved") || message == "Saved." ? .green : .red)
                }
                SlideToSaveView(isSaving: isSaving, onComplete: performSave)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .navigationTitle("Reflection")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showReportSummary) {
            ReportSummaryView(
                triggers: Array(selectedTriggers).sorted(),
                controlLevel: Int(controlLevel),
                location: locationDisplay,
                urgeToEat: selectedUrgeToEat ?? "",
                whatAte: selectedWhatAte.sorted().joined(separator: ", "),
                episodeDuration: episodeDurationFormatted
            )
        }
    }

    private func performSave() {
        guard !didSave else { return }
        isSaving = true
        saveMessage = nil
        let triggersString = selectedTriggers.isEmpty ? "Not specified" : selectedTriggers.sorted().joined(separator: ", ")
        let urgeToEatString = selectedUrgeToEat ?? ""
        let whatAteString = selectedWhatAte.isEmpty ? "" : selectedWhatAte.sorted().joined(separator: ", ")
        CareStoreManager.shared.addEpisodeOutcome(
            triggers: triggersString,
            intensity: Int(controlLevel),
            location: locationDisplay,
            urgeToEat: urgeToEatString,
            whatAte: whatAteString,
            episodeDuration: episodeDurationFormatted
        ) { result in
            isSaving = false
            switch result {
            case .success:
                didSave = true
                saveMessage = "Saved."
                showReportSummary = true
            case .failure(let error):
                saveMessage = "Error: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Card para opción (SF Symbol + título)
struct OptionCard: View {
    let title: String
    let symbol: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: symbol)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : Color.bedPrimaryVivid)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .background(isSelected ? Color.bedPrimaryVivid : Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Trigger chip (multi-select)
struct TriggerChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.bedPrimaryVivid : Color(.secondarySystemFill))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flow layout for chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var positions: [CGPoint] = []
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}

// MARK: - Slide to save
struct SlideToSaveView: View {
    let isSaving: Bool
    let onComplete: () -> Void

    @State private var dragOffset: CGFloat = 0
    private let thumbSize: CGFloat = 44
    private let triggerDistance: CGFloat = 220

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let maxDrag = max(0, width - thumbSize - 16)
            let progress = maxDrag > 0 ? min(1, dragOffset / maxDrag) : 0
            let thumbX = min(max(0, dragOffset), maxDrag) + 8

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: thumbSize / 2)
                    .fill(Color(.secondarySystemFill))
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: thumbSize / 2)
                            .fill(Color.bedPrimaryVivid.opacity(0.35))
                            .frame(width: thumbX + thumbSize * 0.5)
                    }
                    .overlay {
                        Text(progress >= 0.85 ? "Release to save" : "Slide to save report")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                            .allowsHitTesting(false)
                    }
                Circle()
                    .fill(Color.bedPrimaryVivid)
                    .frame(width: thumbSize, height: thumbSize)
                    .overlay {
                        if isSaving {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "arrow.right")
                                .font(.headline.bold())
                                .foregroundStyle(.white)
                        }
                    }
                    .offset(x: thumbX)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !isSaving { dragOffset = max(0, value.translation.width) }
                            }
                            .onEnded { _ in
                                if !isSaving && dragOffset >= triggerDistance { onComplete() }
                                withAnimation(.easeOut(duration: 0.25)) { dragOffset = 0 }
                            }
                    )
            }
            .frame(height: thumbSize)
        }
        .frame(height: 44)
    }
}

#Preview {
    NavigationStack {
        LoggingView()
    }
}
