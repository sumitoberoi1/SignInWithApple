//
//  SignInWithAppleButton.swift
//  iOS-Demo-SignInWithApple-SwiftUI
//
//  Created by Sumit Oberoi on 05/06/2019.
//  Copyright © 2019 Sumit Oberoi. All rights reserved.
//

import SwiftUI
import AuthenticationServices

extension String: Error { }

enum CredentialsOrError {
  case credentials(user: String, givenName: String?, familyName: String?, email: String?)
  case error(_ error: Error)
}

struct Credentials {
  let user: String
  let givenName: String?
  let familyName: String?
  let email: String?
}

struct SignInWithAppleButton: View {
  
  @Binding var credentials: CredentialsOrError?
  
  var body: some View {
    let button = ButtonController(credentials: $credentials)
    
    return button
      .frame(width: button.button.frame.width, height: button.button.frame.height, alignment: .center)
  }
  
  struct ButtonController: UIViewControllerRepresentable {
    let button: ASAuthorizationAppleIDButton = ASAuthorizationAppleIDButton()
    let vc: UIViewController = UIViewController()
    
    @Binding var credentials: CredentialsOrError?
    
    func makeCoordinator() -> Coordinator {
      return Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
      vc.view.addSubview(button)
      return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
    
    class Coordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
      let parent: ButtonController
      
      init(_ parent: ButtonController) {
        self.parent = parent
        
        super.init()
        
        parent.button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
      }
      
      @objc func didTapButton() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.presentationContextProvider = self
        authorizationController.delegate = self
        authorizationController.performRequests()
      }
      
      func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return parent.vc.view.window!
      }
      
      func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credentials = authorization.credential as? ASAuthorizationAppleIDCredential else {
          parent.credentials = .error("Credentials are not of type ASAuthorizationAppleIDCredential")
          return
        }
        
        parent.credentials = .credentials(user: credentials.user, givenName: credentials.fullName?.givenName, familyName: credentials.fullName?.familyName, email: credentials.email)
      }
      
      func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        parent.credentials = .error(error)
      }
    }
  }

}
