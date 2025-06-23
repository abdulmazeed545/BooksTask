//
//  ViewController.swift
//  MyBooks
//
//  Created by SK ABDUL MAZEED on 22/06/25.
//

import UIKit
import GoogleSignIn
import FirebaseCore
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var btnGoogleSignin: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if Auth.auth().currentUser != nil {
            showHomeScreen()
        }else{
            
        }
    }


    @IBAction func btnSigninGoogle(_ sender: UIButton){
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
          guard error == nil else {
            // ...
              return
          }

          guard let user = result?.user,
            let idToken = user.idToken?.tokenString
          else {
            // ...
              return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)

          // ...
        Auth.auth().signIn(with: credential) { result, error in
            
            if error == nil {
                if let email = result?.user.email, let name = result?.user.displayName, let url = result?.user.photoURL{
                    var userDetails = UserDetails()
                    userDetails.email = email
                    userDetails.name = name
                    userDetails.profileUrl = url.absoluteString
                    UserInfoModel.saveUserRecord(userObj: userDetails)
                }
                // Switch to home screen
                self.showHomeScreen()
            }
            
            }
        }
        
    }
    
    func showHomeScreen() {
        DispatchQueue.main.async{
            guard let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
                print("Failed to instantiate HomeViewController")
                return
            }

            // Create a navigation controller with homeVC as its root
            let navigationController = UINavigationController(rootViewController: homeVC)

            // Optional: Configure navigation bar appearance
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            navigationController.navigationBar.standardAppearance = appearance
            navigationController.navigationBar.scrollEdgeAppearance = appearance

            if let delegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                // Set the navigation controller as root
                delegate.window?.rootViewController = navigationController
                delegate.window?.makeKeyAndVisible()
                
                // Optional transition animation
                UIView.transition(with: delegate.window!,
                                 duration: 0.3,
                                 options: .transitionCrossDissolve,
                                 animations: {},
                                 completion: nil)
            }
        }
    }
}

