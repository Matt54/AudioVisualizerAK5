//
//  ContentView.swift
//  AudioVizualizerAK5
//
//  Created by Matt Pfeiffer on 12/23/20.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var conductor: Conductor
    @State var filterLowPassPercentage : Double = 1.0
    
    var body: some View {
        ZStack{
            Color.black
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            VStack{
                FFTView(amplitudes: conductor.amplitudes)
                Slider(value: $filterLowPassPercentage, in: 0...1.0)
                    .onChange(of: filterLowPassPercentage, perform: { value in
                        conductor.filter.cutoffFrequency = Float(800 * filterLowPassPercentage)
                        print(conductor.filter.cutoffFrequency)
                    })
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Conductor.shared)
    }
}
