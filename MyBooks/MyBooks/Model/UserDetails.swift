//
//  UserDetails.swift
//  MyBooks
//
//  Created by PeopleLink on 23/06/25.
//

import Foundation

struct UserDetails: Codable {
    var email: String?
    var name: String?
    var profileUrl: String?
   
    init() {
        
    }
}
