//
//  ChatViewModel.swift
//  BEDAPP
//
//  Created by Riccardo Puggioni on 27/01/26.
//

import Foundation

@Observable
class ChatViewModel {
    var messages: [ChatMessage] = [
        ChatMessage(text: "Where are you?", isUser: false)
    ]
    var currentStep = 1
    var inputText = ""
    var intensity = 5
    var selectedSymptoms: Set<String> = []
    
    let symptomsList = [
        "Tachycardia", "Sweating", "Tremors", "Shortness of breath",
        "Chest pain", "Nausea", "Dizziness", "Derealization",
        "Fear of losing control"
    ]
    
    private let questions = [
        "",
        "Where are you?",
        "What triggered the attack?",
        "How intense was it (1-10)?",
        "Select your symptoms:",
        "Anything else you'd like to add?",
        "Done. Everything has been saved."
    ]

    func sendResponse(_ text: String) {
        guard !text.isEmpty || currentStep == 4 else { return }
        
        // Aggiunge risposta utente
        messages.append(ChatMessage(text: text, isUser: true))
        inputText = ""
        
        // Simula risposta dell'app
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.currentStep += 1
            if self.currentStep < self.questions.count {
                self.messages.append(ChatMessage(text: self.questions[self.currentStep], isUser: false))
            }
        }
    }
}
