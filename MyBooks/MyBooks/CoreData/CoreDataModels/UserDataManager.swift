//
//  UserDataManager.swift
//  MyBooks
//
//  Created by Mazeed on 23/06/25.
//

import Foundation
import CoreData

class UserInfoModel: NSObject {
    static let shared = UserInfoModel()
    let entityName = EntityName.UserEntity
    
    /**
        This method is used for add record.
     */
    static func saveUserRecord(userObj: UserDetails?) {
        guard let currentUser = userObj else {
            return
        }
        guard let entity = NSEntityDescription.entity(forEntityName: EntityName.UserEntity, in: CoreDataManger.shared.context) else {
            return
        }

        let userInfo = NSManagedObject(entity: entity,
                                       insertInto: CoreDataManger.shared.context)

        if let name = currentUser.name{
            userInfo.setValue(name, forKeyPath: UserEntityKeys.userName)
        }
        
        if let email = currentUser.email{
            userInfo.setValue(email, forKeyPath: UserEntityKeys.email)
        }
        
        if let imageUrl = currentUser.profileUrl{
            userInfo.setValue(imageUrl, forKeyPath: UserEntityKeys.profileUrl)
        }
        CoreDataManger.shared.save()
    }
    /**
        This method is used for get  user records.
     */
    static func getUserRecords() -> [UserEntity] {
        var arrUserRecords = [UserEntity]()
        // Create Fetch Request
          let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
          do {
              // Perform Fetch Request
              arrUserRecords = try  CoreDataManger.shared.context.fetch(fetchRequest)
          } catch {
              print("Unable to Fetch , (\(error))")
          }
          return arrUserRecords
    }
    
 
    func fetchOfflineRecords(completion: @escaping ([UserDetails]) -> Void) {
        
        let arrOfflineRecords = UserInfoModel.getUserRecords()
        
        var arrUsers = [UserDetails]()
        var count = 0
        if arrOfflineRecords.count > 0 {
            for userRecord in arrOfflineRecords {
                var userData = UserDetails()
                userData.name = userRecord.userName
                userData.email = userRecord.email
                userData.profileUrl = userRecord.profileUrl

                arrUsers.append(userData)
                
                if count == (arrOfflineRecords.count - 1) {
                    completion(arrUsers)
                    return
                }
                count += 1
            }
            
        }else{
            completion([])
            return
        }
    }
}
