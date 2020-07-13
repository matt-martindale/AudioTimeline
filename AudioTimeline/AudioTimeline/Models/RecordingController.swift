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
        saveToPersistentStore()
    }

    init() {
        loadFromPersistentStore()
    }
    
    private var persistentFileURL: URL? {
        //Singleton = single instance that can be used throughout the app
        let fileManager = FileManager.default
        guard let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            else { return nil }
        
        //Users/johhnyhicks/Documents
        return documents.appendingPathComponent("recordings.plist")
    }
    
    func saveToPersistentStore() {
        //Star -> Data -> Plist
        guard let url = persistentFileURL else { return }
        
        do {
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(recordings)
            try data.write(to: url)
        } catch {
            print("Error saving stars data: \(error)")
        }
    }
    
    func loadFromPersistentStore() {
        //Plist -> Data -> Stars
        let fileManager = FileManager.default
        guard let url = persistentFileURL, fileManager.fileExists(atPath: url.path) else { return }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            recordings = try decoder.decode([Recording].self, from: data)
        } catch {
            print("Error loading stars data: \(error)")
        }
    }
}
