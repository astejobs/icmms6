//
//  ResetPasswordView.swift
//  ICMMS
//
//  Created by Tahreem on 07/07/21.
//

import SwiftUI

struct ResetPasswordView: View {
    @State private var emailAddress: String = ""
    @State private var errorString: String = ""
    @Binding var showForgetAlert: Bool
    @State private var successBool : Bool = false
    @State private var failedAlert: Bool = false
    @State private var afterLoad: Bool = false

    @State private var isLoading: Bool = false
    var body: some View {
        NavigationView{
           
        VStack{
           
            TextField("Please enter registered e-mail", text: $emailAddress)
                .padding(20)
                .cornerRadius(8)
                .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1)
                    )
                
            if isLoading{
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
            else{
                Button {
                    afterLoad = false
                    successBool = false
                    failedAlert = false
                    if !emailAddress.isEmpty && emailAddress.isValidEmail {
                        resetPassword(emailAddress: emailAddress)
                    }else{

                        print("wrong email: \(emailAddress)")
                    }
                } label: {
                    Text("Send Email to reset Password")
                       
                }
                .padding()
            }
        }
        .background(Color.white)
        .cornerRadius(10)
        .padding()
        .shadow(radius: 10)
            
        .alert(isPresented: $afterLoad) {

            if self.successBool {
                return  Alert(title: Text("Alert"), message: Text("Please check mail"), primaryButton: .destructive(Text("ok")) {
                    showForgetAlert = false
                },secondaryButton: .cancel())
            }else{
                return  Alert(title: Text("Alert"), message: Text("There was an error :\(errorString)"), dismissButton: .default(Text("OK")))
            }
        }
       
        .navigationBarTitle(Text("Reset Password"))
        }
       
    }
    func resetPassword(emailAddress: String)  {
        
        isLoading = true
        guard let url = URL(string: "\(CommonStrings().apiURL)reset") else {return}
        
        var urlRequest = URLRequest(url: url)
        //urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(emailAddress, forHTTPHeaderField: "email")
        print(urlRequest)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
          
//            if let error = error {
//                print("Request error: ", error)
//                failedAlert = true
//                return
//            }
//
//            guard let response = response as? HTTPURLResponse else {
//                print("response error: \(String(describing: error))")
////                failedAlert = true
//                return
//            }
//
            guard let response = response as? HTTPURLResponse else{return}
            
            if response.statusCode == 200 {
                guard let _ = data else {return }
                afterLoad = true
                successBool = true
                print("success")
            }
            else{
                errorString=String(response.statusCode)
                print("Failed")
                afterLoad = true
                failedAlert = true
            }
        }
        isLoading = false
        dataTask.resume()
    }
    
    
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ResetPasswordView(showForgetAlert: .constant(true))
            ResetPasswordView(showForgetAlert: .constant(true))
        }
    }
}

extension String {
    
    var isValidEmail: Bool {
        let name = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
        let domain = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
        let emailRegEx = name + "@" + domain + "[A-Za-z]{2,8}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: self)
    }
    
}
