//
//  AppDelegate.swift
//  HeartVoiceViewer
//
//  Created by mzp on 2017/12/27.
//  Copyright © 2017 mzp. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!
    private let viewController = ViewController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let cv = window.contentView {
            window.backgroundColor = NSColor.clear
            window.isOpaque = false
            window.title = ""

            let autolayout = cv.northLayoutFormat([:], [
                "main": viewController.view
            ])
            autolayout("H:|[main]|")
            autolayout("V:|[main]|")
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}
