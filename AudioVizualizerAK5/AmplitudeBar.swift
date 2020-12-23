//
//  AmplitudeBar.swift
//  AudioVizualizerAK5
//
//  Created by Matt Pfeiffer on 12/23/20.
//

import SwiftUI

struct AmplitudeBar: View {
    @Binding var amplitude: Double
    @Binding var linearGradient : LinearGradient
    
    var body: some View {
        GeometryReader
            { geometry in
            ZStack(alignment: .bottom){
                
                // Colored rectangle in back of ZStack
                Rectangle()
                    .fill(self.linearGradient)
                
                    // blue/purple bar style - try switching this out with the .fill statement above
                    //.fill(LinearGradient(gradient: Gradient(colors: [Color.init(red: 0.0, green: 1.0, blue: 1.0), .blue, .purple]), startPoint: .top, endPoint: .bottom))
                
                // Dynamic black mask padded from bottom in relation to the amplitude
                Rectangle()
                    .fill(Color.black)
                    .mask(Rectangle().padding(.bottom, geometry.size.height * CGFloat(self.amplitude)))
                    .animation(.easeOut(duration: 0.15))
                
                // White bar with slower animation for floating effect
                Rectangle()
                    .fill(Color.white)
                    .frame(height: geometry.size.height * 0.005)
                    .offset(x: 0.0, y: -geometry.size.height * CGFloat(self.amplitude) - geometry.size.height * 0.02)
                    .animation(.easeOut(duration: 0.6))
                
            }
            .padding(geometry.size.width * 0.1)
            .border(Color.black, width: geometry.size.width * 0.1)
        }
    }
}

struct AmplitudeBar_Previews: PreviewProvider {
    static var previews: some View {
        AmplitudeBar(amplitude: .constant(0.8), linearGradient: .constant(LinearGradient(gradient: Gradient(colors: [.red, .yellow, .green]), startPoint: .top, endPoint: .center)))
        .previewLayout(.fixed(width: 40, height: 500))
    }
}
