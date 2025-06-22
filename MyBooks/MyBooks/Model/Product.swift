import Foundation

struct Product: Codable, Identifiable {
    let id: String
    let name: String
    let data: ProductData?
}

struct ProductData: Codable {
    let color: String?
    let capacity: String?
    let capacityGB: Int?
    let price: Double?
    let generation: String?
    let year: Int?
    let cpuModel: String?
    let hardDiskSize: String?
    let strapColour: String?
    let caseSize: String?
    let description: String?
    let screenSize: Double?
    let Capacity: String?
    let Generation: String?
    let Price: String?
    let Color: String?
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