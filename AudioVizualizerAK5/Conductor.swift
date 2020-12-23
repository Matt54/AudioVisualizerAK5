//
//  Conductor.swift
//  AudioVizualizerAK5
//
//  Created by Matt Pfeiffer on 12/23/20.
//

import AudioKit
import Foundation
import SwiftUI

/**
 This is the persistent data object that binds to the SwiftUI views.
 You can think of it as the model that holds all of our objects.
 The ChoirEffect class is likely all you need from this project, but the rest of this class should demonstrate how to interface with it functionality.
 */
class Conductor : ObservableObject{
    
    /// Single shared data model
    static let shared = Conductor()
    
    /// Audio engine instance
    let engine = AudioEngine()
        
    /// default microphone
    var mic: AudioEngine.InputNode
    
    /// mixing node for microphone input - routes to plotting and recording paths
    let micMixer : Mixer
    
    /// mixer with no volume so that we don't output audio
    let silentMixer : Mixer
    
    /// time interval in seconds for repeating timer callback
    let refreshTimeInterval : Double = 0.02
    
    /// tap for the fft data
    var fft : FFTTap!
    
    /// size of fft
    let FFT_SIZE = 512
    
    /// audio sample rate
    let sampleRate : double_t = 44100
    
    /// limiter to prevent excessive volume at the output - just in case, it's the music producer in me :)
    let outputLimiter : PeakLimiter
    
    /// bin amplitude values (range from 0.0 to 1.0)
    @Published var amplitudes : [Double] = Array(repeating: 0.5, count: 50)
    
    @Published var linearGradient = LinearGradient(gradient: Gradient(colors: [.red, .yellow, .green]), startPoint: .top, endPoint: .center)
    
    var gradientList = [Gradient(colors: [.red, .yellow, .green]),
                        Gradient(colors: [Color.init(red: 0.0, green: 1.0, blue: 1.0), .blue, .purple]),
                        Gradient(colors: [Color.init(red: 86/255, green: 18/255, blue: 16/255),
                                            Color.init(red: 240/255, green: 146/255, blue: 34/255),
                                            Color.init(red: 246/255, green: 236/255, blue: 32/255)])]
    
    var colorIndex = 0
    
    init(){
        guard let input = engine.input else {
            fatalError()
        }
        mic = input
        
        micMixer = Mixer(mic)
        
        silentMixer = Mixer(micMixer)
        
        // route the silent Mixer to the limiter (you must always route the audio chain to AudioKit.output)
        outputLimiter = PeakLimiter(silentMixer)
        
        // set the limiter as the last node in our audio chain
        engine.output = outputLimiter
        
        // connect the fft tap to the mic mixer (this allows us to analyze the audio at the micMixer node)
        fft = FFTTap(micMixer) { fftData in
            DispatchQueue.main.async {
                self.update(fftData)
            }
        }
        
        silentMixer.volume = 0.0
        
        // route the audio from the microphone to the limiter
        //setupMic()
        
        
        
        // do any AudioKit setting changes before starting the AudioKit engine
        setAudioKitSettings()
        
        //START AUDIOKIT
        do{
            try engine.start()
            fft.start()
        }
        catch{
            assert(false, error.localizedDescription)
        }
        
        // create a repeating timer at the rate of our chosen time interval - this updates the amplitudes each timer callback
        /*Timer.scheduledTimer(withTimeInterval: refreshTimeInterval, repeats: true) { timer in
            self.updateAmplitudes()
        }*/
        
    }
    
    /// Sets AudioKit to appropriate settings
    func setAudioKitSettings(){
        do {
            try Settings.setSession(category: .ambient, with: [.mixWithOthers])
        } catch {
            Log("Could not set session category.")
        }
    }
    
    /// Does all the setup required for microphone input
    /*func setupMic(){
        // route mic to the micMixer which is tapped by our fft
        micMixer.addInput(mic)
        
        // route mixMixer to a mixer with no volume so that we don't output audio
        silentMixer.addInput(micMixer)
        silentMixer.volume = 0.0
    }*/
    
    func update(_ fftData: [Float]){
        for i in stride(from: 0, to: self.FFT_SIZE - 1, by: 2) {
            
            print(fftData)
            
            //print(fft.fftData)

            // get the real and imaginary parts of the complex number
            let real = fftData[i]
            let imaginary = fftData[i + 1]
            
            let normalizedBinMagnitude = 2.0 * sqrt(real * real + imaginary * imaginary) / Float(self.FFT_SIZE)
            let amplitude = Double(20.0 * log10(normalizedBinMagnitude))
            
            // scale the resulting data
            var scaledAmplitude = (amplitude + 250) / 229.80
            
            // restrict the range to 0.0 - 1.0
            if (scaledAmplitude < 0) {
                scaledAmplitude = 0
            }
            if (scaledAmplitude > 1.0) {
                scaledAmplitude = 1.0
            }
            
            // add the amplitude to our array (further scaling array to look good in visualizer)
            DispatchQueue.main.async {
                if(i/2 < self.amplitudes.count){
                    self.amplitudes[i/2] = self.mapy(n: scaledAmplitude, start1: 0.3, stop1: 0.9, start2: 0.0, stop2: 1.0)
                }
            }
        }
    }
    
    /// Analyze fft data and write to our amplitudes array
    @objc func updateAmplitudes(){
        
        // loop by two through all the fft data
        for i in stride(from: 0, to: self.FFT_SIZE - 1, by: 2) {
            
            //print(fft.fftData)

            // get the real and imaginary parts of the complex number
            let real = fft.fftData[i]
            let imaginary = fft.fftData[i + 1]
            
            let normalizedBinMagnitude = 2.0 * sqrt(real * real + imaginary * imaginary) / Float(self.FFT_SIZE)
            let amplitude = Double(20.0 * log10(normalizedBinMagnitude))
            
            // scale the resulting data
            var scaledAmplitude = (amplitude + 250) / 229.80
            
            // restrict the range to 0.0 - 1.0
            if (scaledAmplitude < 0) {
                scaledAmplitude = 0
            }
            if (scaledAmplitude > 1.0) {
                scaledAmplitude = 1.0
            }
            
            // add the amplitude to our array (further scaling array to look good in visualizer)
            DispatchQueue.main.async {
                if(i/2 < self.amplitudes.count){
                    self.amplitudes[i/2] = self.mapy(n: scaledAmplitude, start1: 0.3, stop1: 0.9, start2: 0.0, stop2: 1.0)
                }
            }
        }
        
    }
    
    /// simple mapping function to scale a value to a different range
    func mapy(n:Float, start1:Float, stop1:Float, start2:Float, stop2:Float) -> Float {
        return ((n-start1)/(stop1-start1))*(stop2-start2)+start2;
    };
    
    /// simple mapping function to scale a value to a different range
    func mapy(n:Double, start1:Double, stop1:Double, start2:Double, stop2:Double) -> Double {
        return ((n-start1)/(stop1-start1))*(stop2-start2)+start2;
    };
    
    func colorChange(){
        
        colorIndex += 1
        if (colorIndex > gradientList.count-1){
            colorIndex = 0
        }
        
        linearGradient = LinearGradient(gradient: gradientList[colorIndex], startPoint: .top, endPoint: .center)
        print("colorChange")
    }
    
}
