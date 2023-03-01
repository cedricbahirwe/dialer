//
//  SpeakerView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 26/02/2023.
//

import SwiftUI

struct SpeakerView: View {
    @State private var isSpeaking = false

    var body: some View {
        VStack {

            LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .topLeading, endPoint: .trailing)
                .frame(width: 50, height: 50)
                .mask(
                    Image(systemName: isSpeaking ? "waveform.circle.fill" : "mic.circle.fill")
                        .resizable()
                        .scaledToFit()
                )
                .scaleEffect(isSpeaking ? 1.3 : 1)
                .animation(.spring(), value: isSpeaking)
                .padding(.bottom, isSpeaking ? 70 : 60)
                .onTapGesture {
                    isSpeaking.toggle()
                }
        }
    }
}

struct SpeakerView_Previews: PreviewProvider {
    static var previews: some View {
        SpeakerView()
            
    }
}
