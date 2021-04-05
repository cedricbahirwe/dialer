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
                            
                            Text("History")
                                .foregroundColor(Color(.label))
                                .font(Font.system(size: 22, weight: .semibold, design: .rounded))
                                .textCase(.lowercase)
                            
                            
                            
                            Spacer()
                            ProgressView()
                        }
            ) {
                ForEach(data.recentCodes!) { recentCode in
                    NavigationLink(destination:Text("Destination"))
                    {
                        HStack {
                            Image(systemName: "chevron.left.slash.chevron.right")
                                .imageScale(.small)
                                .frame(width: 30, height: 30)
                                .background(Color.black)
                                .clipShape(Circle())
                                .foregroundColor(.white)
                            Text(recentCode.code)
                                .foregroundColor(Color(.label))
                                .fontWeight(.semibold)
                            Spacer()
                            Text(recentCode.count.description)
                                .foregroundColor(.gray)
                        }
                        .contextMenu(ContextMenu(menuItems: {
                            Button {
                                data.deleteRecentCode(code: recentCode)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                data.performQuickDial(for: recentCode.code)
                            } label: {
                                Label("Dial", systemImage: "phone.circle")
                            }
                        }))
                        
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
