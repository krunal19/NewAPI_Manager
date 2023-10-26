//
//  CellData.swift
//  WebServiceDemo
//
//  Created by Krunal on 27/10/23.
//

import UIKit

class CellData: UICollectionViewCell {
    
    static let identifier = "CellData"
    static let nib = UINib(nibName: "CellData", bundle: nil)
    @IBOutlet weak var imgEmp: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func config(){
        
    }
}
