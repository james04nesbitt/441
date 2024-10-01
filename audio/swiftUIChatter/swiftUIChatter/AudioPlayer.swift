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
