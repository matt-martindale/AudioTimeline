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
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecordingSegue" {
            let recordingVC = segue.destination as? RecordingViewController
            recordingVC?.recordingController = recordingController
        }
    }

}
