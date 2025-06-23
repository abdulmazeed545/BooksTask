//
//  ImagePickerVC.swift
//  MyBooks
//
//  Created by PeopleLink on 23/06/25.
//

import UIKit
import MobileCoreServices // For kUTTypeImage, etc.

class ImagePickerSwiftController: UIViewController {

    var selectedImageView: UIImageView! // To display the selected image
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    func setupUI() {
        // ImageView to display the selected image
        selectedImageView = UIImageView()
        selectedImageView.contentMode = .scaleAspectFit
        selectedImageView.backgroundColor = .lightGray
        selectedImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectedImageView)
        
        // Buttons
        let cameraButton = UIButton(type: .system)
        cameraButton.setTitle("Open Camera", for: .normal)
        cameraButton.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraButton)
        
        let galleryButton = UIButton(type: .system)
        galleryButton.setTitle("Open Gallery", for: .normal)
        galleryButton.addTarget(self, action: #selector(openPhotoLibrary), for: .touchUpInside)
        galleryButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(galleryButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            selectedImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectedImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            selectedImageView.widthAnchor.constraint(equalToConstant: 250),
            selectedImageView.heightAnchor.constraint(equalToConstant: 250),
            
            cameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraButton.topAnchor.constraint(equalTo: selectedImageView.bottomAnchor, constant: 40),
            
            galleryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            galleryButton.topAnchor.constraint(equalTo: cameraButton.bottomAnchor, constant: 20)
        ])
    }

    // MARK: - Button Actions

    @objc func openCamera() {
        // Check if camera is available on the device
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera is not available on this device.")
            showAlert(title: "Error", message: "Camera is not available.")
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = [kUTTypeImage as String] // Restrict to images only
        picker.allowsEditing = false // Set to true if you want to allow editing (cropping, etc.)
        picker.delegate = self // Set the delegate to receive callbacks

        present(picker, animated: true, completion: nil)
    }

    @objc func openPhotoLibrary() {
        // Check if photo library is available (it almost always is)
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Photo Library is not available on this device.")
            showAlert(title: "Error", message: "Photo Library is not available.")
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeImage as String] // Restrict to images only
        picker.allowsEditing = true // You can allow editing for gallery picks
        picker.delegate = self // Set the delegate to receive callbacks

        present(picker, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension ImagePickerSwiftController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // This method is called when the user selects an image or takes a photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil) // Dismiss the picker

        if let image = info[.editedImage] as? UIImage {
            // If allowsEditing was true, use .editedImage
            selectedImageView.image = image
        } else if let image = info[.originalImage] as? UIImage {
            // Otherwise, use .originalImage
            selectedImageView.image = image
        }
    }

    // This method is called if the user cancels the picking process
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
