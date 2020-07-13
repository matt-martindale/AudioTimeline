//
//  RecordingViewController.swift
//  AudioTimeline
//
//  Created by Matthew Martindale on 7/12/20.
//  Copyright © 2020 Matthew Martindale. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var audioVisualizer: AudioVisualizer!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Properties
    var audioPlayer: AVAudioPlayer? {
        didSet {
            guard let audioPlayer = audioPlayer else { return }
            audioPlayer.delegate = self
            audioPlayer.isMeteringEnabled = true
        }
    }
    
    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
        // NOTE: DateComponentFormatter is good for minutes/hours/seconds
        // DateComponentsFormatter is not good for milliseconds, use DateFormatter instead)
        
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional // 00:00  mm:ss
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()
    
    weak var timer: Timer?
    private var duration: String?
    var recordingURL: URL?
    var audioRecorder: AVAudioRecorder?
    var recordingController: RecordingController?

    // MARK: - View Controller Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        print(recordingController?.recordings)
    }
    
    func setUpViews() {
        timeElapsedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeElapsedLabel.font.pointSize,
                                                          weight: .regular)
        timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeRemainingLabel.font.pointSize,
                                                                   weight: .regular)
        // record/stop image
        let configuration = UIImage.SymbolConfiguration(pointSize: 60)
        let micImage = UIImage(systemName: "mic.circle.fill", withConfiguration: configuration)
        let redMic = micImage?.withTintColor(.recordRed, renderingMode: .alwaysOriginal)
        let stopImage = UIImage(systemName: "stop.circle.fill", withConfiguration: configuration)
        let redStop = stopImage?.withTintColor(.recordRed, renderingMode: .alwaysOriginal)
        recordButton.setImage(redMic, for: .normal)
        recordButton.setImage(redStop, for: .selected)
        
        // play/pause image
        let playImage = UIImage(systemName: "play.circle.fill", withConfiguration: configuration)
        let whitePlay = playImage?.withTintColor(.white, renderingMode: .alwaysOriginal)
        let pauseImage = UIImage(systemName: "pause.circle.fill", withConfiguration: configuration)
        let whitePause = pauseImage?.withTintColor(.white, renderingMode: .alwaysOriginal)
        playButton.setImage(whitePlay, for: .normal)
        playButton.setImage(whitePause, for: .selected)
        
        // slider
        timeSlider.thumbTintColor = .barColor
    }
    
    func updateViews() {
        playButton.isEnabled = !isRecording
        recordButton.isEnabled = !isPlaying
        saveButton.isEnabled = !isRecording
        timeSlider.isEnabled = !isRecording
        
        playButton.isSelected = isPlaying
        recordButton.isSelected = isRecording
        
        if !isRecording {
            let elapsedTime = audioPlayer?.currentTime ?? 0
            let duration = audioPlayer?.duration ?? 0
            let timeRemaining = duration.rounded() - elapsedTime
            
            timeElapsedLabel.text = timeIntervalFormatter.string(from: elapsedTime)
            
            timeSlider.minimumValue = 0
            timeSlider.maximumValue = Float(duration)
            timeSlider.value = Float(elapsedTime)
            
            timeRemainingLabel.text = timeIntervalFormatter.string(from: timeRemaining)
        } else {
            let elapsedTime = audioRecorder?.currentTime ?? 0
            
            timeElapsedLabel.text = "--:--"
            
            timeSlider.minimumValue = 0
            timeSlider.maximumValue = 1
            timeSlider.value = 0
            timeRemainingLabel.text = timeIntervalFormatter.string(from: elapsedTime)
        }
    }
    
    // MARK: - Timer
    func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] (_) in
            guard let self = self else { return }
            
            self.updateViews()
            
            if let audioRecorder = self.audioRecorder,
                self.isRecording == true {

                audioRecorder.updateMeters()
                self.audioVisualizer.addValue(decibelValue: audioRecorder.averagePower(forChannel: 0))

            }

            if let audioPlayer = self.audioPlayer,
                self.isPlaying == true {

                audioPlayer.updateMeters()
                self.audioVisualizer.addValue(decibelValue: audioPlayer.averagePower(forChannel: 0))
            }
        }
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Recording
    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }
    
    func requestPermissionOrStartRecording() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                guard granted == true else {
                    print("We need microphone access")
                    return
                }
                
                print("Recording permission has been granted!")
                // NOTE: Invite the user to tap record again, since we just interrupted them, and they may not have been ready to record
            }
        case .denied:
            print("Microphone access has been blocked.")
            
            let alertController = UIAlertController(title: "Microphone Access Denied", message: "Please allow this app to access your Microphone.", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Open Settings", style: .default) { (_) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            present(alertController, animated: true, completion: nil)
        case .granted:
            startRecording()
        @unknown default:
            break
        }
    }
    
    func createNewRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
        
        return file
    }
    
    func startRecording() {
        do {
            try prepareAudioSession()
        } catch {
            print("Cannot record audio: \(error)")
            return
        }
        
        recordingURL = createNewRecordingURL()
        
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        
        do {
            audioRecorder = try AVAudioRecorder(url: recordingURL!, format: format)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            
            
            updateViews()
            startTimer()
        } catch {
            preconditionFailure("The audio recorder could not be created with \(recordingURL!) and \(format): \(error)")
        }
    }
    
    func stopRecording() {
        guard let duration = timeRemainingLabel.text else { return }
        self.duration = duration
        audioRecorder?.stop()
        updateViews()
        cancelTimer()
    }
    
    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: []) // can fail if on a phone call, for instance
    }
    
    // MARK: - Playing
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    func play() {
        do {
            try prepareAudioSession()
            audioPlayer?.play()
            updateViews()
            startTimer()
        } catch {
            print("Cannot play audio: \(error)")
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        updateViews()
        cancelTimer()
    }
    
    // MARK: - IBActions

    @IBAction func recordButtonTapped(_ sender: Any) {
        if isRecording {
            stopRecording()
        } else {
            requestPermissionOrStartRecording()
        }
    }
    
    @IBAction func updateTimeSlider(_ sender: UISlider) {
        if isPlaying {
            pause()
        }
        audioPlayer?.currentTime = TimeInterval(sender.value)
        updateViews()
    }
    
    @IBAction func togglePlayback(_ sender: Any) {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        displaySaveAlert()
    }
    
    func displaySaveAlert() {
        let alert = UIAlertController(title: "Save Recording", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Title"
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self](_) in
            guard let title = alert.textFields?[0].text,
                let recordingURL = self?.recordingURL,
                let duration = self?.duration else { return }
            
            // Save Recording object
            let newRecording = Recording(url: recordingURL, title: title, duration: duration)
            self?.recordingController?.addRecording(recording: newRecording)
            print(newRecording)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}

extension RecordingViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if let recordingURL = recordingURL {
            audioPlayer = try? AVAudioPlayer(contentsOf: recordingURL)
        }
        audioRecorder = nil
        cancelTimer()
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Audio Recorder Error: \(error)")
        }
    }
}

extension RecordingViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            updateViews()
            cancelTimer()
        }
        
        func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
            if let error = error {
                print("Error decoding audio: \(error)")
            }
        }
    }

