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
    @State private var navPath: [WrappedRoute] = []

    var body: some View {
        NavigationStack(path: $navPath) {
            ZStack {
                Color.black.ignoresSafeArea()
                Image(.dialitApplogo)
            }
            .task {
                navPath.append(
                    .one(
                        username: userStore.localUser?.username ?? "Dialer ",
                        transactionsCount: insightsStore.transactionInsights.count
                    )
                )
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
                case .three(let categoryName, let amountSpent, let percentage, let iconName, let color):
                    WrappedViewThree(
                        categoryName: categoryName,
                        amountSpent: amountSpent,
                        percentage: percentage,
                        imageName: iconName,
                        color: color
                    )
                    .hideNavigationBar()
                    .task { scheduleGotoNextPage() }
                case .four(let activeMonth, let count):
                    WrappedViewFour(activeMonth: activeMonth, count: count)
                        .hideNavigationBar()
                        .task { scheduleGotoNextPage() }
                case .five(let spendings):
                    WrappedViewFive(spendings: spendings)
                        .hideNavigationBar()
                        .task { scheduleGotoNextPage() }
                case .six:
                    WrappedViewSix()
                        .hideNavigationBar()
//                        .task { scheduleGotoNextPage() }

                }
            }
        }
        .preferredColorScheme(.light)
        .statusBarHidden()
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .topLeading) {
            HStack {
                Image(.dialitApplogo)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(.rect(cornerRadius: 8))
                    .onTapGesture {
                        navPath.removeLast()
                    }
                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.white)
                        .bold()
                        .background(.tertiary, in: .circle)
                }
            }
            .padding()
        }
    }

    private func scheduleGotoNextPage(delay: TimeInterval = 5.0) {
        guard let nextRoute = getNextRoute() else {
            dismiss()
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            navPath.append(nextRoute)
        }
    }

    private func getNextRoute() -> WrappedRoute? {

        guard let lastRoute = navPath.last else { return nil }

        switch lastRoute {
        case .one: return .two(totalAmountSpent: insightsStore.generalTotal)
        case .two:
            guard let popular = insightsStore.getPopularInsight() else { return nil }
            return .three(
                categoryName: popular.title,
                amountSpent: popular.totalAmount,
                percentage: Double(popular.totalAmount) / Double(insightsStore.generalTotal),
                iconName: popular.iconName,
                color: popular.color
            )
        case .three:
            guard let activeMonth = insightsStore.getMostActiveMonth() else { return nil }
            return .four(activeMonth: activeMonth.month, count: activeMonth.count)
        case .four:
            guard let spendings = insightsStore.makeSpendings() else { return nil }
            return .five(spendings: spendings)
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
