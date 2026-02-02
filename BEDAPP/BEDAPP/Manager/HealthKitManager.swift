//
//  HealthKitManager.swift
//  BEDAPP
//
//  Created by Alberto Besne Cabrera on 27/01/26.
//

import Combine
import HealthKit
import UserNotifications

class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()
    @Published private(set) var isAuthorized = false

    func requestAccess() {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        let types: Set<HKObjectType> = [hrType]
        healthStore.requestAuthorization(toShare: nil, read: types) { [weak self] success, _ in
            if success { self?.startObservation() }
        }
    }

    func startObservation() {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }

        let query = HKObserverQuery(sampleType: hrType, predicate: nil) { [weak self] _, completionHandler, _ in
            // Logic to check if HR > 100 while stationary
            self?.sendSupportiveAlert()
            completionHandler()
        }
        healthStore.execute(query)
    }

    private func sendSupportiveAlert() {
        let content = UNMutableNotificationContent()
        content.title = "Checking in on you"
        content.body = "I noticed your heart rate is a bit high. Shall we take a mindful breath together?"

        let request = UNNotificationRequest(identifier: "HR_Alert", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
