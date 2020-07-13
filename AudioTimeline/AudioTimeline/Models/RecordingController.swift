//
//  RecordingController.swift
//  AudioTimeline
//
//  Created by Matthew Martindale on 7/12/20.
//  Copyright © 2020 Matthew Martindale. All rights reserved.
//

import Foundation

class RecordingController {
    var recordings: [Recording] = []
    
    func addRecording(recording: Recording) {
        recordings.append(recording)
    }
}
