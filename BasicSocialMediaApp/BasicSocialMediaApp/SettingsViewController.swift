//
//  SettingsViewController.swift
//  BasicSocialMediaApp
//
//  Created by Eren Berkay Dinç on 26.05.2022.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    @IBOutlet weak var userEmail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        userEmail.text = Auth.auth().currentUser?.email
    }
    

    @IBAction func logOutPressed(_ sender: UIButton) {
        
//        let successAlert = UIAlertController(title: "Success!", message: "You have successfully logged out", preferredStyle: UIAlertController.Style.alert)
//        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
//        successAlert.addAction(okButton)
//
//
        do{
            try Auth.auth().signOut()
            performSegue(withIdentifier: "toViewController", sender: nil)
            
        }catch{
            errorMessage(titleInput: "Error", messageInput: error.localizedDescription)
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
