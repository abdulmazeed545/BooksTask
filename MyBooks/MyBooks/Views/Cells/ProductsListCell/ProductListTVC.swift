//
//  ProductListTVC.swift
//  MyBooks
//
//  Created by SK ABDUL MAZEED on 22/06/25.
//

import UIKit

class ProductListTVC: UITableViewCell {

    static let identifier = "ProductListTVC"
    @IBOutlet weak var lblSerialNo: UILabel!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var vaBorders: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        vaBorders.drawShadow(cornerRadius: 10, shadowColor: .gray, shadowOpacity: 0.3, shadowOffset: CGSize(width: 0, height: 2), shadowRadius: 4)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateData(obj: Product){
        lblSerialNo.text = "S.No:  \(obj.id)"
        lblProductName.text = obj.name
    }
    
}
