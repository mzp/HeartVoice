//
//  ViewController.swift
//  HeartVoiceViewer
//
//  Created by mzp on 2017/12/27.
//  Copyright © 2017 mzp. All rights reserved.
//

import Cocoa
import NorthLayout
import ReactiveSwift
import ReactiveCocoa

class ViewController: NSViewController {
    let button = NSButton()
    var server: HeartVoiceServiceServer?
    let contentView = MainView()

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        button.title = "become a server"
        button.target = self
        button.action = #selector(becomeAServer(_:))

        let autolayout = view.northLayoutFormat(["p": 20], [
            "server": button,
            "content": contentView])
        autolayout("H:|-p-[server]-p-|")
        autolayout("H:|-p-[content]-p-|")
        autolayout("V:|-p-[content(>=128)]-p-[server]-p-|")
    }

    @objc private func becomeAServer(_ sender: AnyObject?) {
        server = HeartVoiceServiceServer(name: ProcessInfo().hostName)
        server?.activty.signal.observe(on: QueueScheduler.main).observeValues { activity in
            self.contentView.currentHeartRateView.heartrate = activity.heartrate
        }
        server?.dokiDokiActivity.signal.observe(on: QueueScheduler.main).observeValues { activity in
            self.contentView.activity = activity
        }
        server?.peers.signal.observe(on: QueueScheduler.main).observeValues { peers in
            if self.server != nil {
                self.button.title = "\(peers.count) peers connected"
            } else {
                self.button.title = "become a server"
                self.button.isEnabled = true
            }
        }
        server?.start()
        button.title = "Server Started"
        button.isEnabled = false
    }
}
