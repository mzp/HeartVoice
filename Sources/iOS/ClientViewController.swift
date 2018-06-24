//
//  ClientViewController.swift
//  HeartVoice
//
//  Created by mzp on 2017/12/28.
//  Copyright © 2017 mzp. All rights reserved.
//

import Foundation
import UIKit
import NorthLayout
import ReactiveCocoa
import ReactiveSwift
import Ikemen
import BrightFutures
import Result
import HealthKit

final class ClientViewController: UIViewController {
    private lazy var watchSession: WatchSession = WatchSession()
    private let client: HeartVoiceServiceClient
    private lazy var tableView: UITableView = .init(frame: .zero, style: .grouped) ※ { tv in
        tv.delegate = self
        tv.dataSource = self
        tv.register(DokiDokiActivityCell.self, forCellReuseIdentifier: "Cell")
        dokiDokiActivities.producer.startWithValues {[unowned tv] _ in tv.reloadData()}
    }
    private let store = HKHealthStore()
    private let dokiDokiActivities = MutableProperty<[DokiDokiActivity]>([])

    init(client: HeartVoiceServiceClient) {
        self.client = client

        super.init(nibName: nil, bundle: nil)

        title = client.server.displayNameWithoutPrefix
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {

        view.backgroundColor = UIColor.white
        let label = UILabel()
        label.text = "--"
        label.font = UIFont.systemFont(ofSize: 42.0)

        let autolayout = northLayoutFormat([:], [
            "label": label,
            "table": tableView])
        autolayout("H:||[label]||")
        autolayout("H:|[table]|")
        autolayout("V:||[label]-[table]|")

        label.reactive.text <~ watchSession.activity.map { "💓\($0.heartrate)" }

        watchSession.activity.signal.observeValues {
            self.client.send(activity: $0)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupHealthKit()
    }
}

// MARK: - HealthKit
extension ClientViewController {
    private func setupHealthKit() {
        let typesToRead: [HKObjectType] = [.quantityType(forIdentifier: .heartRate)].flatMap {$0}

        store.requestAuthorization(toShare: nil, read: Set(typesToRead)) { granted, error in
            guard granted, error == nil else { NSLog("%@", "granted = \(granted), error = \(String(describing: error))"); return }
            self.healthStoreDidSetup()
        }
    }

    private func healthStoreDidSetup() {
        guard dokiDokiActivities.value.isEmpty else { return }

        // NOTE: hard coded dates are Cinderella Girls 5th LIVE Serendipity Parade!!!, so far
        // NOTE: it's more better to query workout where activity type = other
        let periods: [(title: String, start: String, end: String)] = [
            ("宮城 Day1", "2017-05-13T17:00:00+0900", "2017-05-13T20:00:00+0900"),
            ("宮城 Day2", "2017-05-14T16:00:00+0900", "2017-05-14T19:00:00+0900"),
            ("石川 Day1", "2017-05-27T17:00:00+0900", "2017-05-27T20:00:00+0900"),
            ("石川 Day2", "2017-05-28T16:00:00+0900", "2017-05-28T19:00:00+0900"),
            ("大阪 Day1", "2017-06-09T18:00:00+0900", "2017-06-09T21:00:00+0900"),
            ("大阪 Day2", "2017-06-10T16:00:00+0900", "2017-06-10T19:00:00+0900"),
            ("静岡 Day1", "2017-06-24T17:00:00+0900", "2017-06-24T20:00:00+0900"),
            ("静岡 Day2", "2017-06-25T16:00:00+0900", "2017-06-25T19:00:00+0900"),
            ("幕張 Day1", "2017-07-08T17:00:00+0900", "2017-07-08T20:00:00+0900"),
            ("幕張 Day2", "2017-07-09T16:00:00+0900", "2017-07-09T19:00:00+0900"),
            ("福岡 Day1", "2017-07-29T16:30:00+0900", "2017-07-29T19:30:00+0900"),
            ("福岡 Day2", "2017-07-30T15:30:00+0900", "2017-07-30T18:30:00+0900"),
            ("SSA Day1", "2017-08-12T17:30:00+0900", "2017-08-12T22:30:00+0900"),
            ("SSA Day2", "2017-08-13T17:30:00+0900", "2017-08-13T22:30:00+0900")]

        SignalProducer<(title: String, start: String, end: String), NoError>(periods)
            .map {($0.title, ISO8601DateFormatter().date(from: $0.start)!, ISO8601DateFormatter().date(from: $0.end)!)}
            .flatMap(.concat) { period in
                SignalProducer<DokiDokiActivity, NoError> { observer, _ in
                    self.activities(title: period.0, start: period.1, end: period.2).onSuccess {
                        observer.send(value: $0)
                        observer.sendCompleted()
                    }
                }
            }.observe(on: QueueScheduler.main).startWithValues {
                self.dokiDokiActivities.value.append($0)
        }
    }

    private func activities(title: String, start: Date, end: Date) -> Future<DokiDokiActivity, NoError> {
        return .init { resolve in
            let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [])
            store.execute(HKAnchoredObjectQuery(
                type: HKSampleType.quantityType(forIdentifier: .heartRate)!,
                predicate: predicate,
                anchor: nil,
                limit: HKObjectQueryNoLimit) { _, samples, _, _, _ in
                    // NSLog("%@", "\(samples?.count ?? 0) samples found")
                    guard let qSamples = samples as? [HKQuantitySample], qSamples.count > 0 else { return }

                    let activity = DokiDokiActivity(title: title, start: start, heartbeats: qSamples.map {
                        DokiDokiActivity.TimedBeat(time: $0.startDate, heartrate: Int($0.quantity.doubleValue(for: HKUnit(from: "count/min"))))
                    })
                    resolve(.success(activity))
            })
        }
    }
}

// MARK: - TableView
extension ClientViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dokiDokiActivities.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DokiDokiActivityCell
        cell.configure(dokiDokiActivities.value[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        client.send(activity: dokiDokiActivities.value[indexPath.row])
    }
}

final class DokiDokiActivityCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder aDecoder: NSCoder) {super.init(coder: aDecoder)}

    func configure(_ activity: DokiDokiActivity) {
        textLabel?.text = activity.title
        detailTextLabel?.text = (DateFormatter() ※ {$0.dateFormat = "yyyy-MM-dd HH:mm -"}).string(from: activity.start)
    }
}
