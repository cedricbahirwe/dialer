//
//  PinView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/05/2021.
//

import SwiftUI

struct PinView: View {
    @State private var didCopyToClipBoard = false
    @Binding var input: String
    public var isFullMode: Bool = false
    public var btnSize: CGFloat = 60

    private var buttons: [String] {
        var defaults: [String] = ["1","2","3","4","5","6","7","8", "9", isFullMode ? "*" : "copy","0"]
        
        defaults += isFullMode ? ["#"] : ["X"]
        return defaults
    }
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
        ], spacing: 10) {
            ForEach(buttons, id: \.self) { button in
                ZStack {
                    CircleButton(button, size: btnSize,
                                 action: { addKey(button)})
                        .foregroundColor(
                            button == "X" ?
                            Color.red :
                                Color(.label)
                        )
                        .opacity(!isFullMode && button == "*" ? 0 : 1)
                        .opacity(input.isEmpty && button == "X" ? 0 : 1)
                        .opacity((button == "copy" && didCopyToClipBoard) ? 0 : 1)

                    if (button == "copy" && didCopyToClipBoard) {
                        Image(systemName: "checkmark")
                            .font(.callout.weight(.black))
                            .foregroundColor(.green)
                            .frame(width: btnSize, height: btnSize)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                
            }
        }
    }
    
    private func addKey(_ value: String) {
        if value == "copy" {
            copyToClipBoard()
            return
        }
        if value == "X" {
            if !input.isEmpty {
                input.removeLast()
            }
        } else {
            input.append(value)
        }
    }

    private func copyToClipBoard() {
        UIPasteboard.general.string = input
        didCopyToClipBoard = true
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            didCopyToClipBoard = false
        }
    }
}

extension Int {
    var stringBind: String {
        get { String(self) }
        set(value) { self = Int(value) ?? 0 }
    }
}


struct PinView_Previews: PreviewProvider {
    static var previews: some View {
        PinView(input: .constant("*182#"))
    }
}

struct CircleButton: View {
    
    let title: String
    let size: CGFloat
    let action: () -> Void

    
    init(_ title: String, size: CGFloat, action: @escaping () -> Void) {
        self.title = title
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Group {
                if title == "copy" {
                    Image(systemName: "doc.on.doc.fill")
                        .frame(width: 45, height: 45)
                } else {
                    Text(title)
                }
            }
            .frame(width: size, height: size)
            .background(Color.gray.opacity(0.2))
            .clipShape(Circle())
        }
    }
}
