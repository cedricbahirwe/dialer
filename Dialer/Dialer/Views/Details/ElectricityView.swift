//
//  ElectricityView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 12/12/2021.
//

import SwiftUI

struct ElectricityView: View {
    @EnvironmentObject private var store: MainViewModel
    @State private var meterNumber: String = ""
    @State private var amount: String = ""
    
    private var isValidMeter: Bool { meterNumber.count >= 11  }
    private var isValidAmount: Bool { (Int(amount) != nil) }
    private var isValidTransaction: Bool {
        isValidMeter && isValidAmount
    }
    
    private var amountHintView: Text {
        if let amount = Int(amount) {
            return Text(amount >= 600 ? "" : "The amount must be greater or equal to 600 RWF")
        } else {
            return Text("You have entered an invalid amount.")
        }
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                VStack(spacing: 5) {
                    if !amount.isEmpty {
                        amountHintView
                            .font(.caption).foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .animation(.default, value: amount)
                    }
                    
                    NumberField("Enter Amount", text: $amount.animation())
                }
                
                VStack(spacing: 5) {
                    HStack {
                        NumberField("Enter Meter Number", text: $meterNumber)
                        Button(action: {
                            store.saveMeterNumber("")
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
                    store.getElectricity(for: meterNumber, amount: Int(amount)!)
                }) {
                    Text("Buy electricity")
                        .font(.footnote.bold())
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(Color.blue.opacity(isValidMeter ? 1 : 0.6))
                        .cornerRadius(8)
                        .foregroundColor(Color.white)
                }
                .disabled(isValidTransaction == false)
                
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
