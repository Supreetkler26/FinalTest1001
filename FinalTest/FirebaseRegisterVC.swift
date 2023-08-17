//
//  FirebaseRegisterVC.swift
//  FinalTest
//
//  Created by Ravi  on 2023-08-16.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class FirebaseRegisterVC: UIViewController {
    
    @IBOutlet var firstNameTextField: UITextField!
    
    @IBOutlet var lastNameTextField: UITextField!
    
    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var usernameTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var confirmPasswordTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func registerButton(_ sender: Any) {
        guard let username = usernameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text,
              password == confirmPassword else {
            print("Please enter valid email and matching passwords.")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Registration failed: \(error.localizedDescription)")
                return
            }

            // Store the username and email mapping in Firestore
            let db = Firestore.firestore()
            db.collection("usernames").document(username).setData(["email": email]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }

            print("User registered successfully.")
            DispatchQueue.main.async {
                FirebaseLoginVC.shared?.ClearLoginTextFields()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        
        FirebaseLoginVC.shared?.ClearLoginTextFields()
        dismiss(animated: true, completion: nil)
    }
    

}
