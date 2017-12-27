//
//  WatchSession.swift
//  HeartVoice
//
//  Created by mzp on 2017/12/27.
//  Copyright © 2017 mzp. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchSession: NSObject {
    var onActivity: ((HeartActivity) -> Void)?

    private lazy var session: WCSession? = {
        if WCSession.isSupported() {
            return WCSession.default
        } else {
            return nil
        }
    }()

    override init() {
        super.init()
        session?.delegate = self
        session?.activate()
    }

    func send(_ activity: HeartActivity) {
        guard let session = session else { return }

        guard let data = try? JSONEncoder().encode(activity) else {
            return
        }

        let message = [
            "activity": data
        ]
        if session.isReachable {
            session.sendMessage(message, replyHandler: { _ in }, errorHandler: nil)
        }
    }
}

extension WatchSession: WCSessionDelegate {
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
    }

    func sessionDidDeactivate(_ session: WCSession) {
    }
    #endif

    func session(_ session: WCSession,
                 didReceiveMessage message: [String: Any],
                 replyHandler: @escaping ([String: Any]) -> Swift.Void) {
        NSLog("\(message)")
        if let data = message["activity"] as? Data {
            guard let activity = try? JSONDecoder().decode(HeartActivity.self, from: data) else {
                return
            }
            NSLog("\(activity)")
            self.onActivity?(activity)
        }
    }
}
