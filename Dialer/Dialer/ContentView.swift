//
//  ContentView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 08/02/2021.
//

import SwiftUI
import Combine
import Foundation

enum DialerOption {
    case airtime
    case momo(option: MomoOption)
    
    var value: String {
        switch self {
        case .airtime: return ""
        case .momo(option: let option):
            switch option {
            case .airtime:
                return ""
            case .payment:
                return "*182*"
            }
        }
    } 
    
}

enum MomoOption: String {
    case payment
    case airtime
}

struct Dial: Identifiable {
    var id = UUID()
    var title: String
    var subAction: [SubDial]?
}
struct SubDial: Identifiable {
    var id = UUID()
    var title: String
}

struct ContentView: View {
    
    @State private var bottomTextFieldPadding: CGFloat = .zero
    
    @EnvironmentObject var mainVM: MainViewModel
    
    var dialers: [Dial] = [
        Dial(title: "Buy Airtime ⏰"),
        Dial(title: "Buy Call Packs 📞"),
        Dial(title: "Buy Money Mobile 💰"),
        Dial(title: "Settings ⚙️"),
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dialers) { dialer in
                    Text(dialer.title)
                        .fontWeight(.semibold)
                }
            }
            .listStyle(PlainListStyle())
            .resignKeyboardOnDragGesture()
            .onReceive(Publishers.keyboardHeight, perform: { value in
                withAnimation(Animation.easeIn(duration: 0.16)) {
                    self.bottomTextFieldPadding = abs(value)
                }
            })
            .navigationBarTitle("Dialers📞📱☎️")
            .overlay(
                VStack(spacing: 0){
                    if mainVM.error.state {
                        Text("An error Occured")
                            .foregroundColor(.red)
                    }
                    HStack {
                        TextField("Enter Your Code", text: $mainVM.selectedCode)
                            .foregroundColor(Color.white)
                            .padding(.leading)
                            .frame(height: 36)
                            .background(Color.white.opacity(0.2).cornerRadius(5))
                            .keyboardType(.phonePad)
                        
                        Button(action: mainVM.dial) {
                            Text("Dial")
                                .foregroundColor(.white)
                                .frame(width:80, height: 36)
                                .background(Color.green)
                                .cornerRadius(5)
                        }
                    }
                    
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.black.opacity(0.9))
                .padding(.bottom, bottomTextFieldPadding)
                
                
                , alignment: .bottom
            )
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MainViewModel())
    }
}


class MainViewModel: ObservableObject {
    @Published var selectedCode: String = ""
    
    @Published var error: (state: Bool, message: String) = (false, "")
    let elements = "0123456789*#"
    
    func dial() {

        
        if elements.contains(selectedCode) {
            
        }
        withAnimation {
            self.error.state.toggle()
        }
        //        UIApplication.shared.endEditing(true)
        
        if !selectedCode.isEmpty {
            dialCode(url: selectedCode)
        } else {
            self.error = (true, "")
        }
    }
    
    
    func dialCode(url: String) {
        if let url = URL(string: "tel://\(url)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Can not dial this code
            self.error = (true, "Can not dial this code")
//            let alert = UIAlertController(title: "", message: "Can not call this number", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func checkError() throws {
    
    }
}

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}
extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

