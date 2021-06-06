//
//  Testingview.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 06/06/2021.
//

import SwiftUI

struct Testingview: View {
    let shortcuts = UIApplication.shared.shortcutItems
    var body: some View {
        VStack {
            if let items = shortcuts {
                ForEach(items, id:\.self) { item in
                    Text(item.localizedTitle)
                        .onTapGesture {
                            UIApplication.shared.shortcutItems?.removeFirst()
                        }
                }
            } else {
                Text("No shorcuts")
            }
            
        }
    }
}

struct Testingview_Previews: PreviewProvider {
    static var previews: some View {
        Testingview()
    }
}
