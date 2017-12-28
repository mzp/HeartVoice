//
//  PartyPlay.swift
//  Multipeer
//
//  Created by BAN Jun on 8/15/15.
//  Copyright © 2015 banjun. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct HeartVoiceService {
    /// MultipeerConnectivity service type
    static let serviceType = "heartvoice"

    /// MCPeerID.displayName consists of (Server|Client)Prefix + device name
    static let serverPrefix = "Server: "
    static let clientPrefix = "Client: "
}

extension MCPeerID {
    var isServer: Bool { return displayName.hasPrefix(HeartVoiceService.serverPrefix) }
    var isClient: Bool { return displayName.hasPrefix(HeartVoiceService.clientPrefix) }
    var displayNameWithoutPrefix: String {
        if isServer {
            return String(displayName.dropFirst(HeartVoiceService.serverPrefix.count))
        }
        if isClient {
            return String(displayName.dropFirst(HeartVoiceService.clientPrefix.count))
        }
        return displayName
    }
}

extension MCSession {
    var server: MCPeerID? {
        return connectedPeers.filter {$0.isServer}.first
    }

    var clients: [MCPeerID] {
        return connectedPeers.filter {$0.isClient}
    }
}
