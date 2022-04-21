
import  CoreData

@objc(Restaurant)
class Restaurant:NSManagedObject{
    
    @NSManaged var id:NSNumber!
    @NSManaged var name:String!
    @NSManaged var desc:String!
    @NSManaged var deletedDate:Date?
    @NSManaged var phone:String!
    @NSManaged var address:String!
    @NSManaged var tags:String!
    @NSManaged var ratings:String!
    
    
    
}
