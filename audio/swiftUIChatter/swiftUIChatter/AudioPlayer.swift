//
//  AudioPlayer.swift
//  swiftUIChatter
//
//  Created by Aryan Pal on 10/1/24.
//

import Foundation
import AVFoundation
import Observation

enum StartMode {
    case standby, record, play
}
enum PlayerState: Equatable {
    case start(StartMode)
    case recording
    case playing(StartMode)
    case paused(StartMode)
}
enum TransEvent {
    case recTapped, playTapped, stopTapped, doneTapped, failed
}

extension PlayerState{
    mutating func transition(_ event: TransEvent) {
        if event == .doneTapped {
            self = .start(.standby) // When doneTapped, reset to standby
            return
        }
        
        // Switch on the current state
        switch self {
        
        // Transition from start state with mode `.record`
        case .start(.record) where event == .recTapped:
            self = .recording

        // Transition from start state with mode `.play`
        case .start(.play) where event == .playTapped:
            self = .playing(.play)

        // Handle `.standby` state with different events
        case .start(.standby):
            switch event {
            case .recTapped:
                self = .recording
            case .playTapped:
                self = .playing(.standby)
            default:
                break
            }

        // Transition when in recording state
        case .recording:
            switch event {
            case .recTapped, .stopTapped:
                self = .start(.standby)
            case .failed:
                self = .start(.record)
            default:
                break
            }

        // Transition when in playing state
        case .playing(let parent):
            switch event {
            case .playTapped:
                self = .paused(parent)
            case .stopTapped, .failed:
                self = .start(parent)
            default:
                break
            }

        // Transition when in paused state
        case .paused(let grand):
            switch event {
            case .recTapped:
                self = .recording
            case .playTapped:
                self = .playing(grand)
            case .stopTapped:
                self = .start(.standby)
            default:
                break
            }

        // Default case to catch any other states or events
        default:
            break
        }
    }
}

@Observable
final class AudioPlayer: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    var audio: Data! = nil
    private let audioFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("chatteraudio.m4a")
    
    @ObservationIgnored let playerUIState = PlayerUIState()
    @ObservationIgnored var playerState = PlayerState.start(.standby) {
        didSet { playerUIState.propagate(playerState) }
    }
    
    private let audioSession = AVAudioSession.sharedInstance()
    private var audioRecorder: AVAudioRecorder! = nil
    private var audioPlayer: AVAudioPlayer! = nil

    override init() {
        super.init()

        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("AudioPlayer: failed to setup AVAudioSession")
        }
    }
    
    func setupRecorder() {
        playerState = .start(.record)
        audio = nil
        
        guard let _ = audioRecorder else {
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            audioRecorder = try? AVAudioRecorder(url: audioFilePath, settings: settings)
            guard let _ = audioRecorder else {
                print("setupRecorder: failed")
                return
            }
            audioRecorder.delegate = self
            return
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error encoding audio: \(error!.localizedDescription)")
        audioRecorder.stop()
        playerState.transition(.failed)
    }

    func setupPlayer(_ audioStr: String) {
        playerState = .start(.play)
        audio = Data(base64Encoded: audioStr, options: .ignoreUnknownCharacters)
        preparePlayer()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Error decoding audio \(error?.localizedDescription ?? "on playback")")
        // don't dismiss, in case user wants to record
        playerState.transition(.failed)
    }
    private func preparePlayer() {
        audioPlayer = try? AVAudioPlayer(data: audio)
        guard let audioPlayer else {
            print("preparePlayer: incompatible audio encoding, not m4a?")
            return
        }
        audioPlayer.volume = 10.0
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playerState.transition(.stopTapped)
    }
    func playTapped() {
        guard let audioPlayer else {
            print("playTapped: no audioPlayer!")
            return
        }
        playerState.transition(.playTapped)
        if audioPlayer.isPlaying {
            audioPlayer.pause()
        } else {
            audioPlayer.play()
        }
    }
    func rwndTapped() {
        audioPlayer.currentTime = max(0, audioPlayer.currentTime - 10.0) // seconds
    }

    func ffwdTapped() {
        audioPlayer.currentTime = min(audioPlayer.duration, audioPlayer.currentTime + 10.0) // seconds
    }
    
    func stopTapped() {
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        playerState.transition(.stopTapped)
    }
}
