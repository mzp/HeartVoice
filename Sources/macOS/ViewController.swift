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

class ViewController: NSViewController {
    let button = NSButton()
    let heartrate = NSTextField()
    var server: HeartVoiceServiceServer?

    override func viewDidLoad() {
        super.viewDidLoad()

        button.title = "become a server"
        button.target = self
        button.action = #selector(becomeAServer(_:))

        heartrate.isEditable = false
        heartrate.stringValue = "-"

        let autolayout = view.northLayoutFormat(["p": 20], [
            "server": button,
            "heartrate": heartrate
            ])
        autolayout("H:|-p-[server]-p-|")
        autolayout("H:|-p-[heartrate]-p-|")
        autolayout("V:[server]-p-|")
        autolayout("V:[heartrate]-p-[server]-p-|")

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @objc private func becomeAServer(_ sender: AnyObject?) {
        server = HeartVoiceServiceServer(name: ProcessInfo().hostName)

        server?.onActivity = { activity in
            DispatchQueue.main.async {
                self.heartrate.stringValue = "💓\(activity.heartrate)"
            }
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
