//
//  RecordingViewController.swift
//  AudioTimeline
//
//  Created by Matthew Martindale on 7/12/20.
//  Copyright © 2020 Matthew Martindale. All rights reserved.
//

import UIKit

class RecordingViewController: UIViewController {
    
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var playRecordButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    func setUpViews() {
        let configuration = UIImage.SymbolConfiguration(pointSize: 60)
        let micImage = UIImage(systemName: "mic.circle.fill", withConfiguration: configuration)
        playRecordButton.setImage(micImage, for: .normal)
        playRecordButton.contentHorizontalAlignment = .center
        playRecordButton.contentVerticalAlignment = .center
    }

   

}
