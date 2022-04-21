//
//  ViewController.swift
//  COMP3097_Project_Team_19
//
//  Created by Graphic on 2022-04-14.
//

import UIKit
import CoreData
import MessageUI
import Social

class RestaurantDetailVC: UIViewController {

    @IBOutlet weak var descTV: UITextView!
    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var idLabel: UILabel!
    
    @IBOutlet weak var tagsTF: UITextField!
    
    @IBOutlet weak var addressTV: UITextView!
    
    @IBOutlet weak var ratingsTF: UITextField!
    
    
    @IBOutlet weak var phoneTF: UITextField!
    
    
    
    @IBOutlet weak var emailTF: UITextField!
    
    
    
    @IBOutlet weak var emailBtn: UIButton!
    
    @IBOutlet weak var twitterTF: UITextField!
    
    @IBOutlet weak var twitterBtn: UIButton!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
       
        if(segue.identifier=="showMap"){
            //let indexPath=tableView.indexPathForSelectedRow!
            
            let restaurantAddress = segue.destination as? MapVC
            
            let selectedAddress : String!
            selectedAddress = addressTV.text!
            
            
            //selectedRestaurant = nonDeletedRestaurants()[indexPath.row]
            
            restaurantAddress!.selectedAddress = selectedAddress
            
            //tableView.deselectRow(at: indexPath, animated: true)
            
            
            
        }
    }
    
    @IBAction func shareOnTwitter(_ sender: Any) {
        
        shareOnTwitter()
    }
    
    //share on facebook or twitter
    @IBAction func shareBtnAction(_ sender: Any) {
        
        let messageToShare = "Name:  \( nameTF.text!)Description:  \(descTV.text!) Address:  \(addressTV.text!)  Phone:  \(phoneTF.text!)  Ratings: \(ratingsTF.text!) Tag:  \(tagsTF.text!)";
        
        //display an alert, as an action sheet
        let shareAlert = UIAlertController(title: "Share", message: "Share this restaurant!", preferredStyle: .actionSheet)
        
        //first action
        let facebookAction = UIAlertAction(title: "Share on Facebook", style: .default){(action) in
//            print("Sucess!")
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
                
                let fbPost = SLComposeViewController(forServiceType: SLServiceTypeFacebook)!
                fbPost.setInitialText(messageToShare)
                
                self.present(fbPost, animated: true, completion: nil)
            }
            else{
                
                self.showErrorAlert(service: "Facebook")
                
            }
            
        }
        
        
        
        
        //now we add some actions to the action sheet
        shareAlert.addAction(facebookAction)
      
        
        //present alert
        self.present(shareAlert, animated: true, completion: nil)
        
    }
    func showErrorAlert(service: String){
        let errorAlert = UIAlertController(title: "Error", message: "Device is not connected to \(service)!", preferredStyle: .alert)
        let errorAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        
        errorAlert.addAction(errorAction)
        
        present(errorAlert, animated: true, completion: nil)
    }
    
    
    
    var selectedRestaurant: Restaurant? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if(selectedRestaurant != nil) {
            nameTF.text = selectedRestaurant?.name
            descTV.text = selectedRestaurant?.desc
            tagsTF.text = selectedRestaurant?.tags
            addressTV.text = selectedRestaurant?.address
            ratingsTF.text = selectedRestaurant?.ratings
            phoneTF.text = selectedRestaurant?.phone
            //idLabel.text = selectedRestaurant?.id.stringValue
        }
    }


    @IBAction func save(_ sender: Any) {
        
       
        
    }
    
    
    @IBAction func saveAction(_ sender: Any) {
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:  NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        if(selectedRestaurant == nil){ //add as no row there
        let entity = NSEntityDescription.entity(forEntityName: "Restaurant", in: context)
        
        let newRestaurant = Restaurant(entity: entity!, insertInto: context)
        
        newRestaurant.id = restaurantList.count as NSNumber
        newRestaurant.name = nameTF.text
        newRestaurant.desc = descTV.text
        newRestaurant.address = addressTV.text
        newRestaurant.tags = tagsTF.text
        newRestaurant.phone = phoneTF.text
        newRestaurant.ratings = ratingsTF.text
        
        
        do{
            try context.save()
            restaurantList.append(newRestaurant)
            navigationController?.popViewController(animated: true)
        }
        catch{
            print("context save error ")
        }
        
        }else{ //edit means row already there
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Restaurant")
            
            do{
                let results:NSArray = try context.fetch(request) as NSArray
                for result in results{
                    let restaurant = result as! Restaurant
                    if(restaurant == selectedRestaurant){
                        restaurant.name = nameTF.text
                        restaurant.desc = descTV.text
                        restaurant.address = addressTV.text
                        restaurant.ratings = ratingsTF.text
                        restaurant.tags = tagsTF.text
                        restaurant.phone = phoneTF.text
                        
                        try context.save()
                        navigationController?.popViewController(animated: true)
                        
                    }
                }
                
            }catch{
                print("Fetch Failed")
            }
            
        }
        
        
    }
    
    
    

    @IBAction func DeleteRestaurant(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:  NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Restaurant")
        
        do{
            let results:NSArray = try context.fetch(request) as NSArray
            for result in results{
                let restaurant = result as! Restaurant
                if(restaurant == selectedRestaurant){
                   
                    restaurant.deletedDate = Date()
                    try context.save()
                    navigationController?.popViewController(animated: true)
                    
                }
            }
            
        }catch{
            print("Fetch Failed")
        }
    }
    
    
    
 
    
    
    @IBAction func sendEmail(_ sender: Any) {
        showMailComposer()
        
    }
    
   
    func showMailComposer()
    {
        var emailBody =  "Name:  \( nameTF.text!)Description:  \(descTV.text!) Address:  \(addressTV.text!)  Phone:  \(phoneTF.text!)  Ratings: \(ratingsTF.text!) Tag:  \(tagsTF.text!)";
        
        guard MFMailComposeViewController.canSendMail() else {
            print(emailBody)
            print("Mail services are not available in your emulator")
           
            return
        }
        
        
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
         
        // Configure the fields of the interface.
        composer.setToRecipients([emailTF.text!])
        composer.setSubject("Restaurant App Details Made By Team 19")
        composer.setMessageBody("Hello from California!", isHTML: false)
         
        // Present the view controller modally.
        self.present(composer, animated: true)
        
        
        }
    
    
    
    
    
}










extension RestaurantDetailVC: MFMailComposeViewControllerDelegate{
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _=error{
          return  controller.dismiss(animated: true)
        }
        
        switch result {
        case .cancelled:
            print("Cancelled")
        case .saved:
            print("Saved")
        case .sent:
            print("Sent")
        case .failed:
            print("Failed")
        }
        
        controller.dismiss(animated: true)
    }
    
    //share on twitter function called when u click on share on twitter button
    func shareOnTwitter(){
        
        //let twitterURL = twitterTF.text
        let tweet = "Name:  \( nameTF.text!)Description:  \(descTV.text!) Address:  \(addressTV.text!)  Phone:  \(phoneTF.text!)  Ratings: \(ratingsTF.text!) Tag:  \(tagsTF.text!)";
        
        let twitterMessage = "https://twitter.com/intent/tweet?text=\(tweet)"
        
        
        //encode a space to %20 for example
        let escapeTwitterMessage = twitterMessage.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        //cast to a url
        let url = URL(string: escapeTwitterMessage)
        
        //open in safari
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        
        
    }
    
    
    
}
