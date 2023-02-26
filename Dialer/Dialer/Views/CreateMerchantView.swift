//
//  CreateMerchantView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 26/02/2023.
//

import SwiftUI

struct CreateMerchantView: View {
    var body: some View {
        VStack {
            TextField("Merchant Name", text: .constant(""))

            TextField("Merchant Code", text: .constant(""))

            TextField("Merchant Address", text: .constant(""))

            TextField("Merchant Location", text: .constant(""))
        }
    }
}

struct CreateMerchantView_Previews: PreviewProvider {
    static var previews: some View {
        CreateMerchantView()
    }
}
