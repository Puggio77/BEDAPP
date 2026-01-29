//
//  HealthReport.swift
//  BEDAPP
//
//  Created by Riccardo Puggioni on 28/01/26.
//

import Foundation

enum TriggerEmotion: String, CaseIterable, Codable {
    case anxiety = "Anxiety"
    case boredom = "Boredom"
    case sadness = "Sadness"
    case stress = "Stress"
}

struct AttackReport: Identifiable {
    let id = UUID()
    let timestamp: Date
    let duration: Int // Durata in minuti
    let emotion: TriggerEmotion
    let location: String
    let controlLevel: Int // 1-10
}
