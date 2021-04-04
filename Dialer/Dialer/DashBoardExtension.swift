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
        .background(Color.white.opacity(isSearching ? 1 : 0).ignoresSafeArea(.all, edges: .top))
    }
    
    var bottomSectionView: some View {
        Form {
            Section(header:
                        HStack(spacing:0) {
                            
                            Text("My Lists")
                                .foregroundColor(Color(.label))
                                .font(Font.system(size: 22, weight: .semibold, design: .rounded))
                                .textCase(.lowercase)
                            
                            
                            
                            Spacer()
                            ProgressView()
                        }
            ) {
                ForEach(0..<3) { i in
                    NavigationLink(destination:Text("Destination"))
                    {
                        HStack {
                            Image(systemName: "list.bullet")
                                .imageScale(.small)
                                .frame(width: 30, height: 30)
                                .background(Color.black)
                                .clipShape(Circle())
                                .foregroundColor(.white)
                            Text("The line \(i)")
                                .foregroundColor(Color(.label))
                            Spacer()
                            Text("\(i+1)")
                                .foregroundColor(.gray)
                        }
                        
                    }
                }
            }
        }
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
