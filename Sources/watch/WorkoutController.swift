//
//  WorkoutController.swift
//  HeartVoiceWatch Extension
//
//  Created by mzp on 2017/12/28.
//  Copyright © 2017 mzp. All rights reserved.
//

import Foundation
import WatchKit

class WorkoutController: WKInterfaceController {
    private let heartRate: HeartRateSource = HeartRateSource.shared
    @IBOutlet var startButton: WKInterfaceButton!
    @IBOutlet var stopButton: WKInterfaceButton!

    override func willActivate() {
        super.willActivate()
        updateButtons()
    }

    @IBAction func start() {
        heartRate.start()
        updateButtons()
    }

    @IBAction func stop() {
        heartRate.stop()
        updateButtons()
    }

    private func updateButtons() {
        startButton.setEnabled(!heartRate.isRunning)
        stopButton.setEnabled(heartRate.isRunning)
    }
}
