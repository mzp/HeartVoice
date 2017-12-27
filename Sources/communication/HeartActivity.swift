//
//  HeartActivity.swift
//  HeartVoice
//
//  Created by mzp on 2017/12/27.
//  Copyright © 2017 mzp. All rights reserved.
//

struct HeartActivity: Equatable, Codable {
    var heartrate: Int

    init(_ heartrate: Int) {
        self.heartrate = heartrate
    }

    static func == (lhs: HeartActivity, rhs: HeartActivity) -> Bool {
        return lhs.heartrate == rhs.heartrate
    }
}
