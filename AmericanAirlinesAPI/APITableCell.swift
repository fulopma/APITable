//
//  APITableCell.swift
//  AmericanAirlinesAPI
//
//  Created by Marcell Fulop on 4/28/25.
//

import UIKit

class APITableCell: UITableViewCell {

    @IBOutlet weak var cellResultLabel: UILabel!
    @IBOutlet weak var cellLinkLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
