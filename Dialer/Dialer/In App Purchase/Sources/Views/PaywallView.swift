//
//  PaywallView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 12/07/2023.
//

import SwiftUI
import RevenueCat

struct PaywallView: View {
    
    /// - This binding is passed from ContentView: `paywallPresented`
    @Binding var isPresented: Bool
    
    /// - This can change during the lifetime of the PaywallView (e.g. if poor network conditions mean that loading offerings is slow)
    /// So set this as an observed object to trigger view updates as necessary
    @ObservedObject var userViewModel = UserViewModel.shared
    
    /// - The current offering saved from PurchasesDelegateHandler
    ///  if this is nil, then you might want to show a loading indicator or similar
    private var offering: Offering? {
        userViewModel.offerings?.current
    }
    
    var body: some View {
        PaywallContent(offering: self.offering, isPresented: self.$isPresented)
    }
    
}

private struct PaywallContent: View {
    
    var offering: Offering?
    var isPresented: Binding<Bool>
    
    /// - State for displaying an overlay view
    @State private var isPurchasing: Bool = false
    @State private var error: NSError?
    @State private var displayError: Bool = false
    @State private var isAnimating = false

    private let linearGradient = LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .topLeading, endPoint: .trailing)
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .leading) {
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Dialer +")
                            .font(.system(size: 050, design: .rounded))
                            .fontWeight(.bold)
                        
                        Text("Get access to unlimited transfers, payments, reporting and more!")
                            .font(.headline)
                    }
                    .padding()

                    
                    /// - The paywall view list displaying each package
                    List {

                        Section(header: Text(""), footer: Text(Self.footerText)) {
                            ForEach(offering?.availablePackages ?? []) { package in
                                PackageCellView(package: package) { (package) in
                                    Task {
                                        await purchasePackage(package)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .safeAreaInset(edge: .bottom) {
                        if let package = offering?.availablePackages.last {
                            VStack(spacing: 25) {
                                Button {
                                    Task {
                                        await purchasePackage(package)
                                    }
                                } label: {
                                    Text("Get Lifetime Access for \(package.localizedPriceString)")
                                        .font(.system(.title3, design: .rounded))
                                        .bold()
                                        .foregroundColor(.white)
                                        .frame(height: 60)
                                        .frame(maxWidth: .infinity)
                                        .background(linearGradient)
                                        .cornerRadius(15)
                                        .shadow(color: .purple, radius: isAnimating ? 5 : 0)
                                        .scaleEffect(isAnimating ? 0.97 : 1.0)
                                        .onAppear {
                                            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                                self.isAnimating = true
                                            }
                                        }
                                }
                                
                                Button {
                                    Task {
                                        do {
                                           _ = try await Purchases.shared.restorePurchases()
                                        } catch {
                                            
                                        }
                                    }
                                } label: {
                                    Text("Restore purchase")
                                        .font(.system(.title3, design: .rounded))
                                        .bold()
                                        .foregroundColor(.white)
                                        .frame(height: 60)
                                        .frame(maxWidth: .infinity)
                                        .background(linearGradient.opacity(0.1))
                                        .cornerRadius(15)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .topLeading, endPoint: .trailing), lineWidth: 2)
                                        }
                                }
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                        }
                    }
                }
                
                
                /// - Display an overlay during a purchase
                Rectangle()
                    .foregroundColor(Color.black)
                    .opacity(isPurchasing ? 0.5: 0.0)
                    .edgesIgnoringSafeArea(.all)
                    .overlay {
                        if isPurchasing {
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                    }
            }
            .navigationBarTitleDisplayMode(.inline)

        }
        .navigationViewStyle(StackNavigationViewStyle())
        .colorScheme(.dark)
        .alert(
            isPresented: self.$displayError,
            error: self.error,
            actions: { _ in
                Button(role: .cancel,
                       action: { self.displayError = false },
                       label: { Text("OK") })
            },
            message: { Text($0.recoverySuggestion ?? "Please try again") }
        )
    }
    
    private static let footerText: LocalizedStringKey = "The purchase will be billed to your Apple ID account. By activating the subscription, you agree to Dialer's Privacy Policy. For more information, see our [Terms of Service](https://cedricbahirwe.github.io/html/dialit/tos.html) and [Privacy Policy](https://cedricbahirwe.github.io/html/privacy.html)."
    
    private func purchasePackage(_ package: Package) async {
        
        /// - Set 'isPurchasing' state to `true`
        isPurchasing = true
        
        /// - Purchase a package
        do {
            let result = try await Purchases.shared.purchase(package: package)
            
            /// - Set 'isPurchasing' state to `false`
            self.isPurchasing = false
            
            if !result.userCancelled {
                self.isPresented.wrappedValue = false
            }
        } catch {
            self.isPurchasing = false
            self.error = error as NSError
            self.displayError = true
        }
    }
    
}

/* The cell view for each package */
private struct PackageCellView: View {
    
    let package: Package
    let onSelection: (Package) async -> Void
    
    var body: some View {
        Button {
            Task {
                await self.onSelection(self.package)
            }
        } label: {
            self.buttonLabel
        }
        .buttonStyle(.plain)
    }
    
    private var buttonLabel: some View {
        HStack {
            VStack {
                HStack {
                    Text(package.storeProduct.localizedTitle)
                        .font(.title3)
                        .bold()
                    
                    Spacer()
                }
                HStack {
                    Text(package.terms)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding([.top, .bottom], 8.0)
            
            Spacer()
            
            Text(package.localizedPriceString)
                .font(.title3)
                .bold()
        }
        .contentShape(Rectangle()) // Make the whole cell tappable
    }
    
}

extension NSError: LocalizedError {
    
    public var errorDescription: String? {
        return self.localizedDescription
    }
    
}

struct PaywallView_Previews: PreviewProvider {
    
    private static let product1 = TestStoreProduct(
        localizedTitle: "PRO monthly",
        price: 3.99,
        localizedPriceString: "$3.99",
        productIdentifier: "com.revenuecat.product",
        productType: .autoRenewableSubscription,
        localizedDescription: "Description",
        subscriptionGroupIdentifier: "group",
        subscriptionPeriod: .init(value: 1, unit: .month),
        introductoryDiscount: .init(
            identifier: "intro",
            price: 0,
            localizedPriceString: "$0.00",
            paymentMode: .freeTrial,
            subscriptionPeriod: .init(value: 1, unit: .week),
            numberOfPeriods: 1,
            type: .introductory
        ),
        discounts: []
    )
    private static let product2 = TestStoreProduct(
        localizedTitle: "Dialer Plus (Lifetime",
        price: 19.99,
        localizedPriceString: "$19.99",
        productIdentifier: "com.revenuecat.product",
        productType: .nonConsumable,
        localizedDescription: "Get Lifetime access for $19.99",
        subscriptionGroupIdentifier: "group",
        subscriptionPeriod: .init(value: 1, unit: .year),
        introductoryDiscount: nil,
        discounts: []
    )
    
    private static let offering = Offering(
        identifier: Self.offeringIdentifier,
        serverDescription: "Main offering",
        metadata: [:],
        availablePackages: [
            //            .init(
            //                identifier: "monthly",
            //                packageType: .monthly,
            //                storeProduct: product1.toStoreProduct(),
            //                offeringIdentifier: Self.offeringIdentifier
            //            ),
            .init(
                identifier: "annual",
                packageType: .annual,
                storeProduct: product2.toStoreProduct(),
                offeringIdentifier: Self.offeringIdentifier
            )
        ]
    )
    
    private static let offeringIdentifier = "offering"
    
    static var previews: some View {
        PaywallContent(offering: Self.offering, isPresented: .constant(true))
    }
    
}
