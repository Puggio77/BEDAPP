//
//  ReportView.swift
//  BEDAPP
//
//  Created by Riccardo Puggioni on 28/01/26.
//

import SwiftUI
import Charts

struct ReportView: View {
    @State private var viewModel = ReportViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                // Grafico: Andamento settimanale
                Section {
                    VStack(alignment: .leading) {
                        Text("Weekly Intensity & Duration")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Chart(viewModel.reports) { report in
                            BarMark(
                                x: .value("Day", report.timestamp, unit: .day),
                                y: .value("Duration", report.duration)
                            )
                            .foregroundStyle(Color.accentColor.gradient)
                            .cornerRadius(4)
                            
                            LineMark(
                                x: .value("Day", report.timestamp, unit: .day),
                                y: .value("Control", report.controlLevel)
                            )
                            .foregroundStyle(.orange)
                            .interpolationMethod(.catmullRom)
                            
                            PointMark(
                                x: .value("Day", report.timestamp, unit: .day),
                                y: .value("Control", report.controlLevel)
                            )
                            .foregroundStyle(.orange)
                        }
                        .frame(height: 200)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Analytics")
                }
                
                Section("Recent History") {
                    ForEach(viewModel.reports) { report in
                        ReportRowView(report: report)
                    }
                }
            }
            .navigationTitle("Report")
        }
    }
}

struct ReportRowView: View {
    let report: AttackReport
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(report.timestamp, style: .date)
                        .font(.headline)
                    Text(report.timestamp, style: .time)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                
                // Badge emozione
                Text(report.emotion.rawValue)
                    .font(.caption).bold()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.12))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(Capsule())
            }
            
            HStack {
                Label("\(report.duration) min", systemImage: "timer")
                Spacer()
                Label(report.location, systemImage: "location.fill")
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "hand.raised.fill")
                    Text("Control: \(report.controlLevel)/10")
                }
                .foregroundStyle(report.controlLevel < 4 ? .red : .primary)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ReportView()
}
