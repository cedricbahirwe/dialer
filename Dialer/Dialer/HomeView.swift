//
//  HomeView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/02/2021.
//

import SwiftUI
import Combine

enum DialerOption {
    case internet
    case call
    case airtimeBalance
    case momo(option: MomoOption)
    
    var value: String {
        switch self {
        case .internet: return "*345*"
        case .airtimeBalance: return "*131#"
        case .call: return "*140*"
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

struct HomeView: View {
    
    @State private var bottomTextFieldPadding: CGFloat = .zero
    @EnvironmentObject var mainVM: MainViewModel
    
    var body: some View {
        NavigationView {
            VStack (spacing: 0){
                HStack {
                    Text("Dialers📞📱☎️")
                        .font(.system(size: 35, weight: .bold))
                    Spacer()
                }
                .padding()
                ZStack(alignment: .bottom) {
                    ScrollView {
                        VStack(alignment: .leading) {
                            DialerRow(title: "Buy Internet Bundle ⏰")
                            DialerRow(title: "Buy Call Packs 📞")
                            DialerRow(title: "Buy with Mobile Money 💰")
                            DialerRow(title: "Settings ⚙️")
                            DialerRow(title: "Check Airtime Balance ⚖️", perfom: mainVM.dial)
                            DialerRow(title: "Check Mobile Money Balance ⚖️💲")
                        }
                    }
                    .resignKeyboardOnDragGesture()
                    .onReceive(Publishers.keyboardHeight, perform: { value in
                        withAnimation(Animation.easeIn(duration: 0.16)) {
                            self.bottomTextFieldPadding = abs(value)
                        }
                    })
                    
                    VStack(spacing: 0){
                        if mainVM.error.state {
                            Text(mainVM.error.message)
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
                }
            }
            .background(
                Color(.secondarySystemBackground).edgesIgnoringSafeArea(.all)
            )
            .navigationBarTitle("") //"Dialers📞📱☎️
            .navigationBarHidden(true)
        }
    }
}
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(MainViewModel())
    }
}


struct PassCodeField: UIViewRepresentable {
    func makeUIView(context: Context) ->  UITextField {
        let field = UITextField()
        field.textContentType = .password
//        field.keyboardType
        
        return field
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        
    }
}

struct ConfirmationCodeViewController: UIViewRepresentable {
    
    
//    @Binding var passCode: String
    @State var txtFirst: UITextField = UITextField()
    @State var txtSecond: UITextField = UITextField()
    @State var txtThird: UITextField = UITextField()
    @State var txtFourth: UITextField = UITextField()
    @State var txtFifth: UITextField = UITextField()
    
    var action: ((String) -> ())?
    
    let size  = UIScreen.main.bounds.size
    let fieldHeight: CGFloat = 80
    
    func beautify(field: inout UITextField)  {
        field.placeholder = ""
        field.clearButtonMode = .whileEditing
        field.isSecureTextEntry = true
        field.textColor = UIColor.white
        field.font = UIFont.systemFont(ofSize: 35, weight: .black)
        field.textAlignment = .center
        field.autocorrectionType = .no
        field.clearButtonMode = .never
        field.autocapitalizationType = .none
        field.textContentType = .password
        field.keyboardType = .numberPad
        field.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        field.widthAnchor.constraint(equalToConstant: 60.0).isActive = true
        
        field.layer.borderColor = UIColor.white.cgColor
        field.layer.borderWidth = 2
        field.layer.cornerRadius = 8
        
        
            
    }
    
    func makeUIView(context: Context) -> UIStackView {
        
        
        txtFirst.delegate = context.coordinator
        txtSecond.delegate = context.coordinator
        txtThird.delegate = context.coordinator
        txtFourth.delegate = context.coordinator
        txtFifth.delegate = context.coordinator
        
        
        
        
        
        beautify(field: &txtFirst)
        beautify(field: &txtSecond)
        beautify(field: &txtThird)
        beautify(field: &txtFourth)
        beautify(field: &txtFifth)
        
    
        //Stack View
        let stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.horizontal
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = 16.0

        stackView.addArrangedSubview(txtFirst)
        stackView.addArrangedSubview(txtSecond)
        stackView.addArrangedSubview(txtThird)
        stackView.addArrangedSubview(txtFourth)
        stackView.addArrangedSubview(txtFifth)
        stackView.backgroundColor = UIColor.green
        stackView.translatesAutoresizingMaskIntoConstraints = false

        
        
        return stackView
//        self.view.addSubview(stackView)
//
//        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
//        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

    }
    
    func updateUIView(_ uiViewController: UIStackView, context: Context) {
        
    }

    func makeCoordinator() -> ConfirmationCodeViewController.Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: ConfirmationCodeViewController
        
        init(parent: ConfirmationCodeViewController) {
            self.parent = parent
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if !(string == "") {
                textField.text = string
                if textField == parent.txtFirst {
                    parent.txtSecond.becomeFirstResponder()
                }
                else if textField == parent.txtSecond {
                    parent.txtThird.becomeFirstResponder()
                }
                else if textField == parent.txtThird {
                    parent.txtFourth.becomeFirstResponder()
                } else if textField == parent.txtFourth {
                    parent.txtFifth.becomeFirstResponder()
                }
                else {
                    textField.resignFirstResponder()
                    let passCode =
                        (parent.txtFirst.text ?? "") +
                        (parent.txtSecond.text ?? "") +
                        (parent.txtThird.text ?? "") +
                        (parent.txtFourth.text ?? "") +
                        (parent.txtFifth.text ?? "")
                    
                    pa
                    print(textField.text)
                }
                return false
            }
            return true
        }

        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            if (textField.text?.count ?? 0) > 0 {

            }
            return true
        }
    }
        
//        func textFieldDidChangeSelection(_ textField: UITextField) {
//            parent.text = textField.text ?? ""
//        }
//        func textFieldDidBeginEditing(_ textField: UITextField) {
//            parent.isEditingPassword = true
//        }
//        func textFieldDidEndEditing(_ textField: UITextField) {
//            parent.text = textField.text ?? ""
//            if textField.text?.isEmpty ?? false {
//                UIView.animate(withDuration: 0.2) {
//                    self.parent.isEditingPassword = false
//                }
//            }
//        }
//
//        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//            textField.resignFirstResponder()
//            return true
//        }
//
//        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//            if string == " " {
//                return false
//            } else {
//                return true
//            }
//        }
}
