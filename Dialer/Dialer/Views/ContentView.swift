//
//  ContentView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 08/02/2021.
//

import SwiftUI
import RevenueCat

struct ContentView: View {
    @EnvironmentObject private var data: MainViewModel

    @EnvironmentObject private var forceUpdate: ForceUpdateManager
    var body: some View {
        NavigationView {
            DashBoardView()
                .task {
                    do {
                        UserViewModel.shared.offerings = try await Purchases.shared.offerings()
                    } catch {
                        print("Error fetching offerings: \(error)")
                    }
                }
        }
        .navigationViewStyle(.stack)
        .onAppear(perform: setupAppearance)
        .alert(Text("App Update"),
               isPresented: forceUpdate.isPresented,
               presenting: forceUpdate.updateAlert) { alert in

            ForEach(alert.buttons) {
                Button($0.title, action: $0.action)
            }
        } message: {
            Text($0.message)
        }
        .fullScreenCover(isPresented: $data.hasReachSync) {
            ThanksYouView(isPresented: $data.hasReachSync)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            Task {
                await RemoteConfigs.shared.fetchRemoteValues()
            }
        }
    }
    
    private func setupAppearance() {
        
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1).withSymbolicTraits(.traitBold)?.withDesign(UIFontDescriptor.SystemDesign.rounded)
        let descriptor2 = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle).withSymbolicTraits(.traitBold)?.withDesign(UIFontDescriptor.SystemDesign.rounded)
        
        UINavigationBar.appearance().largeTitleTextAttributes = [
            NSAttributedString.Key.font:UIFont.init(descriptor: descriptor2!, size: 34),
            NSAttributedString.Key.foregroundColor: UIColor.label,
        ]
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.font:UIFont.init(descriptor: descriptor!, size: 17),
            NSAttributedString.Key.foregroundColor: UIColor.label
        ]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MainViewModel())
            .environmentObject(ForceUpdateManager())
    }
}
