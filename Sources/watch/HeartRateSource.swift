//
//  HeartRateSource.swift
//  HeartVoiceWatch Extension
//
//  Created by mzp on 2017/12/28.
//  Copyright © 2017 mzp. All rights reserved.
//

import Foundation
import HealthKit
import ReactiveSwift

class HeartRateSource: NSObject {
    static let shared: HeartRateSource = HeartRateSource()

    let source: Property<Int>

    var isRunning: Bool {
        return self.session != nil
    }

    private let mutableSource: MutableProperty<Int>
    private let healthStore: HKHealthStore = HKHealthStore()
    private let kHeartRateUnit = HKUnit(from: "count/min")
    private var session: HKWorkoutSession?

    private override init() {
        self.mutableSource = MutableProperty<Int>(0)
        self.source = Property(self.mutableSource)
        super.init()
    }

    func start() {
        guard HKHealthStore.isHealthDataAvailable() == true else {
            return
        }

        guard let quantityType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return
        }

        let dataTypes = Set([quantityType])
        healthStore.requestAuthorization(toShare: nil, read: dataTypes) { (success, _) -> Void in
            if success {
                self.startWorkout()
            }
        }
    }

    func stop() {
        if let session = session {
            healthStore.end(session)
        }
        self.session = nil
    }

    private func startWorkout() {
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .other

        do {
            let session = try HKWorkoutSession(configuration: workoutConfiguration)
            session.delegate = self
            healthStore.start(session)
            self.session = session
        } catch {
            fatalError("Unable to create the workout session!")
        }
    }
}

extension HeartRateSource: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState,
                        date: Date) {
        if toState == .running {
            if let query = createHeartRateStreamingQuery(date) {
                healthStore.execute(query)
            }
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
    }

    private func createHeartRateStreamingQuery(_ workoutStartDate: Date) -> HKQuery? {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return nil
        }
        let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictEndDate )
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate])

        let heartRateQuery = HKAnchoredObjectQuery(
            type: quantityType,
            predicate: predicate,
            anchor: nil,
            limit: Int(HKObjectQueryNoLimit)) { (_, sampleObjects, _, _, _) -> Void in
                self.updateHeartRate(sampleObjects)
        }

        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            self.updateHeartRate(samples)
        }
        return heartRateQuery
    }

    private func updateHeartRate(_ samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else {return}

        DispatchQueue.main.async {
            guard let sample = heartRateSamples.first else {
                return
            }
            let value = sample.quantity.doubleValue(for: self.kHeartRateUnit)
            self.mutableSource.swap(Int(value))
        }
    }
}
