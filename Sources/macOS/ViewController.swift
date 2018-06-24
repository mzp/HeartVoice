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
    let heartrate = NSTextField()
    var server: HeartVoiceServiceServer?
    let graph = DokiDokiGraph()

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        button.title = "become a server"
        button.target = self
        button.action = #selector(becomeAServer(_:))

        heartrate.isEditable = false
        heartrate.stringValue = "--"
        heartrate.isBordered = false
        heartrate.drawsBackground = false
        heartrate.font = NSFont.systemFont(ofSize: 42.0)
        heartrate.textColor = NSColor.white

        let autolayout = view.northLayoutFormat(["p": 20], [
            "server": button,
            "heartrate": heartrate,
            "graph": graph])
        autolayout("H:|-p-[server]-p-|")
        autolayout("H:|-p-[heartrate]-p-|")
        autolayout("H:|-p-[graph]-p-|")
        autolayout("V:|-p-[heartrate]-p-[graph(==128)]-p-[server]-p-|")
    }

    @objc private func becomeAServer(_ sender: AnyObject?) {
        server = HeartVoiceServiceServer(name: ProcessInfo().hostName)
        server?.activty.signal.observe(on: QueueScheduler.main).observeValues { activity in
            self.heartrate.stringValue = "♥\(activity.heartrate)"
        }
        server?.dokiDokiActivity.signal.observe(on: QueueScheduler.main).observeValues { activity in
            self.graph.activity = activity
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
