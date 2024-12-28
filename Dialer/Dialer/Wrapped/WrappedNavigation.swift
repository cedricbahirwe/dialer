//
//  WrappedNavigation.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/12/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct WrappedNavigation: View {
    @EnvironmentObject private var userStore: UserStore
    @EnvironmentObject private var insightsStore: DialerInsightStore
    @Environment(\.dismiss) private var dismiss
    @State private var navPath: [WrappedRoute] = [.one(username: "cedric", transactionsCount: 10)]

    var body: some View {
        NavigationStack(path: $navPath) {
            ZStack {
                Color.black.ignoresSafeArea()
                Image(.dialitApplogo)
            }
            .navigationDestination(for: WrappedRoute.self) { route in
                switch route {
                case .one(let username, let transactionsCount):
                    WrappedViewOne(
                        username: username,
                        numberOfTransactions: transactionsCount
                    )
                    .hideNavigationBar()
                    .task { scheduleGotoNextPage() }
                case .two(let totalAmountSpent):
                    WrappedViewTwo(totalAmountSpent: totalAmountSpent)
                        .hideNavigationBar()
                        .task { scheduleGotoNextPage() }
                case .three:
                    WrappedViewThree()
                        .hideNavigationBar()
                        .task { scheduleGotoNextPage() }
                case .four:
                    WrappedViewFour()
                        .hideNavigationBar()
                        .task { scheduleGotoNextPage() }
                case .five:
                    WrappedViewFive()
                        .hideNavigationBar()
                        .task { scheduleGotoNextPage() }
                case .six:
                    WrappedViewSix()
                        .hideNavigationBar()
                        .task { scheduleGotoNextPage() }

                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .topLeading) {
            HStack {
                Image(.dialitApplogo)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(.rect(cornerRadius: 8))

                Spacer()

                Button.init {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.white)
                        .bold()
                        .background(.quaternary, in: .circle)
                }
            }
            .padding()
        }
    }

    private func scheduleGotoNextPage() {
        guard let nextRoute = getNextRoute() else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            navPath.append(nextRoute)
        }
    }

    private func getNextRoute() -> WrappedRoute? {

        guard let lastRoute = navPath.last, lastRoute != .six else {
            dismiss()
            return nil
        }

        switch lastRoute {
        case .one: return .two(totalAmountSpent: insightsStore.generalTotal)
            case .two: return .three
            case .three: return .four
            case .four: return .five
            case .five: return .six
            case .six: return nil
            }
    }
}

#Preview {
    WrappedNavigation()
        .environmentObject(UserStore())
        .environmentObject(DialerInsightStore())
}

extension View {
    @ViewBuilder
    func hideNavigationBar() -> some View {
        if #available(iOS 18.0, *) {
            self.toolbarVisibility(.hidden, for: .navigationBar)
        } else {
            self.toolbar(.hidden, for: .navigationBar)
        }
    }
}