//
//  ViewController.swift
//  BasicSocialMediaApp
//
//  Created by Eren Berkay Dinç on 26.05.2022.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    
    @IBAction func signInPressed(_ sender: UIButton) {
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            //login
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { authdataresult, error in
                
                if error != nil {
                    self.errorMessage(titleInput: "Error", messageInput: error?.localizedDescription ?? "something happened")
                }else{
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
                
            }
            
        }else{
            //email or password empty
            errorMessage(titleInput: "Error!", messageInput: "Please enter Email and Pass")
        }
    
    }
    
    
    @IBAction func signUpPressed(_ sender: Any) {
    
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            //register
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { authdataresult, error in
                
                if error != nil {
                    self.errorMessage(titleInput: "Error", messageInput: error?.localizedDescription ?? "something happened")
                }else{
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
                
            }
           
        }else{
            //email or password empty
            errorMessage(titleInput: "Error!", messageInput: "Please enter Email and Pass")
        }
    
        
    }
    
    
    //func for Error message
    func errorMessage(titleInput:String,messageInput:String){
        
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil)
        
        alert.addAction(okButton)
        self.present(alert, animated: true,completion: nil)
        
    }
    

}

