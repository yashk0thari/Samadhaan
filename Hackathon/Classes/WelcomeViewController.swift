//
//  WelcomeViewController.swift
//  Hackathon
//
//  Created by Aashrit Garg on 12/20/18.
//  Copyright © 2018 Samyak Jain. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuth
import SVProgressHUD
import CryptoKit
import AuthenticationServices

class WelcomeViewController: UIViewController, GIDSignInDelegate, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    @IBOutlet weak var googleLoginView: GIDSignInButton!
    
    override func viewDidLoad() {
            super.viewDidLoad()

        // Apple sign-in view
        setupView()
        
            SVProgressHUD.dismiss()
            
            //Set self as delegate and initiate views
            GIDSignIn.sharedInstance().presentingViewController = self
            googleLoginView.frame = CGRect(x: 13, y: view.frame.height - 60, width: view.frame.width - 26, height: 50)
            
            if Auth.auth().currentUser != nil {
                
                // User is signed in.
                self.performSegue(withIdentifier: "goToHomePage", sender: self)
            }
            
        }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    // Apple Sign-In Shit
    func setupView() {
        let appleButton = ASAuthorizationAppleIDButton()
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        appleButton.addTarget(self, action: #selector(didTapAppleButton), for: .touchUpInside)
        
        view.addSubview(appleButton)
        NSLayoutConstraint.activate([
            
            appleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appleButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -0.15*view.frame.height),
            appleButton.widthAnchor.constraint(equalToConstant: view.frame.width-40),
            appleButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }

    // Unhashed nonce.
    fileprivate var currentNonce: String?
    @objc func didTapAppleButton() {
      let nonce = randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
        
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
      if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
        guard let nonce = currentNonce else {
          fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
          print("Unable to fetch identity token")
          return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
          print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
          return
        }
        // Initialize a Firebase credential.
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
        // Sign in with Firebase.
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if (error != nil) {
            // Error. If error.code == .MissingOrInvalidNonce, make sure
            // you're sending the SHA256-hashed nonce as a hex string with
            // your request to Apple.
                print(error?.localizedDescription)
            return
          }
          // User is signed in to Firebase with Apple.
          self.performSegue(withIdentifier: "goToHomePage", sender: self)
        }
      }
    }

    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
      // Handle error.
      print("Sign in with Apple errored: \(error)")
    }
    
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        return view.window!
    }
    
}
