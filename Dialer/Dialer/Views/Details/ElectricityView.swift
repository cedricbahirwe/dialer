//
//  ElectricityView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 12/12/2021.
//

import SwiftUI

struct ElectricityView: View {
    
    @State private var showContactPicker = false
    @State private var allContacts: [Contact] = []
    @State private var meterNumber: String = ""
    
    @EnvironmentObject private var store: MainViewModel
    private var isValidMeter: Bool { meterNumber.count >= 11  }
    
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                
                VStack(spacing: 5) {
                    HStack {
                        NumberField("Enter Meter Number", text: $meterNumber)
                        Button(action: {
                            
                        }){
                            Text("Save")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                                .frame(height: 46)
                                .background(Color.primary)
                                .cornerRadius(8)
                                .foregroundColor(Color(.systemBackground))
                        }
                            .disabled(!isValidMeter)
                            .opacity(isValidMeter ? 1 : 0.4)
                            .animation(.easeInOut, value: isValidMeter)
                    }
                    
                    Text("The meter number should have at least 14 digits.")
                        .font(.caption).foregroundColor(.blue)
                }
                                
                
                Button(action: {
                    hideKeyboard()
                    store.getElectricity(for: meterNumber)
                }) {
                    Text("Buy electricity")
                        .font(.footnote.bold())
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(Color.blue.opacity(isValidMeter ? 1 : 0.6))
                        .cornerRadius(8)
                        .foregroundColor(Color.white)
                }
                .disabled(meterNumber.isEmpty)
                
                Spacer()
            }
            .padding()
            
        }
        .background(Color(.systemBackground)
                        .onTapGesture(perform: hideKeyboard))
        .navigationTitle("Buy Electricity")
    }
}

struct ElectricityView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ElectricityView()
        }
    }
}
