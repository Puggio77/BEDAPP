//
//  CareStoreManager.swift
//  BEDAPP
//
//  Created by Alberto Besne Cabrera on 27/01/26.
//
import CareKit
import CareKitStore
import Combine
import Foundation

/// Un reporte de episodio guardado, para listar y exportar a PDF.
struct EpisodeReport: Identifiable {
    let id: Int
    let date: Date
    let triggers: String
    let controlLevel: Int
    let location: String
    let urgeToEat: String
    let whatAte: String
    let episodeDuration: String
}

class CareStoreManager: ObservableObject {
    static let shared = CareStoreManager()
    let store: OCKStore
    @Published private(set) var isReady = false

    init() {
        store = OCKStore(name: "BEDSupportStore")
        setupTasks()
    }

    private func setupTasks() {
        // CareKit 4: build schedule from elements (once per day)
        let interval = DateComponents(day: 1)
        let element = OCKScheduleElement(start: Date(), end: nil, interval: interval)
        let schedule = OCKSchedule(composing: [element])
        let episodeTask = OCKTask(
            id: "episode_report",
            title: "Episode Record",
            carePlanUUID: nil,
            schedule: schedule
        )

        store.addTasks([episodeTask]) { [weak self] result in
            switch result {
            case .success:
                print("Task initialized")
                DispatchQueue.main.async { self?.isReady = true }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    /// Saves an episode reflection as an outcome for the specialist report.
    func addEpisodeOutcome(
        triggers: String,
        intensity: Int,
        location: String,
        urgeToEat: String,
        whatAte: String,
        episodeDuration: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let query = OCKTaskQuery(for: Date())
        store.fetchTasks(query: query) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            case .success(let tasks):
                let episodeTasks = tasks.filter { $0.id == "episode_report" }
                guard let task = episodeTasks.first else {
                    DispatchQueue.main.async { completion(.failure(NSError(domain: "BEDAPP", code: -1, userInfo: [NSLocalizedDescriptionKey: "Episode task not found"]))) }
                    return
                }
                // CareKit requires unique (taskUUID, taskOccurrenceIndex). Use next available index.
                self.addOutcomeWithNextIndex(
                    task: task,
                    triggers: triggers,
                    intensity: intensity,
                    location: location,
                    urgeToEat: urgeToEat,
                    whatAte: whatAte,
                    episodeDuration: episodeDuration,
                    completion: completion
                )
            }
        }
    }

    private let outcomeIndexKeyPrefix = "BEDAPP_episode_outcome_index_"

    private func addOutcomeWithNextIndex(
        task: OCKTask,
        triggers: String,
        intensity: Int,
        location: String,
        urgeToEat: String,
        whatAte: String,
        episodeDuration: String,
        retryIfDuplicate: Bool = true,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let nextIndex = nextEpisodeOutcomeIndex(for: task.uuid)
        let dateString = ISO8601DateFormatter().string(from: Date())
        let values: [OCKOutcomeValue] = [
            OCKOutcomeValue(triggers.isEmpty ? "Not specified" : triggers),
            OCKOutcomeValue(Double(intensity)),
            OCKOutcomeValue(location.isEmpty ? "Not specified" : location),
            OCKOutcomeValue(urgeToEat.isEmpty ? "Not specified" : urgeToEat),
            OCKOutcomeValue(whatAte.isEmpty ? "Not specified" : whatAte),
            OCKOutcomeValue(dateString),
            OCKOutcomeValue(episodeDuration.isEmpty ? "—" : episodeDuration)
        ]
        let outcome = OCKOutcome(
            taskUUID: task.uuid,
            taskOccurrenceIndex: nextIndex,
            values: values
        )
        store.addOutcome(outcome) { [weak self] addResult in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch addResult {
                case .success:
                    self.recordEpisodeOutcomeIndex(nextIndex, for: task.uuid)
                    completion(.success(()))
                case .failure(let err):
                    let message = err.localizedDescription
                    if retryIfDuplicate, message.contains("non-unique") || message.contains("unique") {
                        self.recordEpisodeOutcomeIndex(nextIndex, for: task.uuid)
                        self.addOutcomeWithNextIndex(
                            task: task,
                            triggers: triggers,
                            intensity: intensity,
                            location: location,
                            urgeToEat: urgeToEat,
                            whatAte: whatAte,
                            episodeDuration: episodeDuration,
                            retryIfDuplicate: false,
                            completion: completion
                        )
                    } else {
                        completion(.failure(err))
                    }
                }
            }
        }
    }

    /// Returns the next available taskOccurrenceIndex so each save is unique.
    private func nextEpisodeOutcomeIndex(for taskUUID: UUID) -> Int {
        let key = outcomeIndexKeyPrefix + taskUUID.uuidString
        return UserDefaults.standard.integer(forKey: key)
    }

    /// After a successful save, increment the stored index for next time.
    private func recordEpisodeOutcomeIndex(_ indexJustUsed: Int, for taskUUID: UUID) {
        let key = outcomeIndexKeyPrefix + taskUUID.uuidString
        UserDefaults.standard.set(indexJustUsed + 1, forKey: key)
    }

    /// Fetches all saved episode reports for "My reports" and export.
    func fetchEpisodeOutcomes(completion: @escaping (Result<[EpisodeReport], Error>) -> Void) {
        let query = OCKTaskQuery(for: Date())
        store.fetchTasks(query: query) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            case .success(let tasks):
                let episodeTasks = tasks.filter { $0.id == "episode_report" }
                guard let task = episodeTasks.first else {
                    DispatchQueue.main.async { completion(.success([])) }
                    return
                }
                var outcomeQuery = OCKOutcomeQuery()
                outcomeQuery.taskIDs = ["episode_report"]
                outcomeQuery.dateInterval = DateInterval(start: .distantPast, end: .distantFuture)
                self.store.fetchOutcomes(query: outcomeQuery) { fetchResult in
                    DispatchQueue.main.async {
                        switch fetchResult {
                        case .failure(let error):
                            completion(.failure(error))
                        case .success(let outcomes):
                            let reports = outcomes.compactMap { outcome -> EpisodeReport? in
                                self.parseOutcome(outcome)
                            }
                            completion(.success(reports.sorted { $0.date > $1.date }))
                        }
                    }
                }
            }
        }
    }

    private func parseOutcome(_ outcome: OCKOutcome) -> EpisodeReport? {
        let v = outcome.values
        let triggers = stringFromOutcomeValue(v, at: 0) ?? "—"
        let intensityDouble = doubleFromOutcomeValue(v, at: 1) ?? 5
        let controlLevel = Int(intensityDouble)
        let location = stringFromOutcomeValue(v, at: 2) ?? "—"
        let urgeToEat = stringFromOutcomeValue(v, at: 3) ?? "—"
        let whatAte = stringFromOutcomeValue(v, at: 4) ?? "—"
        let date: Date
        if let dateStr = stringFromOutcomeValue(v, at: 5), let d = ISO8601DateFormatter().date(from: dateStr) {
            date = d
        } else {
            date = Date()
        }
        let episodeDuration = stringFromOutcomeValue(v, at: 6) ?? "—"
        return EpisodeReport(
            id: outcome.taskOccurrenceIndex,
            date: date,
            triggers: triggers,
            controlLevel: controlLevel,
            location: location,
            urgeToEat: urgeToEat,
            whatAte: whatAte,
            episodeDuration: episodeDuration
        )
    }

    private func stringFromOutcomeValue(_ values: [OCKOutcomeValue], at index: Int) -> String? {
        guard index < values.count else { return nil }
        let ov = values[index]
        if let s = ov.value as? String { return s }
        if let n = ov.value as? NSNumber { return n.stringValue }
        return nil
    }

    private func doubleFromOutcomeValue(_ values: [OCKOutcomeValue], at index: Int) -> Double? {
        guard index < values.count else { return nil }
        let ov = values[index]
        if let d = ov.value as? Double { return d }
        if let n = ov.value as? NSNumber { return n.doubleValue }
        return nil
    }
}
