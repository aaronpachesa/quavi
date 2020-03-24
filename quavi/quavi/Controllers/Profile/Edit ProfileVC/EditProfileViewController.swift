//
//  EditProfileViewController.swift
//  quavi
//
//  Created by Radharani Ribas-Valongo on 2/25/20.
//  Copyright © 2020 Sunni Tang. All rights reserved.
//

import UIKit
import Photos
import FirebaseAuth
import FirebaseFirestore

class EditProfileViewController: UIViewController {
    
    //MARK: - Lazy Properties
    lazy var topBarView: UIView = {
        var view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    lazy var logoutButton: UIButton = {
        var button = UIButton()
        button.setTitle("Logout", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(handleLogOut), for: .touchUpInside)
        return button
    }()
    
    lazy var backButton: UIButton = {
        var button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "chevron.compact.down"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        return button
    }()
    
    lazy var confirmEditButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleConfirmButtonPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var cancelEditButton: UIButton = {
        var button = UIButton()
        let x = "X"
        button.setTitle("X", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleCancelButtonPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var changeImageButton: UIButton = {
        var button = UIButton()
        button.backgroundColor = .white
        button.setBackgroundImage(UIImage(systemName: "camera"), for: .normal)
        button.tintColor = .black
        button.contentMode = .bottom
        button.addTarget(self, action: #selector(handleImagePicker), for: .touchUpInside)
        return button
    }()
    
    lazy var userImage: UIImageView = {
            var imageView = UIImageView()
            imageView.backgroundColor = .white
            imageView.image = UIImage(systemName: "person.fill")
            imageView.tintColor = .systemYellow
            imageView.layer.borderWidth = 2
            return imageView
        }()
    
    //MARK: labels
    
    lazy var nameLabel: UILabel = {
        var label = UILabel()
        label.text = "Full Name"
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        label.textColor = .darkGray
        return label
    }()
    
    lazy var usernameLabel: UILabel = {
        var label = UILabel()
        label.text = "Username"
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        label.textColor = .darkGray
        return label
    }()
    
    lazy var emailLabel: UILabel = {
        var label = UILabel()
        label.text = "E-mail Address"
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        label.textColor = .darkGray
        return label
    }()
    
    //MARK: Textfields
    
    lazy var nameTextField: UITextField = {
        var textField = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        textField.borderStyle = .none
        textField.placeholder = "Name"
        textField.backgroundColor = .white
        return textField
    }()
    
    lazy var usernameTextField: UITextField = {
        var textField = UITextField()
        textField.borderStyle = .none
        textField.placeholder = "Username"
        textField.backgroundColor = .white
        return textField
    }()
    
    lazy var emailTextField: UITextField = {
        var textField = UITextField()
        textField.borderStyle = .none
        textField.placeholder = "Email"
        textField.backgroundColor = .white
        return textField
    }()
    
    //MARK: - Regular Properties
    
    var currentTextfield: UITextField!
    lazy var editTextFieldLayout = setEditTextFieldConstraint(textField: currentTextfield)
    var photoLibraryAccess = false
    
    //MARK: - Life Cycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDelegates()
        setUpSubviews()
        setUpConstraints()
        setUsernameAndEmail()
        getAndSetUserPhoto()
        miscSetUp()
        checkPhotoLibraryAccess()
        
    }
    
    override func viewDidLayoutSubviews() {
        nameTextField.styleTextView()
        usernameTextField.styleTextView()
        emailTextField.styleTextView()
    }
    
    //MARK: - Objc functions
    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleConfirmButtonPressed(){
        handleEditDismissal()
    }
    
    @objc func handleCancelButtonPressed(){
        handleEditDismissal()
    }
    
    @objc func handleLogOut(){
        logOut()
    }
    @objc func handleImagePicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        if self.photoLibraryAccess {
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController,animated: true)
        } else {
            let noAuthenticationAlertalertVC = UIAlertController(title: "Acess Denied", message: "This app has not been authorized to access your photo library. Would you like to authorize it now?", preferredStyle: .alert)
            noAuthenticationAlertalertVC.addAction(UIAlertAction (title: "Deny", style: .destructive, handler: nil))
            self.present(noAuthenticationAlertalertVC, animated: true, completion: nil)
            
            noAuthenticationAlertalertVC.addAction(UIAlertAction (title: "Allow", style: .default, handler: { (action) in
                self.photoLibraryAccess = true
                self.present(imagePickerController, animated: true, completion: nil)
            }))
        }
    }
    
    //MARK: - Private Functions
    
    private func logOut() {
        FirebaseAuthService.manager.logOut { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(()):
                    self.segueToLogin()
                case.failure(_):
                    self.showAlert(title: "Error", message: "Could not go back to Login")
                }
            }
        }
    }
    
    private func segueToLogin() {
        let window = uiWindow()
    
        UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromLeft, animations: {
            window.rootViewController = LoginViewController()
        }, completion: nil)
    }
    
    func uiWindow() -> UIWindow {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let sceneDelegate = windowScene.delegate as? SceneDelegate, let window = sceneDelegate.window
            else {
                print("error with segue")
                return UIWindow()
        }
        return window
    }
    
    private func checkPhotoLibraryAccess() {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            print(status)
            self.photoLibraryAccess = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({status in
                switch status {
                case .authorized:
                    self.photoLibraryAccess = true
                    print(status)
                case .denied:
                    self.photoLibraryAccess = false
                    print("denied")
                case .notDetermined:
                    print("not determined")
                case .restricted:
                    print("restricted")
                }
            })
            
        case .denied:
            
            showAlert(title: "Denied", message: "This app has not been authorized to access your photo library. Please change your settings.")
            
        case .restricted:
            print("restricted")
        }
    }
    
    
    //MARK: - Setup Functions
    func setUpDelegates() {
        usernameTextField.delegate = self
        nameTextField.delegate = self
        emailTextField.delegate = self
    }
    
    private func setUpStyling() {
        styleTextViews(textfield: nameTextField)
        styleTextViews(textfield: usernameTextField)
        styleTextViews(textfield: emailTextField)
    }
    
    private func miscSetUp(){
        self.view.backgroundColor = .white
        self.userImage.layer.cornerRadius = 150/2
        self.userImage.layer.masksToBounds = true
        
        changeImageButton.layer.cornerRadius = 30/2
        changeImageButton.layer.masksToBounds = true
        
        confirmEditButton.alpha = 0
        cancelEditButton.alpha = 0
    }
    
    private func setUsernameAndEmail() {
        FirestoreService.manager.getUsernameOrEmail(whichOne: "userName") { (result) in
            switch result {
            case .failure(let error):
                print("Error getting username: \(error.localizedDescription)")
            case .success(let username):
                self.usernameTextField.text = username
            }
        }
        
        FirestoreService.manager.getUsernameOrEmail(whichOne: "email") { (result) in
            switch result {
            case .failure(let error):
                print("Error getting email: \(error.localizedDescription)")
            case .success(let email):
                self.emailTextField.text = email
            }
        }
    }
    
    private func getAndSetUserPhoto() {
        if let url = Auth.auth().currentUser?.photoURL {
            FirebaseStorageService(imageType: .profileImage).getImage(photoUrl: url) { (result) in
                switch result {
                case .failure(let error):
                    self.showAlert(title: "Error", message: "Could not retrieve user photo: \(error.localizedDescription)")
                case .success(let image):
                    self.userImage.image = image
                }
            }
        }
    }
    
    //MARK: - edit buttons' functions
    
    func handleEditDismissal(){
        
        UIView.animate(withDuration: 0.70, animations: {

            self.backButton.alpha = 1
            self.logoutButton.alpha = 1
            self.confirmEditButton.alpha = 0
            self.cancelEditButton.alpha = 0
            
            self.emailLabel.alpha = 1
            self.emailTextField.alpha = 1
            
            self.usernameLabel.alpha = 1
            self.usernameTextField.alpha = 1
            
            self.nameLabel.alpha = 1
            self.nameTextField.alpha = 1

            if self.currentTextfield == self.nameTextField {
                
                self.editTextFieldLayout.isActive = false
                self.currentTextfield.resignFirstResponder()
                
            } else if self.currentTextfield == self.emailTextField {
                
                self.editTextFieldLayout.isActive = false
                self.currentTextfield.resignFirstResponder()
                
            } else if self.currentTextfield == self.usernameTextField {
                
                self.editTextFieldLayout.isActive = false
                self.currentTextfield.resignFirstResponder()
            }
            
            
            
            self.view.layoutIfNeeded()
        })
        
        UIView.animate(withDuration: 0.5, delay: 0.70, animations: {
            self.userImage.alpha = 1
            self.changeImageButton.alpha = 1
            self.view.layoutIfNeeded()
        })
    }
    
    func setEditTextFieldConstraint(textField: UITextField) -> NSLayoutConstraint {
        var layout = NSLayoutConstraint()
        
        if textField == nameTextField {
            layout = textField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 110)
        } else if textField == usernameTextField {
            layout = textField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 60)
        } else if textField == emailTextField {
            layout = textField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10)
        }
        return layout
    }
    
    
    //MARK: - Styling functions
    func styleTextViews(textfield: UITextField) {
        
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - -4, width: textfield.frame.width, height: 2)
        
        bottomLine.backgroundColor = UIColor.init(red: 69/255, green: 69/255, blue: 69/255, alpha: 1).cgColor
        
        textfield.layer.addSublayer(bottomLine)
        
        textfield.borderStyle = .none
        textfield.backgroundColor = .white
    }
}
