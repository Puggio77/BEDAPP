//
//  ChatView.swift
//  BEDAPP
//
//  Created by Riccardo Puggioni on 27/01/26.
//

import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Chat List
                List(viewModel.messages) { message in
                    ChatRow(message: message)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                
                // Input Section
                VStack {
                    Divider()
                    inputArea
                        .padding()
                        .background(.background)
                }
            }
            .navigationTitle("Emergency Log")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private var inputArea: some View {
        switch viewModel.currentStep {
        case 3:
            VStack {
                Slider(value: Binding(get: { Double(viewModel.intensity) },
                                      set: { viewModel.intensity = Int($0) }), in: 1...10, step: 1)
                Button("Confirm Intensity: \(viewModel.intensity)") {
                    viewModel.sendResponse("\(viewModel.intensity)")
                }
                .buttonStyle(.borderedProminent)
            }
        case 4:
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.symptomsList, id: \.self) { symptom in
                            Toggle(symptom, isOn: Binding(
                                get: { viewModel.selectedSymptoms.contains(symptom) },
                                set: { isSelected in
                                    if isSelected { viewModel.selectedSymptoms.insert(symptom) }
                                    else { viewModel.selectedSymptoms.remove(symptom) }
                                }
                            ))
                            .toggleStyle(.button)
                        }
                    }
                }
                Button("Send Symptoms") {
                    let summary = Array(viewModel.selectedSymptoms).joined(separator: ", ")
                    viewModel.sendResponse(summary.isEmpty ? "None" : summary)
                }
                .buttonStyle(.borderedProminent)
            }
        default:
            HStack {
                TextField("Type a message...", text: $viewModel.inputText)
                    .textFieldStyle(.roundedBorder)
                Button { viewModel.sendResponse(viewModel.inputText) } label: {
                    Image(systemName: "paperplane.fill")
                }
                .disabled(viewModel.inputText.isEmpty)
            }
        }
    }
}

struct ChatRow: View {
    let message: ChatMessage
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            Text(message.text)
                .padding(10)
                .background(message.isUser ? Color.accentColor : Color(.systemGray6))
                .foregroundColor(message.isUser ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            if !message.isUser { Spacer() }
        }
    }
}
#Preview {
    ChatView()
}
