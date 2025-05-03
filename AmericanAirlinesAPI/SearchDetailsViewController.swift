//
//  SearchDetailsViewController.swift
//  AmericanAirlinesAPI
//
//  Created by Marcell Fulop on 5/2/25.
//

import UIKit

class SearchDetailsViewController: UIViewController, UITableViewDataSource {
    
    var additionalDetails: [SearchResult]?
    
    @IBOutlet weak var additionalDetailsViewTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let additionalDetails = additionalDetails else {
            print("No additional details provided. You've segued wrong!")
            abort()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return additionalDetails?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    

}
