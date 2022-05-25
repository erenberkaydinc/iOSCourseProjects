//
//  ListViewController.swift
//  HaritalarUygulamasi
//
//  Created by Eren Berkay Dinç on 22.05.2022.
//

import UIKit
import CoreData

class ListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var tableView: UITableView!
    
    var isimDizisi = [String]()
    var idDizisi = [UUID]()
    
    var secilenYerIsmi = ""
    var secilenYerId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        //Navigation Bar buttonu ekliyoruz
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(artiButonuTiklandi))
        
        verileriCek()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(verileriCek), name: NSNotification.Name("yeniYerOlusturuldu"), object: nil)
        
       
        
    }
    
    
    
    @objc func verileriCek(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
        
        request.returnsObjectsAsFaults = false
        
        do {
            let sonuclar = try context.fetch(request)
            if sonuclar.count > 0 {
                
                isimDizisi.removeAll(keepingCapacity: false)
                idDizisi.removeAll(keepingCapacity: false)
                
                
                for sonuc in sonuclar as! [NSManagedObject]
                {
                    
                    if let isim = sonuc.value(forKey: "isim") as? String {
                        isimDizisi.append(isim)
                    }
                    
                    if let id = sonuc.value(forKey: "id") as? UUID {
                        idDizisi.append(id)
                    }
                    
                    
                    
                }
                
                tableView.reloadData()
            }
            
        }catch{
            print("Hata")
        }
        
    }
    
    @objc func artiButonuTiklandi(){
        secilenYerIsmi = ""
        
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    
    

    //TABLE VIEW
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isimDizisi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.textLabel?.text = isimDizisi[indexPath.row]
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        secilenYerIsmi = isimDizisi[indexPath.row]
        secilenYerId = idDizisi[indexPath.row]
        performSegue(withIdentifier: "toMapsVC", sender: nil)
        
        
    }
    //prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapsVC"{
            
            let destinationVC = segue.destination as! MapsViewController
            
            destinationVC.secilenIsim = secilenYerIsmi
            destinationVC.secilenId = secilenYerId
            
            
        }
        
    }
    

}
