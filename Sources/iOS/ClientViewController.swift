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

class ClientViewController: UIViewController {
    private lazy var watchSession: WatchSession = WatchSession()
    private let client: HeartVoiceServiceClient

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
            "label": label
            ])
        autolayout("H:||[label]||")
        autolayout("V:||[label]||")

        watchSession.onActivity = { activity in
            DispatchQueue.main.async {
                label.text = "💓\(activity.heartrate)"
            }
            self.client.send(activity: activity)
        }
    }
}
