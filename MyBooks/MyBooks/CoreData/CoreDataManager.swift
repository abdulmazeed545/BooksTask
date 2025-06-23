//
//  CoreDataManager.swift
//  MyBooks
//
//  Created by Mazeed on 23/06/25.
//

import UIKit
import Foundation
import CoreData

class CoreDataManger: NSObject {
    static let shared = CoreDataManger()
    
    let container: NSPersistentContainer = NSPersistentContainer(name: "MyBooks")
    func clearPersistentStore(completion: @escaping () -> ()) {
        guard let storeURL = container.persistentStoreDescriptions.first?.url else { return }

        do {
            // Remove the existing store
            try FileManager.default.removeItem(at: storeURL)
            print("Persistent store cleared.")
            completion()
        } catch {
            print("Failed to clear persistent store: \(error.localizedDescription)")
        }
    }
    override init() {
        super.init()
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
                return
            }
            
            self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        }
    }
    
    public var context: NSManagedObjectContext {
        get {
            return self.container.viewContext
        }
    }
    
    
    // MARK: - Common Methods
    public func save() {
        // Check if there are changes before attempting to save
        if self.context.hasChanges {
            do {
                // Attempt to save the context
                try self.context.save()
                print("Saved data successfully")
            } catch let error as NSError {
                // Log the error and provide more context
                print("Unresolved CoreData error \(error), \(error.userInfo)")
                
            }
        } else {
           print("No changes to save.")
        }
    }

    public func update() {
        do {
            // Try saving the context
            try self.context.save()
            print("Data updated successfully.")
        } catch let error as NSError {
            // Catch specific NSError and log the error
            let errorMessage = "Unresolved error \(error), \(error.userInfo)"
            print(errorMessage)
            
            // Optionally, you can add further error handling (e.g., alerting the user or retrying)
            // You can even consider re-throwing the error or handling the failure gracefully based on your needs
            handleCoreDataError(error)
        } catch {
            // Handle any unexpected errors
            print("An unexpected error occurred: \(error.localizedDescription)")
        }
    }

    private func handleCoreDataError(_ error: NSError) {
        // Check the error domain
        if error.domain == NSCocoaErrorDomain {
            switch error.code {
            case NSValidationMissingMandatoryPropertyError:
                print("Save failed: Missing a mandatory property.")
            case NSValidationRelationshipLacksMinimumCountError:
                print("Save failed: Relationship lacks minimum count.")
            case NSValidationRelationshipExceedsMaximumCountError:
                print("Save failed: Relationship exceeds maximum count.")
            case NSValidationInvalidDateError:
                print("Save failed: Invalid date.")
            case NSPersistentStoreSaveError:
                print("Save failed: Persistent store error.")
            default:
                print("Core Data error: \(error.localizedDescription)")
            }
        }
    }
    
    public func delete(row : NSManagedObject?) {
        if let currentRow = row {
            self.context.delete(currentRow)
            self.save()
        }
    }
 
    public func deleteAll(strEntityName: String, completion: @escaping () -> Void = {}) {
        // Getting context from your Core Data Manager Class
        let managedContext = context
        managedContext.perform {
            // Create a fetch request to retrieve the objects to delete
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: strEntityName)
            
            // Create a batch delete request
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            
            // Set the result type to .resultTypeObjectIDs to get the object IDs of deleted objects
            deleteRequest.resultType = .resultTypeObjectIDs
            
            do {
                // Perform the batch delete
                let result = try managedContext.execute(deleteRequest) as? NSBatchDeleteResult
                
                // Extract the object IDs of the deleted objects
                if let objectIDs = result?.result as? [NSManagedObjectID] {
                    // Merge the changes to the context to update in-memory managed objects
                    let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: objectIDs]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [managedContext])
                }
                
                print("\(strEntityName): Deleted Entities successfully")
                completion()
            } catch let error as NSError {
               print("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    public func clearDB() {
        let entityNames = [EntityName.ProductsEntity]
        
        entityNames.forEach({
            CoreDataManger.shared.deleteAll(strEntityName: $0)
        })
    }
    
}

