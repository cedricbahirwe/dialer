//
//  MerchantsListView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/02/2023.
//

import SwiftUI

struct MerchantsListView: View {
    @StateObject private var merchantStore = MerchantStore()
    @State private var showCreateView = false
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            List {
                ForEach(merchantStore.merchants) { merchant in
                    MerchantRow(merchant)
                }
            }
            .overlay {
                if merchantStore.isFetching {
                    Color.black.opacity(0.8).ignoresSafeArea()
                    ProgressView()
                        .tint(.green)
                        .scaleEffect(2)
                }
            }
            .sheet(isPresented: $showCreateView) {
                CreateMerchantView()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {

                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreateView.toggle()
                    } label: {
                        Image( systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                }
            }
            .onAppear(perform: merchantStore.getAllMerchants)
        }
    }
}

private extension MerchantsListView {
    struct MerchantRow: View {
        private let merchant: Merchant
        init(_ merchant: Merchant) {
            self.merchant = merchant
        }
        var body: some View {
            VStack(alignment: .leading) {
                Text(merchant.name)
                    .font(.title3.weight(.semibold))
                Text("Address: \(merchant.address)")
                    .font(.callout)
                Text("Merchant Code: **\(merchant.code)**")
                HStack {
                    Text("Lat: \(merchant.location.latitude), Long: \(merchant.location.longitude)")
                }
            }
        }
    }
}

struct MerchantsListView_Previews: PreviewProvider {
    static var previews: some View {
        MerchantsListView()
    }
}
