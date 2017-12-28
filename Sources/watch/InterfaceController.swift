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
import ReactiveSwift

class InterfaceController: WKInterfaceController {
    @IBOutlet var label: WKInterfaceLabel!
    private let heartRate: HeartRateSource = HeartRateSource.shared
    private let watchSession: WatchSession = WatchSession()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }

    override func willActivate() {
        super.willActivate()

        heartRate.source.signal.observeValues { value in
            self.watchSession.send(HeartActivity(value))
        }
        heartRate.source.signal.observe(on: QueueScheduler.main).observeValues { value in
            self.label.setText("💓\(String(value))")
        }

        if heartRate.isRunning {
            self.label.setText("💓\(heartRate.source.value)")
        } else {
            self.label.setText("⇒")
        }
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
}
