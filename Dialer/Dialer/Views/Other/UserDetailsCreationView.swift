//
//  UserDetailsCreationView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 02/08/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct UserDetailsCreationView: View {
    @State private var username = ""
    @FocusState var isFocused: Bool
    var body: some View {
        VStack {
            Text("We are **Dialer**")
                .font(.title)
                .fontDesign(.rounded)
            
            Spacer()
            
            Text("How should we call you?")
                .fontWeight(.heavy)
            
            VStack(spacing: 20) {

                TextField("", text: $username)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .bold()
                    .focused($isFocused)
                    .textContentType(.nickname)
                    .textInputAutocapitalization(.never)
                    .overlay {
                        
                        if username.isEmpty {
                            Text("username")
                                .foregroundStyle(.secondary)
                                .font(.title.bold())
                                .allowsHitTesting(false)
                        }
                    }
                
                VStack(spacing: 24.0) {
//                    Text("we'll use this throughout the app 👀")
//                        .font(.callout)
//                        .hidden()
                    Button {
                        
                    } label: {
                        Label("next", systemImage: "arrow.right")
                            .fontWeight(.semibold)
                            .padding(10)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                }
            }
            Spacer()
        }
        .frame(maxHeight: .infinity)
        .fontDesign(.rounded)
        .safeAreaInset(edge: .top) {
            HStack {
                Button("Cancel", systemImage: "xmark") {
                    
                }
                .labelStyle(.iconOnly)
                .bold()
                
                Spacer()
                
            }
            .padding()
        }
        .foregroundStyle(.white)
        .background(.matteBlack, ignoresSafeAreaEdges: .all)
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
                isFocused = true
            }
        }
    }
}

#Preview {
    UserDetailsCreationView()
}
