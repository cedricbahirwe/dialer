//
//  CreateMerchantView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 26/02/2023.
//

import SwiftUI

struct CreateMerchantView: View {
    @ObservedObject var merchantStore: MerchantStore
    
    @Environment(\.dismiss) private var dismiss
    @State private var model = MerchantCreationModel()
    
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
                        .cornerRadius(15)
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
        .trackAppearance(.newMerchant)
    }
    
    private func saveMerchant()  {
        do {
            let merchant = try model.getMerchant()
            Task {
                let success = await merchantStore.saveMerchant(merchant)
                guard success else { return }
                dismiss()
            }
        } catch {
            let validationError = error as? MerchantCreationModel.Error
            Log.debug("Error: \(validationError?.message ?? "")")
        }
    }
}

#Preview {
    CreateMerchantView(merchantStore: MerchantStore())
}
