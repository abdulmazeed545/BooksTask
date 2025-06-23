//
//  Encodale+Extension.swift
//  MyBooks
//
//  Created by PeopleLink on 23/06/25.
//

import UIKit

extension Encodable {
    
    var dictionaryArray: [[String: Any]]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: [.allowFragments])).flatMap { $0 as? [[String: Any]] }
    }
    
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
    
    var stringDictionary: [String: String]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: String] }
    }
    
    var toJsonString: NSString? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        let jsonString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        return jsonString
    }
}

extension String{
    var isEmptyString : Bool {
        return self.isEmpty || self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || self == "N/A"
    }
}
