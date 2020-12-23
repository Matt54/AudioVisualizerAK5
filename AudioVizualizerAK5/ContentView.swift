//
//  ContentView.swift
//  AudioVizualizerAK5
//
//  Created by Matt Pfeiffer on 12/23/20.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var conductor: Conductor
    
    var body: some View {
        ZStack{
            VisualizerBars(amplitudes: $conductor.amplitudes, linearGradient: $conductor.linearGradient)
        }
        .onTapGesture {
            self.conductor.colorChange()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Conductor.shared)
    }
}
