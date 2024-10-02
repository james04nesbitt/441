//
//  swiftUIChatterApp.swift
//  swiftUIChatter
//
//  Created by James Nesbitt on 9/14/24.
//

import SwiftUI

@main
struct swiftUIChatterApp: App {
    init() {
            ChattStore.shared.getChatts()
        }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainView()
            }
            .environment(AudioPlayer())
        }
    }
}
