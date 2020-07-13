//
//  Recording.swift
//  AudioTimeline
//
//  Created by Matthew Martindale on 7/12/20.
//  Copyright © 2020 Matthew Martindale. All rights reserved.
//

import Foundation

struct Recording: Codable, Equatable {
    var url: URL
    var title: String
    var duration: String
}
