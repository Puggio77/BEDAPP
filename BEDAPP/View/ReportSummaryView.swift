//
//  ReportSummaryView.swift
//  BEDAPP
//
//  Resumen detallado del reporte, estilo Health (iPhone).
//

import SwiftUI

struct ReportSummaryView: View {
    let triggers: [String]
    let controlLevel: Int
    let location: String
    let urgeToEat: String
    let whatAte: String
    let episodeDuration: String
    @State private var showReportSaved = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Recuadro Episode Summary más grande y dinámico
                SummarySection(title: "Episode Summary") {
                    VStack(spacing: 0) {
                        SummaryRow(title: "Feelings", value: triggers.isEmpty ? "—" : triggers.joined(separator: ", "), icon: "heart.text.square.fill")
                        Divider().padding(.leading, 52)
                        SummaryRow(title: "Control level", value: "\(controlLevel)/10", icon: "slider.horizontal.3")
                        Divider().padding(.leading, 52)
                        SummaryRow(title: "Where", value: location.isEmpty ? "—" : location, icon: "location.fill")
                        Divider().padding(.leading, 52)
                        SummaryRow(title: "Urge to eat", value: urgeToEat.isEmpty ? "—" : urgeToEat, icon: "flame.fill")
                        Divider().padding(.leading, 52)
                        SummaryRow(title: "What you ate", value: whatAte.isEmpty ? "—" : whatAte, icon: "fork.knife")
                        Divider().padding(.leading, 52)
                        SummaryRow(title: "Episode duration", value: episodeDuration.isEmpty ? "—" : episodeDuration, icon: "clock.fill")
                    }
                }

                Text("Review your reflection below. Tap Done to confirm and save.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .padding(.top, 24)
                    .padding(.bottom, 120)
            }
            .padding(.top, 20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Report Summary")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showReportSaved) {
            ReportPreviewView(
                triggers: triggers,
                controlLevel: controlLevel,
                location: location,
                urgeToEat: urgeToEat,
                whatAte: whatAte,
                episodeDuration: episodeDuration
            )
        }
        .safeAreaInset(edge: .bottom) {
            // Botón Done hasta abajo, con más color (más oscuro)
            Button(action: { showReportSaved = true }) {
                Label("Done", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.bedSecondary)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
    }
}

// MARK: - Sección más grande y dinámica
struct SummarySection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(Color.bedSecondary)
                .textCase(.uppercase)
                .padding(.horizontal, 24)
                .padding(.bottom, 12)

            VStack(spacing: 0) {
                content
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 28)
    }
}

// MARK: - Fila más grande para interacción
struct SummaryRow: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.bedPrimaryVivid)
                .frame(width: 28, alignment: .center)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Text(value)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

#Preview {
    NavigationStack {
        ReportSummaryView(
            triggers: ["Anxiety", "Stress"],
            controlLevel: 7,
            location: "Home",
            urgeToEat: "Sweet / Junk food",
            whatAte: "Chips, Candy",
            episodeDuration: "2 min 15 s"
        )
    }
}
