//
//  ReportViewModel.swift
//  BEDAPP
//
//  Created by Riccardo Puggioni on 28/01/26.
//

import Foundation
import Observation

@Observable
class ReportViewModel {
    var reports: [AttackReport] = []
    
    init() {
        self.reports = createStaticReports()
    }
    
    private func createStaticReports() -> [AttackReport] {
        let calendar = Calendar.current
        let today = Date()
        
        func dateAt(_ daysAgo: Int, _ hour: Int, _ min: Int) -> Date {
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            return calendar.date(bySettingHour: hour, minute: min, second: 0, of: date)!
        }
        
        return [
            AttackReport(timestamp: dateAt(0, 14, 30), duration: 15, emotion: .stress, location: "Work", controlLevel: 4),
            AttackReport(timestamp: dateAt(1, 10, 15), duration: 10, emotion: .anxiety, location: "Home", controlLevel: 3),
            AttackReport(timestamp: dateAt(2, 18, 45), duration: 25, emotion: .stress, location: "Car", controlLevel: 2),
            AttackReport(timestamp: dateAt(3, 09, 00), duration: 8, emotion: .boredom, location: "Gym", controlLevel: 7),
            AttackReport(timestamp: dateAt(4, 21, 20), duration: 30, emotion: .sadness, location: "Home", controlLevel: 1),
            AttackReport(timestamp: dateAt(5, 13, 10), duration: 12, emotion: .anxiety, location: "Supermarket", controlLevel: 5),
            AttackReport(timestamp: dateAt(6, 16, 50), duration: 20, emotion: .stress, location: "Work", controlLevel: 6)
        ]
    }
}
