import Foundation

struct Product: Codable, Identifiable {
    var id: String?
    var name: String?
    var data: ProductData?
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case data = "data"
    }
    
    // Default initializer (all properties nil)
     init() {
         self.id = nil
         self.name = nil
         self.data = nil
     }
}

struct ProductData: Codable {
    var color: String?
    var capacity: String?
    var capacityGB: Int?
    var price: Double?
    var generation: String?
    var year: Int?
    var cpuModel: String?
    var hardDiskSize: String?
    var strapColour: String?
    var caseSize: String?
    var description: String?
    var screenSize: Double?
    var Capacity: String?
    var Generation: String?
    var Price: String?
    var Color: String?
    // Add more fields as needed for flexibility
    
    enum CodingKeys: String, CodingKey {
        case color, capacity, price, generation, year
        case cpuModel = "CPU model"
        case hardDiskSize = "Hard disk size"
        case strapColour = "Strap Colour"
        case caseSize = "Case Size"
        case description = "Description"
        case screenSize = "Screen size"
        case capacityGB = "capacity GB"
        case Capacity, Generation, Price, Color
    }
} 
