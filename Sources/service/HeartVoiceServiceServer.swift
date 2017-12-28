//
//  PartyPlayServer.swift
//  Multipeer
//
//  Created by BAN Jun on 8/14/15.
//  Copyright © 2015 banjun. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class HeartVoiceServiceServer: NSObject {
    private let myPeerID: MCPeerID
    private var sessions = [MCSession]()
    private let advertiser: MCNearbyServiceAdvertiser

    var peers: [[MCPeerID]] { return sessions.map {$0.connectedPeers} }
    var onStateChange: (() -> Void)?
    var onActivity: ((HeartActivity) -> Void)?

    init(name: String, onStateChange: (() -> Void)? = nil) {
        myPeerID = MCPeerID(displayName: HeartVoiceService.serverPrefix + name)
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil,
                                               serviceType: HeartVoiceService.serviceType)
        super.init()
        advertiser.delegate = self
        self.onStateChange = onStateChange
    }

    func start() {
        advertiser.startAdvertisingPeer()
    }

    func stop() {
        advertiser.stopAdvertisingPeer()
        sessions.forEach {$0.disconnect()}
        sessions.removeAll()
    }
}

// MARK: MCSessionDelegate
extension HeartVoiceServiceServer: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            if state == .notConnected, let index = self.sessions.index(of: session) {
                self.sessions.remove(at: index)
            }
            NSLog("%@", "Server: peer = \(peerID), state = \(state.rawValue). total peers = \(self.peers)")
            self.onStateChange?()
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let activity = try? JSONDecoder().decode(HeartActivity.self, from: data) else {
            return
        }
        NSLog("\(activity)")
        self.onActivity?(activity)
    }

    func session(_ session: MCSession, didReceive stream: InputStream,
                 withName streamName: String, fromPeer peerID: MCPeerID) {

    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName from \(peerID.displayName): \(resourceName)")
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName from \(peerID.displayName): " +
            "\(String(describing: localURL)), error = \(String(describing: error?.localizedDescription))")
    }
}

// MARK: MCNearbyServiceAdvertiserDelegate
extension HeartVoiceServiceServer: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DispatchQueue.main.async {
            NSLog("%@", "incoming invitation request from \(peerID). auto-accept with new session.")

            let session = MCSession(peer: self.myPeerID)
            session.delegate = self
            self.sessions.append(session)
            invitationHandler(true, session)
        }
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "cannot start Party Play Server. error = \(error.localizedDescription)")
    }
}
