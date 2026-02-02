//
//  ReportPreviewView.swift
//  BEDAPP
//
//  Created by Alberto Besne Cabrera on 27/01/26.
//

import SwiftUI

struct ReportPreviewView: View {
    let triggers: [String]
    let controlLevel: Int
    let location: String
    var urgeToEat: String = ""
    var whatAte: String = ""
    var episodeDuration: String = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dismissInterventionFlow) private var dismissInterventionFlow

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.bedPrimaryVivid)
                Text("Report saved")
                    .font(.title.bold())
                    .foregroundStyle(Color.bedSecondary)
                Text("Here's a preview of what your specialist will see.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 20) {
                    Text("Report preview")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    ReportPreviewRow(
                        icon: "heart.text.square.fill",
                        title: "Feelings / triggers",
                        value: triggers.isEmpty ? "—" : triggers.joined(separator: ", ")
                    )
                    ReportPreviewRow(
                        icon: "slider.horizontal.3",
                        title: "Episode control",
                        value: controlLabel(controlLevel)
                    )
                    ReportPreviewRow(
                        icon: "location.fill",
                        title: "Where",
                        value: location.isEmpty ? "—" : location
                    )
                    if !urgeToEat.isEmpty {
                        ReportPreviewRow(
                            icon: "flame.fill",
                            title: "Urge to eat",
                            value: urgeToEat
                        )
                    }
                    if !whatAte.isEmpty {
                        ReportPreviewRow(
                            icon: "fork.knife",
                            title: "What you ate",
                            value: whatAte
                        )
                    }
                    if !episodeDuration.isEmpty {
                        ReportPreviewRow(
                            icon: "clock.fill",
                            title: "Episode duration",
                            value: episodeDuration
                        )
                    }
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                Text("This report is stored on your device. You can share it with your specialist via PDF or in your next appointment.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer(minLength: 120)
            }
            .padding(.vertical, 32)
        }
        .navigationTitle("Your report")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom) {
            // Botón Done hasta abajo, más grande y con más color
            Button(action: goToMainScreen) {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.bedSecondary)
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
        }
    }

    private func goToMainScreen() {
        if let dismissFlow = dismissInterventionFlow {
            dismissFlow()
        } else {
            dismiss()
        }
    }

    private func controlLabel(_ level: Int) -> String {
        switch level {
        case 1...3: return "Little control (\(level)/10)"
        case 4...6: return "Some control (\(level)/10)"
        case 7...9: return "Good control (\(level)/10)"
        case 10: return "Full control (10/10)"
        default: return "\(level)/10"
        }
    }
}

struct ReportPreviewRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.bedPrimaryVivid)
                .frame(width: 28, alignment: .center)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body)
            }
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    NavigationStack {
        ReportPreviewView(
            triggers: ["Anxiety", "Stress"],
            controlLevel: 7,
            location: "Home",
            urgeToEat: "Sweet / Junk food",
            whatAte: "Candy"
        )
    }
}
