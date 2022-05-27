//
//  DetailsViewController.swift
//  AlisverisListesi
//
//  Created by Eren Berkay Dinç on 19.05.2022.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imageVIew: UIImageView!
    
    @IBOutlet weak var isimTextField: UITextField!
    @IBOutlet weak var bedenTextField: UITextField!
    @IBOutlet weak var fiyatTextField: UITextField!
    
    
    @IBOutlet weak var kaydetButonu: UIButton!
    
    var secilenUrunIsmi = ""
    var secilenUrunUUID : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if secilenUrunIsmi != "" {
            
            kaydetButonu.isHidden = true
  
            //Core Data Secilen urun bilgileri goster
            if let uuidString = secilenUrunUUID?.uuidString {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString )
                fetchRequest.returnsObjectsAsFaults = false
                
                
                do {
                   let sonuclar = try context.fetch(fetchRequest)
                    
                    if sonuclar.count > 0 {
                        
                        for sonuc in sonuclar as! [NSManagedObject] {
                            
                            if let isim = sonuc.value(forKey: "isim") as? String {
                                isimTextField.text = isim
                            }
                            
                            if let fiyat = sonuc.value(forKey: "fiyat") as? Int {
                                fiyatTextField.text = String(fiyat)
                            }
                            
                            if let beden = sonuc.value(forKey: "beden") as? String {
                                bedenTextField.text = beden
                            }
                            
                            if let gorselData = sonuc.value(forKey: "gorsel") as? Data {
                               let image = UIImage(data: gorselData)
                                imageVIew.image = image
                            }
                            
                            
                        }
                        
                    }
                    
                } catch {
                    print("hata var")
                }
                
                
            }
            
            
            
        }else{
            kaydetButonu.isHidden = false
            kaydetButonu.isEnabled = false
            isimTextField.text = ""
            fiyatTextField.text = ""
            bedenTextField.text = ""
        }
        

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeyiKapat))
        
        view.addGestureRecognizer(gestureRecognizer)
        
        imageVIew.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gorselSec))
        imageVIew.addGestureRecognizer(imageGestureRecognizer)
        
    }
    
    @objc func gorselSec(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        
        present(picker, animated: true,completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageVIew.image = info[.editedImage] as? UIImage
        //secildikten sonra kapatma komutu
        kaydetButonu.isEnabled = true
        self.dismiss(animated: true,completion: nil)
        
    }
    
    
    
    @objc func klavyeyiKapat(){
        //klavyeyi kapat
        view.endEditing(true)
    }
    
    //Kaydet Buton Tiklandi
    @IBAction func butonTiklandi(_ sender: UIButton) {
        
        //CORE DATA
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context  = appDelegate.persistentContainer.viewContext
        
        let alisveris = NSEntityDescription.insertNewObject(forEntityName: "Alisveris", into: context)
        
        alisveris.setValue(isimTextField.text!, forKey: "isim")
        alisveris.setValue(bedenTextField.text!, forKey: "beden")
        
        if let fiyat = Int(fiyatTextField.text!){
            alisveris.setValue(fiyat, forKey: "fiyat")
        }
        
        //universal unique id , // UUID
        alisveris.setValue(UUID(), forKey: "id")
        
        let data = imageVIew.image!.jpegData(compressionQuality: 0.5)
        
        alisveris.setValue(data, forKey: "gorsel")
        
        do {
            try context.save()
            print("kaydedildi")
        }
        catch {
            print("HATA VAR")
        }
        
        //Notification Center
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"veriGirildi"), object: nil)
        
        //goBack navigation
        self.navigationController?.popViewController(animated: true)
        
    }
    

}
