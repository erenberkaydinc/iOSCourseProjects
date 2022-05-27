//
//  FeedViewController.swift
//  BasicSocialMediaApp
//
//  Created by Eren Berkay Dinç on 26.05.2022.
//

import UIKit
import Firebase
import SDWebImage

class FeedViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
  
    @IBOutlet weak var tableView: UITableView!
    
    var postDizisi = [Post]()
    let dateFormatter = DateFormatter()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        getFirebaseData()
    }
    
    func getFirebaseData(){
        let firestoreDatabase = Firestore.firestore()
        
        firestoreDatabase.collection("Post").order(by: "date",descending: true).addSnapshotListener { snapshot, error in
            
            if error != nil {
                print(error?.localizedDescription)
                
            }else{
                // if snapshot is not empty
                if snapshot?.isEmpty != true && snapshot != nil {
                    self.postDizisi.removeAll(keepingCapacity: false)
                 
                    
                    for document in snapshot!.documents {
                        //let documentId = document.documentID
                        
                        if let imageURL = document.get("imageURL") as? String{
                            
                            if let title = document.get("title") as? String{
                                
                                if let date = document.get("date") as? Timestamp{
                                    
                                if let email = document.get("email") as? String{
                                    
                                    let post = Post(email: email, title: title, imageURL: imageURL,date:date.dateValue())
                                    self.postDizisi.append(post)
                                    
                                    }
                                }
                            }
                            
                        }
                        
                        
                      
                        
                    }
                    
                    self.tableView.reloadData()
                    
                }
                
            }
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postDizisi.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath) as! FeedCell
        // we casted it as a feedcell
        // so we can reach all properties
        cell.emailText.text = postDizisi[indexPath.row].email
        cell.titleText.text = postDizisi[indexPath.row].title
        
        dateFormatter.dateFormat = "dd/MM/YY"
        cell.timeText.text = dateFormatter.string(from: postDizisi[indexPath.row].date)
        cell.postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.postImageView.sd_setImage(with: URL(string: self.postDizisi[indexPath.row].imageURL))
        
        
        return cell
        
    }
    
    
    func timeSinceNowString(_ timeInterval:TimeInterval) -> String {

        let calendar = Calendar.current

        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: Date(timeIntervalSince1970: timeInterval/1000), to: Date())

        guard let days = components.day, let hours = components.hour, let minutes = components.minute else {return ""}

        switch days {
        case 366...:
            return "\(days/365) years ago"
        case 7...:
            return "\(days/7) \(days/7 == 1 ? "week" : "weeks") ago"
        case 1...:
            return "\(days) \(days == 1 ? "day" : "days") ago"
        default:
            if hours > 0 {
                return "\(hours) \(hours == 1 ? "hour" : "hours") ago"
            }else if minutes > 0 {
                return "\(minutes) \(minutes == 1 ? "minute" : "minutes") ago"
            }else{
                return "now"
            }
        }

    }
   

}
