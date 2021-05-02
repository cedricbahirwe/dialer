//
//  DashBoardExtension.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/04/2021.
//

import SwiftUI

extension DashBoardView {
    var headerView: some View {
        VStack {
            if !isSearching {
                HStack {
                    Spacer()
                    Button {
                        
                    } label: {
                        Text("Edit")
                    }
                }
            }
            
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search", text: .constant(""))
                        .onTapGesture {
                            withAnimation {
                                isSearching = true
                            }
                        }
                }
                .padding(.horizontal, 10)
                .frame(height: 40)
                .background(Color(.tertiaryLabel).opacity(0.3))
                .cornerRadius(10)
                
                if isSearching {
                    Button {
                        withAnimation {
                            isSearching = false
                        }
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                        to: nil,
                                                        from: nil,
                                                        for: nil)
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            Color(.secondarySystemBackground)
                .opacity(isSearching ? 1 : 0)
                .ignoresSafeArea(.all, edges: .top)
        )
    }
    
    var bottomBarView: some View {
        HStack {
            Button {
                
            } label: {
                Label("New Dial", systemImage: "plus.circle.fill")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
            }
            
            Spacer()
            Button {
                
            } label: {
                Text("Add Code")
                    .font(.callout)
            }
        }
        .padding(.horizontal)
        .padding(.bottom,8)
    }
}
