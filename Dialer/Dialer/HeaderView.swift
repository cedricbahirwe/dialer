//
//  HeaderView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/02/2021.
//

import SwiftUI

struct HeaderView: View {
    let title: String
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        HStack{
            Image(systemName: "chevron.left")
                .imageScale(.large)
                .padding()
                .frame(width: 25, height: 25)
                .contentShape(Rectangle())
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                    
                }
            Spacer()
            Text(title)
            Spacer()
        }
        .font(.system(size: 20, weight: .bold, design: .rounded))
        .foregroundColor(Color(.systemBackground))
        .offset(y: 5)
        .padding(.bottom)
        .padding(.horizontal)
        .frame(height: 42)
        .background(Color(.label).edgesIgnoringSafeArea(.top))
    }
}


struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(title: "Title goes here")
    }
}
