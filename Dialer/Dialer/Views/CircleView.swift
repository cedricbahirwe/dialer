//
//  CircleView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 29/06/2023.
//

import SwiftUI

struct CircleView: View {
    private let lineWidth: CGFloat = 6
    
    var body: some View {
        VStack {
            VStack(spacing: 10) {
                Text("This Month")
                    .foregroundColor(.secondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("50")
                        .font(.largeTitle)
                    
                    Text("%")
                }
                
                Text("Intime")
                    .foregroundColor(.secondary)
                
            }
            .padding(30)
            .overlay {
                Circle()
                    .strokeBorder(Color.gray, lineWidth: 2)
            }
            .padding(10)
            .overlay {
                ZStack {
                    Circle()
                        .trim(from: 0, to: 0.1)
                        .stroke(Color.pink,
                                style: StrokeStyle(
                                    lineWidth: lineWidth,
                                    lineCap: .round,
                                    miterLimit: 10))
                    
                    Circle()
                        .trim(from: 0.12, to: 0.2)
                        .stroke(Color.orange,
                                style: StrokeStyle(
                                    lineWidth: lineWidth,
                                    lineCap: .round,
                                    miterLimit: 10))
                    
                    
                    
                    Circle()
                        .trim(from: 0.22, to: 0.5)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.purple.opacity(0.5),
                                    Color.purple,
                                    Color.purple], startPoint: .leading, endPoint: .trailing)
                            ,
                            style: StrokeStyle(
                                lineWidth: lineWidth,
                                lineCap: .round,
                                miterLimit: 10))
                    
                    Circle()
                        .trim(from: 0.52, to: 0.98)
                        .stroke(
                            LinearGradient(colors: [Color.blue.opacity(0.5), Color.blue], startPoint: .trailing, endPoint: .leading)
                            ,
                            style: StrokeStyle(
                                lineWidth: lineWidth,
                                lineCap: .round,
                                miterLimit: 10))
                }
                .rotationEffect(Angle(degrees: 90))
            }
            
        }
    }
}

struct CircleView_Previews: PreviewProvider {
    static var previews: some View {
        CircleView()
    }
}
