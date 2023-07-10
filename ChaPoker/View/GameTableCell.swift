//
//  GameTableCell.swift
//  ChaPoker
//
//  Created by Elad Sabag on 10/07/2023.
//

import UIKit

class GameTableCell: UITableViewCell {
    @IBOutlet weak var tableModeLabel: UILabel!
    @IBOutlet weak var tableModeImg: UIImageView!
    @IBOutlet weak var joinTableBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
