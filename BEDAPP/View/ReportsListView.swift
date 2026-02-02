//
//  ReportsListView.swift
//  BEDAPP
//
//  Pantalla "Mis reportes": lista de reportes guardados y opción de exportar PDF para el doctor.
//

import SwiftUI

struct ReportsListView: View {
    @State private var reports: [EpisodeReport] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var sharePDFURL: URL?
    @State private var showShareSheet = false

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading reports…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if reports.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No reports yet")
                        .font(.headline)
                    Text("Your episode reports will appear here after you complete a reflection.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(reports) { report in
                        AttackReportRowView(report: report, dateFormatter: dateFormatter) {
                            shareReport(report)
                        }
                    }
                }
            }
        }
        .navigationTitle("My reports")
        .navigationBarTitleDisplayMode(.large)
        .onAppear(perform: loadReports)
        .sheet(isPresented: $showShareSheet) {
            if let url = sharePDFURL {
                ShareSheet(items: [url])
            }
        }
        .onChange(of: showShareSheet) { isShowing in
            if !isShowing, let url = sharePDFURL {
                try? FileManager.default.removeItem(at: url)
                sharePDFURL = nil
            }
        }
    }

    private func loadReports() {
        isLoading = true
        errorMessage = nil
        CareStoreManager.shared.fetchEpisodeOutcomes { result in
            isLoading = false
            switch result {
            case .success(let list):
                reports = list
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }

    private func shareReport(_ report: EpisodeReport) {
        let data = ReportGenerator.createPDFReport(for: report)
        let fileName = "BED_Report_\(dateFormatter.string(from: report.date).replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: ":", with: "-")).pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: tempURL)
            sharePDFURL = tempURL
            showShareSheet = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct AttackReportRowView: View {
    let report: EpisodeReport
    let dateFormatter: DateFormatter
    let onShare: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundStyle(Color.bedPrimaryVivid)
                Text(dateFormatter.string(from: report.date))
                    .font(.headline)
                Spacer()
            }
            Text("Control \(report.controlLevel)/10 · \(report.location)")
                .font(.caption)
                .foregroundStyle(.secondary)
            if !report.triggers.isEmpty && report.triggers != "—" {
                Text(report.triggers)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Button(action: onShare) {
                Label("Share PDF for doctor", systemImage: "square.and.arrow.up")
                    .font(.subheadline)
                    .foregroundStyle(Color.bedPrimaryVivid)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Share sheet (UIKit) para compartir el PDF
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        ReportsListView()
    }
}
