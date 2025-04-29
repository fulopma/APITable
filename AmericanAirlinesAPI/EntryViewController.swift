//
//  EntryViewController.swift
//  AmericanAirlinesAPI
//
//  Created by Marcell Fulop on 4/29/25.
//

import UIKit

class EntryViewController: UIViewController {
    var name: String?
    @IBOutlet weak var nameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = name
    }


}
