//
//  PartyPlayServiceBrowser.swift
//  Multipeer
//
//  Created by BAN Jun on 8/15/15.
//  Copyright © 2015 banjun. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import ReactiveSwift

class HeartVoiceServiceBrowser: NSObject {
    fileprivate let myPeerID: MCPeerID
    fileprivate let browser: MCNearbyServiceBrowser

    /// 1 session per 1 server, 1 session have multiple peers
    let sessions: Property<[MCSession]>
    private let mutableSessions: MutableProperty<[MCSession]>

    init(name: String) {
        mutableSessions = MutableProperty<[MCSession]>([])
        sessions = Property(mutableSessions)
        myPeerID = MCPeerID(displayName: HeartVoiceService.clientPrefix + name)
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: HeartVoiceService.serviceType)
        super.init()
        browser.delegate = self
    }

    func start() {
        browser.startBrowsingForPeers()
    }

    func stop() {
        browser.stopBrowsingForPeers()
    }
}

// MARK: MCSessionDelegate
extension HeartVoiceServiceBrowser: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            NSLog("%@", "Browser: peer = \(peerID), state = \(state.rawValue). allPeers = \(self.sessions)")

            switch state {
            case .notConnected:
                self.mutableSessions.modify { (sessions: inout [MCSession]) in
                    guard let removedIndex = sessions.index(of: session) else { return }
                    sessions.remove(at: removedIndex)
                }
                break
            case .connecting:
                break
            case .connected:
                self.mutableSessions.swap(self.mutableSessions.value)
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {

    }

    func session(_ session: MCSession, didReceive stream: InputStream,
                 withName streamName: String, fromPeer peerID: MCPeerID) {

    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, with progress: Progress) {

    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {

    }
}

// MARK: MCNearbyServiceBrowserDelegate
extension HeartVoiceServiceBrowser: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String: String]?) {
        DispatchQueue.main.async {
            if !peerID.isServer { return }
            NSLog("%@", "PartyPlayServiceBrowser found server: \(peerID)")

            if self.sessions.value.index(where: { session in
                session.server?.displayName == peerID.displayName
            }) == nil {
                NSLog("%@", "new peer detected. auto-connect.")

                let session = MCSession(peer: self.myPeerID)
                session.delegate = self
                self.mutableSessions.modify { $0.append(session) }
                browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
            }
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "PartyPlayServiceBrowser lost peer: \(peerID)")
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "PartyPlayServiceBrowser did not start: \(error.localizedDescription)")
    }
}
