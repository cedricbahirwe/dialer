//
//  CreateMerchantView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 26/02/2023.
//

import SwiftUI

struct CreateMerchantView: View {
    @EnvironmentObject private var merchantStore: MerchantStore
    
    @Environment(\.dismiss) private var dismiss
    @State private var model = Model()

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
                .autocorrectionDisabled(true)
                .padding(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(Color.black, lineWidth: 1)
                }

                Button(action: saveMerchant) {
                    Text("Save Merchant")
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 45)

                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle)
                .tint(.main)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .font(.title2)
        .padding(20)
        .background(
            Color(.secondarySystemBackground)
                .ignoresSafeArea()
                .onTapGesture(perform: hideKeyboard)
        )
        .overlay {
            if merchantStore.isFetching {
                Color.black.opacity(0.8).ignoresSafeArea()
                ProgressView()
                    .tint(.green)
                    .scaleEffect(2)
            }
        }
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
            let validationError = error as? Model.Error
            print("Error: \(validationError?.message ?? "")")
        }
    }
}

private extension CreateMerchantView {
    struct Model {
        var name = ""
        var code = ""
        var address = ""

        enum Error: Swift.Error {
            case invalidInput(String)
            var message: String {
                switch self {
                case .invalidInput(let msg): return msg
                }
            }
        }

        func getMerchant() throws -> Merchant {
            guard name.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
            else { throw Error.invalidInput("Name should be more or equal to 3 characters") }
            guard (5...6).contains(code.count)
            else { throw Error.invalidInput("Code should be 5 or 6 digits")  }
            guard code.allSatisfy(\.isNumber)
            else { throw Error.invalidInput("Code contains only digits")  }

            let userId = DialerStorage.shared.getSavedDevice()?.deviceHash ?? "-"
            return Merchant(name: name, address: address, code: code, ownerId: userId)
        }
    }
}

#if DEBUG
struct CreateMerchantView_Previews: PreviewProvider {
    static var previews: some View {
        CreateMerchantView()
            .environmentObject(MerchantStore())
    }
}
#endif
