//
//  AppDelegate.swift
//  HeartVoice
//
//  Created by mzp on 2017/12/27.
//  Copyright © 2017 mzp. All rights reserved.
//

import UIKit
import HealthKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private let healthStore = HKHealthStore()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow()
        window.rootViewController = ViewController()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }

    func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {
        guard HKHealthStore.isHealthDataAvailable() == true else {
            return
        }

        guard let quantityType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return
        }

        let dataTypes = Set([quantityType])
        healthStore.requestAuthorization(toShare: nil, read: dataTypes) { (success, _) -> Void in
            NSLog("%@", "success = \(success)")
        }
    }
}
