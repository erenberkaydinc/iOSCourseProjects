//
//  UploadViewController.swift
//  BasicSocialMediaApp
//
//  Created by Eren Berkay Dinç on 26.05.2022.
//

import UIKit
import Firebase

class UploadViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        
        view.addGestureRecognizer(gestureRecognizer)
        
        //ImageView
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        
        imageView.addGestureRecognizer(imageGestureRecognizer)
     

    }
    
    @objc func chooseImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
       
        
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //when the image is selected and done
        
        imageView.image = info[.originalImage] as? UIImage
        
        self.dismiss(animated: true,completion: nil)
    }
    
    
    
    
    @objc func closeKeyboard(){
        view.endEditing(true)
    }
    
    
    @IBAction func shareBtnPressed(_ sender: UIButton) {
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let mediaFolder = storageReference.child("media") //media folder
        
        if let data = imageView.image?.jpegData(compressionQuality: 0.5){
            
            let uuid = UUID().uuidString
            
            if titleTextField.text != "" {
            
            let imageReference = mediaFolder.child("\(uuid).jpg")
            
            imageReference.putData(data,metadata: nil) { storageMetadata, error in
                
                if error != nil {
                    
                    self.errorMessage(titleInput: "Error", messageInput: error?.localizedDescription ?? "Something Happened")
                    
                } else{
                    
                    imageReference.downloadURL { [self] (url, error) in
                        
                        if error == nil {
                            
                            let imageUrl = url?.absoluteString
                            
                            if let imageUrl = imageUrl {
                                
                                let firestoreDatabase = Firestore.firestore()
                                
                                let firestorePost = ["imageURL": imageUrl,"title":self.titleTextField.text!,"email":Auth.auth().currentUser!.email, "date": FieldValue.serverTimestamp()] as [String:Any]
                                
                                firestoreDatabase.collection("Post").addDocument(data: firestorePost) { error in
                                    
                                    if error != nil {
                                        self.errorMessage(titleInput: "Hata", messageInput: error?.localizedDescription ?? "Something happened")
                                    }else{
                                        self.tabBarController?.selectedIndex = 0
                                        self.titleTextField.text = ""
                                        self.imageView.image = UIImage(named:"gallery")
                                        
                                    }
                                    
                                }
                                
                                
                                    
                            }
                            
                           
                            
                           
                            
                            
                        }
                        
                        
                    }
                    
                }
                
            }
            
            }
            
        }
            
        
        
        
    }
    
    
    func errorMessage(titleInput:String,messageInput:String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        
        alert.addAction(okButton)
        
        self.present(alert, animated: true)
    }
    
}
