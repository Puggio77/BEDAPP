//
//  ChatView.swift
//  BEDAPP
//
//  Plantilla de chat (sin funcionalidad por ahora).
//

import SwiftUI

struct ChatView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Área de mensajes (placeholder)
            ScrollView {
                VStack(spacing: 16) {
                    Text("Chat")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Here you can talk when you don’t want to create a report.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 40)
                    Spacer(minLength: 200)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Barra de entrada (placeholder)
            HStack(spacing: 12) {
                TextField("Message…", text: .constant(""))
                    .textFieldStyle(.roundedBorder)
                    .disabled(true)
                Button { } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.bedPrimaryVivid)
                }
                .disabled(true)
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
}
