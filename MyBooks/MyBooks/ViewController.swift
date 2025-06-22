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

class ViewController: UIViewController {
    
    @IBOutlet weak var btnGoogleSignin: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func btnSigninGoogle(_ sender: UIButton){
        logout()
        
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

              // At this point, our user is signed in
            print("sign in result is:", result?.user)
            }
        }
        
    }
    
    func logout(){
        
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
}

