//
//  CreateMerchantView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 26/02/2023.
//

import SwiftUI

struct CreateMerchantView: View {
    @ObservedObject var merchantStore: MerchantStore
    @State private var model: MerchantCreationModel
    @State private var alertItem: (status: Bool, message: String) = (false, "")

    @Environment(\.dismiss) private var dismiss

    init(merchantStore: MerchantStore) {
        self.merchantStore = merchantStore
        self._model = State(initialValue: merchantStore.getPotentialMerchantCode() ?? .init())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("Create Merchant")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.vertical)
            
            VStack(alignment: .leading, spacing: 15) {
                Group {
                    TextField("Merchant Name", text: $model.name)
                    
                    
                    TextField("Merchant Code", text: $model.code)
                        .keyboardType(.numberPad)
                    
                    TextField("Merchant Address", text: $model.address)
                }
                .autocorrectionDisabled()
                .keyboardType(.alphabet)
                .font(.callout)
                .padding()
                .frame(height: 48)
                .background(Color.primaryBackground)
                .withNeumorphStyle()
                
                Button(action: saveMerchant) {
                    Text("Save Merchant")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.accentColor)
                        .cornerRadius(16)
                        .foregroundStyle(Color.white)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .font(.title2)
        .padding(20)
        .background(Color.primaryBackground.ignoresSafeArea().onTapGesture(perform: hideKeyboard))
        .overlay {
            if merchantStore.isFetching {
                Color.black.opacity(0.8).ignoresSafeArea()
                ProgressView()
                    .tint(.green)
                    .scaleEffect(2)
            }
        }
        .alert("Merchant Validation", isPresented: $alertItem.status, actions: {
            Button("Okay", action: {})
        }, message: {
            Text(LocalizedStringKey(alertItem.message))
        })
        .trackAppearance(.newMerchant)
    }
    
    private func saveMerchant()  {
        Task {
            do {
                let merchant = try model.getMerchant()
                try await merchantStore.saveMerchant(merchant)
                dismiss()
            } catch {
                if let validationError = error as? MerchantCreationModel.Error {
                    alertItem = (true, validationError.message)
                }
                Log.debug("Error: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    CreateMerchantView(merchantStore: MerchantStore())
}
