//
//  CoreDataConstants.swift
//  MyBooks
//
//  Created by PeopleLink on 23/06/25.
//

import Foundation


enum ProductwsEntityKeys {
    
    static let id = "id"
    static let name = "name"
    static let info = "myData"
}

enum UserEntityKeys{
    static let userName = "userName"
    static let email        = "email"
    static let profileUrl   = "profileUrl"
}
// MARK: - CoreData Entities
enum EntityName {
    static let ProductsEntity                     = "ProductsEntity"
    static let UserEntity                          = "UserEntity"
}
