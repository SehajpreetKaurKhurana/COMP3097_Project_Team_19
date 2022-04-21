import UIKit
import CoreData
var restaurantList = [Restaurant]()

class RestaurantTableView:UITableViewController, UISearchResultsUpdating, UISearchBarDelegate{
    
    var firstLoad = true
    
    var searchController: UISearchController! // search bar controller
    var searchRestaurantResults:[Restaurant] = [] //array to store results for search by name
    
    
      
    func nonDeletedRestaurants () -> [Restaurant]  {
        var noDeleteRestaurantList = [Restaurant]()
        
        for restaurant in restaurantList {
            if(restaurant.deletedDate == nil){
                noDeleteRestaurantList.append(restaurant)
            }
        }
        return noDeleteRestaurantList
    }
    
    
    override func viewDidLoad() {
        
        //add a searchbar
        searchController = UISearchController(searchResultsController: nil)
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        //search bar options
        searchController.searchBar.placeholder = "Search by Name"
        
        //searchbar Disappears when tapped
        searchController.hidesNavigationBarDuringPresentation = false
        
        //add a color to the searchbar
        searchController.searchBar.tintColor = UIColor.blue
        
        
        
        if(firstLoad){
            firstLoad = false
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context:  NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Restaurant")
            
            do{
                let results:NSArray = try context.fetch(request) as NSArray
                for result in results{
                    let restaurant = result as! Restaurant
                    restaurantList.append(restaurant)
                }
                
            }catch{
                print("Fetch Failed")
            }
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let restaurantCell=tableView.dequeueReusableCell(withIdentifier:"restaurantCellID" ,for: indexPath) as! RestaurantCell
        
        let thisRestaurant: Restaurant!
        
        
        //edited for search
        thisRestaurant = (searchController.isActive) ? searchRestaurantResults[(indexPath as NSIndexPath).row] : nonDeletedRestaurants()[(indexPath as NSIndexPath).row]
        //thisRestaurant = nonDeletedRestaurants()[indexPath.row]
        
        restaurantCell.nameLabel.text = thisRestaurant.name
        restaurantCell.descLabel.text = thisRestaurant.desc
        return restaurantCell
    }
    
    //edited for search bar
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if searchController.isActive{
            return searchRestaurantResults.count
        }else{
            return nonDeletedRestaurants().count
        }
        
    }
    
        //required for search
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if searchController.isActive{
            return false
        }else{
            return true
        }
    }
    
    //searchbar
    
    func filterContentForSearchByName(_ searchText: String){
        
        searchRestaurantResults = nonDeletedRestaurants().filter({ (restaurant: Restaurant) -> Bool in
            let nameMatch = restaurant.name!.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return nameMatch != nil}
        )
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchByNameText = searchController.searchBar.text{
            
            filterContentForSearchByName(searchByNameText)
            tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    var rowSelected : Int?
    //edit
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        rowSelected = indexPath.row
        
        self.performSegue(withIdentifier: "editRestaurant", sender: self)
//        self.performSegue(withIdentifier: "details", sender: self)

    }
    //edit
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
       
        if(segue.identifier=="editRestaurant"){
            let indexPath=tableView.indexPathForSelectedRow!
            
            let restaurantDetail = segue.destination as? RestaurantDetailVC
            
            let selectedRestaurant : Restaurant!
            
            selectedRestaurant = nonDeletedRestaurants()[indexPath.row]
            
            restaurantDetail!.selectedRestaurant = selectedRestaurant
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            
            
        }
        
        
        
    }
    
    
    
    
   
    
    
    
   
    
    
    
    
    
    
}
