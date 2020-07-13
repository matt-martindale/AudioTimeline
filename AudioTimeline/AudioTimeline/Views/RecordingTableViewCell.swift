//
//  RecordingTableViewCell.swift
//  AudioTimeline
//
//  Created by Matthew Martindale on 7/12/20.
//  Copyright © 2020 Matthew Martindale. All rights reserved.
//

import UIKit

class RecordingTableViewCell: UITableViewCell {

    var recording: Recording? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    func updateViews() {
        guard let recording = recording else { return }
        titleLabel.text = recording.title
        durationLabel.text = recording.duration
    }

}
