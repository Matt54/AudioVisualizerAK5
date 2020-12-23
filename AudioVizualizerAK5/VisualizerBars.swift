//
//  VisualizerBars.swift
//  AudioVizualizerAK5
//
//  Created by Matt Pfeiffer on 12/23/20.
//

import SwiftUI

struct VisualizerBars: View {
    @Binding var amplitudes: [Double]
    @Binding var linearGradient : LinearGradient
    
    var body: some View {
        HStack(spacing: 0.0){
            ForEach(0 ..< self.amplitudes.count) { number in
                AmplitudeBar(amplitude: self.$amplitudes[number], linearGradient: self.$linearGradient)
            }
        }
        .background(Color.black)
    }
}

struct VisualizerBars_Previews: PreviewProvider {
    static var previews: some View {
        VisualizerBars(amplitudes: .constant(Array(repeating: 1.0, count: 50)), linearGradient: .constant(LinearGradient(gradient: Gradient(colors: [Color.init(red: 0.0, green: 1.0, blue: 1.0), .blue, .purple]), startPoint: .top, endPoint: .bottom)))
    }
}
