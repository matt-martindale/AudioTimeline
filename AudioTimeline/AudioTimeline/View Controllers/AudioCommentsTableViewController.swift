//
//  AudioCommentsTableViewController.swift
//  AudioTimeline
//
//  Created by Matthew Martindale on 7/12/20.
//  Copyright © 2020 Matthew Martindale. All rights reserved.
//

import UIKit

class AudioCommentsTableViewController: UITableViewController {
    
    let recordingController = RecordingController()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return recordingController.recordings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingCell", for: indexPath) as? RecordingTableViewCell else { return UITableViewCell() }
        cell.recording = recordingController.recordings[indexPath.row]

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecordingSegue" {
            let recordingVC = segue.destination as? RecordingViewController
            recordingVC?.recordingController = recordingController
        }
    }

}
