//
//  StramingPlayViewController.swift
//  LiveStraming
//
//  Created by Admin on 09/01/19.
//  Copyright © 2019 VISHAL. All rights reserved.
//

import UIKit
import SocketIO
import LFLiveKit
import IJKMediaFramework
class StramingPlayViewController: UIViewController, LFLiveSessionDelegate {

    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var lbl_Timer: UILabel!
    var propertyID = "62767778"
    
    var player: IJKFFMoviePlayerController!
    let socket = SocketIOClient(socketURL: URL(string: serverUrl)!, config: [.log(true), .forcePolling(true)])
    
    lazy var session: LFLiveSession = {
        let audioConfiguration = LFLiveAudioConfiguration.defaultConfiguration(for: .low)
        let videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: .low3)
        
        let session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)!
        session.delegate = self
        session.captureDevicePosition = .back
        session.preView = self.view
        return session
    }()
    
    var seconds = 0
    var timer = Timer()
    var isTimerRunning = false
    var urlString = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlString = "\(rtmpPlayUrl)\(propertyID)"
        PlayStreaming()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        urlString = "\(rtmpPlayUrl)\(propertyID)"
        print("Play Straming: \(rtmpPlayUrl)\(propertyID)")
        player = IJKFFMoviePlayerController(contentURLString: urlString, with: IJKFFOptions.byDefault())
        if !player.isPlaying()
        {
            player.prepareToPlay()
            player.play()
        }
        socket.connect()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        player.pause()
        player.stop()
        socket.disconnect()
        NotificationCenter.default.removeObserver(self)
    }
    
    func PlayStreaming(){
        player = IJKFFMoviePlayerController(contentURLString: urlString, with: IJKFFOptions.byDefault())
        NotificationCenter.default.addObserver(forName: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: player, queue: OperationQueue.main, using: { [weak self] notification in
            
            guard let this = self else {
                return
            }
            let state = this.player.loadState
            switch state {
            case IJKMPMovieLoadState.playable:
                print("playable")
            case IJKMPMovieLoadState.playthroughOK:
                print("playthroughOK")
            case IJKMPMovieLoadState.stalled:
                print("stalled")
            default:
                print("default")
            }        })
        player.view.frame = self.view.bounds
        self.previewView.addSubview(player.view)
        
        if !player.isPlaying()
        {
            player.prepareToPlay()
            player.play()
        }
    
        socket.on("connect") {[weak self] data, ack in
            self?.joinRoom()
        }
    }

    func joinRoom() {
        socket.emit("join_room", propertyID)
        runTimer()
    }

    func StopStreaming() {
        session.stopLive()
        socket.disconnect()
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
    }
    
    @objc func updateTimer() {
        seconds += 1
        lbl_Timer.text = timeString(time: TimeInterval(seconds))
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    //MARK: LFLive Session Delegate Method
    func liveSession(_ session: LFLiveSession?, liveStateDidChange state: LFLiveState) {
        switch state {
        case .error:
            print("error")
        case .pending:
            print("pending")
        case .ready:
            print("ready")
        case.start:
            print("start")
        case.stop:
            print("stop")
        case .refresh:
            print("refresh")
        }
    }
    
    func liveSession(_ session: LFLiveSession?, debugInfo: LFLiveDebug?) {
    }
    
    func liveSession(_ session: LFLiveSession?, errorCode: LFLiveSocketErrorCode) {
    }
    
}
