//
//  AudioVizualizerAK5App.swift
//  AudioVizualizerAK5
//
//  Created by Matt Pfeiffer on 12/23/20.
//

import SwiftUI

@main
struct AudioVizualizerAK5App: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(Conductor.shared)
        }
    }
}
