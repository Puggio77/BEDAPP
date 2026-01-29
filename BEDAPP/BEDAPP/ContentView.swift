//
//  ContentView.swift
//  BEDAPP
//
//  Created by Riccardo Puggioni on 23/01/26.
//

import SwiftUI

struct ContentView: View {
    /// Cuando es true, se presenta el flujo de intervención (Coping → Logging → Report Summary → Report Preview).
    /// Al cerrar desde ReportPreviewView "Done", se pone en false y se vuelve a esta pantalla principal.
    @State private var showInterventionFlow = false

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                VStack(spacing: 0) {
                    Spacer(minLength: 0)

                    VStack(spacing: 24) {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(Color.bedPrimaryVivid)

                        Text("BED Support")
                            .font(.title.bold())
                            .foregroundStyle(Color.bedSecondary)

                        Text("When you feel an urge, start here. We'll guide you through a short breathing exercise, then a reflection to capture what matters for your specialist.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    Spacer(minLength: 0)

                    VStack(spacing: 16) {
                        Button {
                            showInterventionFlow = true
                        } label: {
                            Label("I'm having an urge", systemImage: "wind")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.bedPrimaryVivid)
                        .shadow(color: Color.bedPrimaryVivid.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, geo.safeAreaInsets.bottom + 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        ChatView()
                    } label: {
                        Label("Chat", systemImage: "bubble.left.and.bubble.right")
                    }
                    .foregroundStyle(Color.bedSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        ReportsListView()
                    } label: {
                        Label("My reports", systemImage: "doc.text.magnifyingglass")
                    }
                    .foregroundStyle(Color.bedSecondary)
                }
            }
            .fullScreenCover(isPresented: $showInterventionFlow) {
                NavigationStack {
                    CopingView()
                }
                .environment(\.dismissInterventionFlow, { showInterventionFlow = false })
            }
            .onOpenURL { url in
                if url.scheme == "bedsupport", url.host == "intervention" {
                    showInterventionFlow = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
