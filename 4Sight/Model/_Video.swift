// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Video.swift instead.

import Foundation
import CoreData

public enum VideoAttributes: String {
    case data = "data"
    case id = "id"
    case uploaded = "uploaded"
    case user_id = "user_id"
}

public class _Video: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Video"
    }

    public class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Video.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var data: Data

    @NSManaged public
    var id: String

    @NSManaged public
    var uploaded: NSNumber?

    @NSManaged public
    var user_id: String?

    // MARK: - Relationships

}

