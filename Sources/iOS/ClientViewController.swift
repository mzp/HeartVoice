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

        label.reactive.text <~ watchSession.activity.map { "💓\($0.heartrate)" }

        watchSession.activity.signal.observeValues {
            self.client.send(activity: $0)
        }
    }
}
