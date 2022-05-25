//
//  ViewController.swift
//  HaritalarUygulamasi
//
//  Created by Eren Berkay Dinç on 22.05.2022.
//

import UIKit
import MapKit //import ettik
import CoreLocation
import CoreData


class MapsViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var isimTextField: UITextField!
    
    @IBOutlet weak var NotTextField: UITextField!
    
    @IBOutlet weak var kaydetButton: UIButton!
    var locationManager = CLLocationManager()
    
    var secilenLatitude = Double()
    var secilenLongitude = Double()
    
    var secilenIsim = ""
    var secilenId : UUID?
    
    var annotationTitle = ""
    var annotationSubTitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(konumuSec(gestureRecognizer:)))
        //long press uzun sure basili tutmak demek
        
        gestureRecognizer.minimumPressDuration = 3
        
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if secilenIsim != "" {
            //Core data'dan verileri cek
            
            if let uuidString = secilenId?.uuidString {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
                //hangi kolonu filtreleyecegimizi ve hangi kolonu, idye esit olanlari getir
                
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do{
                    let sonuclar = try context.fetch(fetchRequest)
                    
                    if sonuclar.count > 0 {
                        
                        for sonuc in sonuclar as! [NSManagedObject] {
                            //idye gore cektigimiz icin genelde 1 adet donucek
                            
                            if let isim = sonuc.value(forKey: "isim") as? String{
                                annotationTitle = isim
                                
                                if let not = sonuc.value(forKey: "not") as? String{
                                    annotationSubTitle = not
                                    
                                    if let latitude = sonuc.value(forKey: "latitude") as? Double{
                                        annotationLatitude = latitude
                                        
                                        if let longitude = sonuc.value (forKey: "longitude") as? Double {
                                            annotationLongitude = longitude
                                            
                                            let annotation = MKPointAnnotation()
                                            annotation.title = annotationTitle
                                            annotation.subtitle = annotationSubTitle
                                            let coordinate = CLLocationCoordinate2D(latitude:annotationLatitude, longitude: annotationLongitude)
                                            annotation.coordinate = coordinate
                                            
                                            mapView.addAnnotation (annotation)
                                            isimTextField.text = annotationTitle
                                            NotTextField.text = annotationSubTitle
                                            
                                            locationManager.stopUpdatingLocation()
                                            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                            let region = MKCoordinateRegion(center: coordinate, span: span)
                                            
                                            mapView.setRegion(region, animated: true)
                                            
                                        }
                                    }
                                    
                                }
                                
                            }
                            
                            
                        }
                        
                    }
                    
                }catch{
                    print("hata")
                }
                
                
                
            }
            
            kaydetButton.isHidden = true
            
            
        }else{
            //yeni veri eklemeye geldik
        }
        
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
          
            return nil
        
        }
        let reuseId = "benimAnnotation"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil {
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = .systemBlue
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            
            pinView?.rightCalloutAccessoryView = button
            
        }else {
            pinView?.annotation = annotation
        }
        
        return pinView
        
    }
    
    //CallOutAccessor'a tiklaninca ne olacak
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if secilenIsim != "" {
            
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            
            //tersten yap geo code islemini
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarkDizisi, hata) in
                //closure yapisi
                
                if let placemarks = placemarkDizisi{
                   
                    if placemarks.count > 0 {
                        
                        let yeniPlacemark = MKPlacemark(placemark: placemarks[0])
                        
                        let item = MKMapItem(placemark: yeniPlacemark)
                        item.name = self.annotationTitle
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        
                        item.openInMaps(launchOptions: launchOptions)
                        
                        
                    }
                    
                }
                
               
                
            }
            
        }
        
    }
    
    
    
    @objc func konumuSec(gestureRecognizer:UILongPressGestureRecognizer){
        
        if gestureRecognizer.state == .began {
            
            let dokunulanNokta = gestureRecognizer.location(in: mapView)
            //dokunulan yeri koordinata ceviriyoruz
            let dokunulanKoordinat = mapView.convert(dokunulanNokta, toCoordinateFrom: mapView)
            
            secilenLatitude = dokunulanKoordinat.latitude
            secilenLongitude = dokunulanKoordinat.longitude
            
            //annotation isaretleme demektir , haritada isaretlemeni saglar
            let annotation = MKPointAnnotation()
            annotation.coordinate = dokunulanKoordinat
            annotation.title = isimTextField.text
            annotation.subtitle = NotTextField.text
            
            mapView.addAnnotation(annotation)
            
        }
        
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //enlem boylam , koordinatlar
        //        print(locations[0].coordinate.latitude)
        //        print(locations[0].coordinate.longitude)
        
        if secilenIsim == ""{
            
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            
            let region = MKCoordinateRegion(center: location, span: span)
            
            mapView.setRegion(region, animated: true)
            
        }
        
    }
    
    
    
    @IBAction func kaydetTiklandi(_ sender: UIButton) {
        
        //CORE DATA save aliyoruz
        //appdelegate , context
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //entity ismi , context
        let yeniYer = NSEntityDescription.insertNewObject(forEntityName: "Yer", into: context)
        
        yeniYer.setValue(isimTextField.text!, forKey: "isim")
        yeniYer.setValue(NotTextField.text!, forKey: "not")
        
        //enlem ve boylam , latitude = enlem , longitude = boylam
        yeniYer.setValue(secilenLongitude, forKey: "longitude")
        yeniYer.setValue(secilenLatitude, forKey: "latitude")
        
        //uuid
        yeniYer.setValue(UUID(), forKey: "id")
        
        //kaydet fonk
        do{
            try context.save()
            print("kayit edildi")
        }catch{
            print("hata")
        }
        
        //kaydedilince geri donuyoruz listeviewine otomatik olarak
        NotificationCenter.default.post(name: NSNotification.Name("yeniYerOlusturuldu"), object:nil )
        navigationController?.popViewController(animated: true)
        
    }
    
    
}

