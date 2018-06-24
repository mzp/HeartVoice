//
//  PartyPlayServer.swift
//  Multipeer
//
//  Created by BAN Jun on 8/14/15.
//  Copyright © 2015 banjun. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import ReactiveSwift

class HeartVoiceServiceServer: NSObject {
    private let myPeerID: MCPeerID
    private let sessions: MutableProperty<[MCSession]> = MutableProperty([])
    private let advertiser: MCNearbyServiceAdvertiser
    private let mutableActivity: MutableProperty<HeartActivity>
    private let mutableDokiDokiActivity: MutableProperty<DokiDokiActivity?> = .init(nil)

    let peers: Property<[[MCPeerID]]>
    let activty: Property<HeartActivity>
    let dokiDokiActivity: Property<DokiDokiActivity?>

    init(name: String) {
        mutableActivity = MutableProperty(HeartActivity(0))
        activty = Property(mutableActivity)
        dokiDokiActivity = Property(mutableDokiDokiActivity)
        myPeerID = MCPeerID(displayName: HeartVoiceService.serverPrefix + name)
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil,
                                               serviceType: HeartVoiceService.serviceType)
        peers = sessions.map { $0.map { $0.connectedPeers } }
        super.init()
        advertiser.delegate = self
    }

    func start() {
        advertiser.startAdvertisingPeer()
    }

    func stop() {
        advertiser.stopAdvertisingPeer()
        sessions.value.forEach {$0.disconnect()}
        sessions.swap([])
    }
}

// MARK: MCSessionDelegate
extension HeartVoiceServiceServer: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            if state == .notConnected, let index = self.sessions.value.index(of: session) {
                self.sessions.modify { $0.remove(at: index) }
            }
            NSLog("%@", "Server: peer = \(peerID), state = \(state.rawValue). total peers = \(self.peers)")
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let activity = try? JSONDecoder().decode(HeartActivity.self, from: data) {
            NSLog("\(activity)")
            mutableActivity.value = activity
            return
        }

        if let activity = try? JSONDecoder().decode(DokiDokiActivity.self, from: data) {
            // NSLog("\(activity)")
            mutableDokiDokiActivity.value = activity
            return
        }
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
            self.sessions.modify { $0.append(session) }
            invitationHandler(true, session)
        }
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "cannot start Party Play Server. error = \(error.localizedDescription)")
    }
}
