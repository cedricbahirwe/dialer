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
        ZStack {
            VStack {
                
                VStack(spacing: 25) {
                    Image("dialer.icon")
                        .resizable()
                        .scaledToFit()
                        .padding(6)
                        .frame(width: 140, height: 140)
                        .background(.ultraThickMaterial)
                        .cornerRadius(40, antialiased: false)
                        .shadow(color: .gray, radius: 2)
                        .foregroundColor(.mainRed)
                        .frame(maxWidth: .infinity)
                    
                    Text("Upgrade to Dialer Pro for unlimited transfers, payments and insights!")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .layoutPriority(2)
                }
                .padding([.horizontal, .bottom], 25)
                
                
                if let package = offering?.availablePackages.last {
                    VStack {
                        VStack(spacing: 20) {
                            Text("Dialer Pro")
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.bold)
                                .font(.headline)
                            
                            Text(package.localizedPriceString)
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.bold) +  Text(" forever").font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 30)
                        
                        
                        VStack(alignment: .leading, spacing: 15) {
                            OfferringLabel("Unlimited USSDs usage")
                            
                            OfferringLabel("USSDs saved by you")
                            
                            OfferringLabel("Customized Insights andd tips")
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        Button {
                            Task {
                                await purchasePackage(package)
                            }
                        } label: {
                            Text("Buy Lifetime Access Now")
                                .font(.system(.title3, design: .rounded))
                                .bold()
                                .foregroundColor(.white)
                                .frame(height: 60)
                                .frame(maxWidth: .infinity)
                                .background(linearGradient)
                                .cornerRadius(15)
                                .shadow(color: .purple, radius: isAnimating ? 3 : 0)
                                .scaleEffect(isAnimating ? 0.97 : 1.0)
                                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
                                .onAppear {
                                    self.isAnimating = true
                                }
                        }
                        .padding(.vertical)
                    }
                    .padding(20)
                    .background(.ultraThickMaterial)
                    .cornerRadius(30)
                    .overlay {
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(.ultraThinMaterial, lineWidth: 3)
                    }
                    
                    HStack {
                        
                        Link("Terms of Use",
                             destination: URL(string: "https://cedricbahirwe.github.io/html/dialit/tos.html")!)
                        
                        Spacer()
                        
                        Button("Restore purchase") {
                            Task {
                                await restorePurchase()
                            }
                        }
                        
                        Spacer()
                        
                        Link("Privacy Policy",
                             destination: URL(string: "https://cedricbahirwe.github.io/html/privacy.html")!)
                        
                    }
                    .font(.callout)
                    .tint(.primary.opacity(0.7))
                    .padding(.vertical, 25)
                }
            }
            .padding(.horizontal)
            .frame(maxHeight: .infinity)
            .background(.background)
            .overlay(alignment: .topLeading) {
                Button {
                    isPresented.wrappedValue = false
                } label: {
                    
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .symbolRenderingMode(.hierarchical)
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }
                .tint(.primary.opacity(0.8))
                .padding()
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
        .preferredColorScheme(.dark)
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
    
    private func restorePurchase() async {
        isPurchasing = true
        
        do {
            let result = try await Purchases.shared.restorePurchases()
            
            self.isPurchasing = false
            
            if result.originalPurchaseDate != nil {
                self.isPresented.wrappedValue = false
            }
            
        } catch {
            self.isPurchasing = false
            self.error = error as NSError
            self.displayError = true
        }
    }
    
}

private struct OfferringLabel: View {
    let title: LocalizedStringKey
    init(_ title: LocalizedStringKey) {
        self.title = title
    }
    
    var body: some View {
        Label(title: {
            Text(title)
        }, icon: {
            Image(systemName: "checkmark.circle.fill")
                .renderingMode(.template)
                .imageScale(.large)
                .foregroundColor(.mainRed)
        } )
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
        localizedTitle: "Dialer Pro (Lifetime",
        price: 4.99,
        localizedPriceString: "$4.99",
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
            .previewLayout(.fixed(width: 416, height: 750))
    }
    
}
