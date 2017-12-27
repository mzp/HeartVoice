//
//  InterfaceController.swift
//  HeartVoiceWatch Extension
//
//  Created by mzp on 2017/12/27.
//  Copyright © 2017 mzp. All rights reserved.
//

import HealthKit
import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    @IBOutlet var label: WKInterfaceLabel!
    private let healthStore: HKHealthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private let watchSession: WatchSession = WatchSession()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        // Configure interface objects here.
    }

    override func willActivate() {
        super.willActivate()

        guard HKHealthStore.isHealthDataAvailable() == true else {
            return
        }

        guard let quantityType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return
        }

        let dataTypes = Set([quantityType])
        healthStore.requestAuthorization(toShare: nil, read: dataTypes) { (success, _) -> Void in
            NSLog("%@", "success = \(success)")
            self.startWorkout()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
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

private let kHeartRateUnit = HKUnit(from: "count/min")

extension InterfaceController: HKWorkoutSessionDelegate {
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
            let value = sample.quantity.doubleValue(for: kHeartRateUnit)
            self.label.setText("💓\(String(UInt16(value)))")
            self.watchSession.send(HeartActivity(Int(value)))
        }
    }
}
