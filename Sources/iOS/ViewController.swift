//
//  ViewController.swift
//  HeartVoice
//
//  Created by mzp on 2017/12/27.
//  Copyright © 2017 mzp. All rights reserved.
//

import UIKit
import HealthKit
import NorthLayout

class ViewController: UIViewController {
    private lazy var watchSession: WatchSession = WatchSession()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        let label = UILabel()
        label.text = "--"
        label.font = UIFont.systemFont(ofSize: 42.0)

        let autolayout = northLayoutFormat([:], [
            "label": label
        ])
        autolayout("H:||[label]||")
        autolayout("V:||[label]||")

        watchSession.onActivity = { activity in
            DispatchQueue.main.async {
                label.text = "💓\(activity.heartrate)"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
