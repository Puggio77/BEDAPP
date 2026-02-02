//
//  CopingView.swift
//  BEDAPP
//
//  Created by Alberto Besne Cabrera on 27/01/26.
//

import SwiftUI

struct CopingView: View {
    @State private var breathScale: CGFloat = 0.75
    @State private var titleOpacity: Double = 0.75
    @State private var showReadyHint = false
    @State private var readyHintOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var episodeStartDate: Date?
    @State private var episodeEndDate: Date?
    @State private var showLogging = false
    @Environment(\.dismiss) var dismiss

    private let breathDuration: Double = 4.0
    private let readyMessageDelay: Double = 30

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.bedPrimary.opacity(0.12),
                    Color.bedPrimary.opacity(0.06)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                // Título más abajo y animado (pulsa con la respiración)
                Text("Inhale peace, exhale tension.")
                    .font(.title2)
                    .italic()
                    .foregroundStyle(Color.bedSecondary)
                    .opacity(titleOpacity)
                    .padding(.top, 32)
                    .padding(.bottom, 24)

                // Animación: círculo que se llena + ondas expansivas (sin texto en el centro)
                BreathingRingsView(scale: breathScale)
                    .frame(width: 280, height: 280)

                Spacer(minLength: 0)

                // Área fija para el hint/botón (evita que la pantalla se mueva al aparecer)
                VStack(spacing: 20) {
                    if showReadyHint {
                        Text("When you're ready, you can continue to your report.")
                            .font(.subheadline)
                            .foregroundStyle(Color.bedSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .opacity(readyHintOpacity)

                        Button {
                            episodeEndDate = Date()
                            showLogging = true
                        } label: {
                            Text("I'm ready to reflect")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.bedPrimaryVivid)
                        .opacity(buttonOpacity)
                        .padding(.horizontal, 32)
                    }
                }
                .frame(minHeight: 120)
                .padding(.bottom, 48)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if episodeStartDate == nil { episodeStartDate = Date() }
            startBreathingAnimation()
            startTitleAnimation()
            scheduleReadyHint()
        }
        .navigationDestination(isPresented: $showLogging) {
            LoggingView(
                episodeStartDate: episodeStartDate ?? Date(),
                episodeEndDate: episodeEndDate ?? Date()
            )
        }
    }

    private func startBreathingAnimation() {
        withAnimation(.easeInOut(duration: breathDuration).repeatForever(autoreverses: true)) {
            breathScale = 1.15
        }
    }

    private func startTitleAnimation() {
        withAnimation(.easeInOut(duration: breathDuration).repeatForever(autoreverses: true)) {
            titleOpacity = 1.0
        }
    }

    private func scheduleReadyHint() {
        DispatchQueue.main.asyncAfter(deadline: .now() + readyMessageDelay) {
            showReadyHint = true
            withAnimation(.easeOut(duration: 1.2)) { readyHintOpacity = 1 }
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) { buttonOpacity = 1 }
        }
    }
}

// MARK: - Círculo que se llena + algunas ondas expansivas (sin "Breathe" en el centro)
struct BreathingRingsView: View {
    let scale: CGFloat

    /// Solo unas pocas ondas expansivas (anillos que pulsan)
    private let ringCount = 4
    private let ringColors: [Color] = [
        Color.bedSecondary.opacity(0.5),
        Color.bedPrimary.opacity(0.6),
        Color.bedPrimary.opacity(0.35),
        Color(red: 0.90, green: 0.94, blue: 0.97)
    ]

    var body: some View {
        ZStack {
            // Ondas expansivas (anillos concéntricos)
            ForEach(Array((0..<ringCount).reversed()), id: \.self) { i in
                let size = 80 + CGFloat(i) * 50
                Circle()
                    .stroke(ringColors[i], lineWidth: 6)
                    .frame(width: size, height: size)
                    .scaleEffect(scale)
            }
            // Centro: círculo que se “llena” (crece y decrece con la respiración), sin texto
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.bedSecondary.opacity(0.9),
                            Color.bedSecondary.opacity(0.75)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .scaleEffect(scale)
                .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
        }
    }
}

#Preview {
    NavigationStack {
        CopingView()
    }
}
