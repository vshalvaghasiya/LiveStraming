//
//  BroadCastViewController.swift
//  LiveStraming
//
//  Created by Admin on 09/01/19.
//  Copyright © 2019 VISHAL. All rights reserved.
//

import UIKit
import SocketIO
import LFLiveKit
class BroadCastViewController: UIViewController, LFLiveSessionDelegate {

     let socket = SocketIOClient(socketURL: URL(string: serverUrl)!, config: [.log(true), .forceWebsockets(true)])
    lazy var session: LFLiveSession = {
        let audioConfiguration = LFLiveAudioConfiguration.defaultConfiguration(for: .low)
        let videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: .low3)
        
        let session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)!
        session.delegate = self
        session.captureDevicePosition = .back
        session.preView = self.view
        return session
    }()
    
    @IBOutlet weak var lbl_Timer: UILabel!
    var seconds = 0
    var timer = Timer()
    var isTimerRunning = false
    override func viewDidLoad() {
        super.viewDidLoad()
        startStraming()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session.running = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.running = false
        stopStraming()
    }
    
    @IBAction func switchButtonClick(_ sender: UIButton) {
        if (session.captureDevicePosition == .front) {
            session.captureDevicePosition = .back
        } else {
            session.captureDevicePosition = .front
        }
        
    }
    
    
    func startStraming(){
        let stream = LFLiveStreamInfo()
        stream.url = "\(rtmpPushUrl)62767778"
        session.startLive(stream)
        socket.connect()
        print("Start Straming: \(rtmpPushUrl)62767778")
        socket.once("connect") {[weak self] data, ack in
            guard let this = self else {
                return
            }
            this.socket.emit("create_room", with: ["62767778"])
//            this.socket.emit("create_room", with: this.room.toDict())
            self?.StartTimer()
        }
    }
    
    func StartTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(self.UpdateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
    }
    
    @objc func UpdateTimer() {
        seconds += 1
        lbl_Timer.text = timeString(time: TimeInterval(seconds))
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func stopStraming(){
        session.stopLive()
        socket.disconnect()
    }

    //MARK: LFLiveSessionDelegate Method
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
