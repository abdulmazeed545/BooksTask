//
//  ProfileVC.swift
//  MyBooks
//
//  Created by PeopleLink on 23/06/25.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class ProfileVC: UIViewController {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var btnLogout: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        fetchData()
        // Do any additional setup after loading the view.
    }
    
    func setupUI(){
        imgProfile.layer.cornerRadius = imgProfile.frame.size.width / 2
    }
    
    func fetchData(){
        UserInfoModel.shared.fetchOfflineRecords { userDetails in
            let userData = userDetails.first
            DispatchQueue.main.async { [weak self] in
                self?.lblEmail.text = userData?.email
                self?.lblName.text = userData?.name
                self?.imgProfile.downloadImage(from: userData?.profileUrl ?? "")
            }
        }
    }
    
    private func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        
        // Logout action
        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            self?.logout()
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @IBAction func btnLogoutTapped(_ sender: UIButton){
        showLogoutConfirmation()
    }
    
    //MARK: Logout
    func logout(){
        do {
            // Sign out from Firebase
            try Auth.auth().signOut()
            
            // Sign out from Google
            GIDSignIn.sharedInstance.signOut()
            
            CoreDataManger.shared.clearDB() // Clearing coredb while logging out the user
            movetoLoginScreen()
            
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func movetoLoginScreen() {
        DispatchQueue.main.async{
            guard let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {
                print("Failed to instantiate HomeViewController")
                return
            }

            if let delegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                // Set the navigation controller as root
                delegate.window?.rootViewController = loginVC
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


extension UIImageView {
    private static let imageCache = NSCache<NSString, UIImage>()
    
    /// Downloads image from URL with caching and placeholder support
    /// - Parameters:
    ///   - urlString: The image URL string
    ///   - placeholder: Optional placeholder image
    ///   - completion: Optional completion handler
    func downloadImage(from urlString: String,
                      placeholder: UIImage? = nil,
                      completion: ((UIImage?) -> Void)? = nil) {
        
        // Set placeholder if provided
        if let placeholder = placeholder {
            self.image = placeholder
        }
        
        // Check for empty URL
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion?(nil)
            return
        }
        
        // Check cache first
        let cacheKey = NSString(string: urlString)
        if let cachedImage = UIImageView.imageCache.object(forKey: cacheKey) {
            self.image = cachedImage
            completion?(cachedImage)
            return
        }
        
        // Download image
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Image download error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion?(nil)
                }
                return
            }
            
            guard let data = data,
                  let downloadedImage = UIImage(data: data),
                  let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                print("Invalid image data or response")
                DispatchQueue.main.async {
                    completion?(nil)
                }
                return
            }
            
            // Cache the image
            UIImageView.imageCache.setObject(downloadedImage, forKey: cacheKey)
            
            DispatchQueue.main.async {
                UIView.transition(with: self,
                                duration: 0.3,
                                options: .transitionCrossDissolve,
                                animations: {
                                    self.image = downloadedImage
                                },
                                completion: { _ in
                                    completion?(downloadedImage)
                                })
            }
        }.resume()
    }
    
    /// Cancel current image download (if any)
    func cancelImageDownload() {
        URLSession.shared.getAllTasks { tasks in
            tasks.forEach {
                if $0.state == .running {
                    $0.cancel()
                }
            }
        }
    }
}
