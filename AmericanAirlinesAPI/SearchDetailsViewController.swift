//
//  SearchDetailsViewController.swift
//  AmericanAirlinesAPI
//
//  Created by Marcell Fulop on 5/2/25.
//

import UIKit

class SearchDetailsViewController: UIViewController, UITableViewDataSource {
    
    var additionalDetails: [SearchResult] = []
    
    @IBOutlet weak var additionalDetailsViewTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        additionalDetailsViewTable.dataSource = self
        if additionalDetails.count == 0 {
            print("Something went wrong.")
            abort()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(additionalDetails.count)
        return additionalDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell =
                tableView.dequeueReusableCell(
                    withIdentifier: "cell",
                    for: indexPath
                ) as? SearchDetailsTableViewCell
        else {
            print("Casting failed")
            abort()
        }
        var relatedText = additionalDetails[indexPath.row].result ?? ""
        relatedText = relatedText.replacing(/<a[^>]+>/, with: "")
        relatedText = relatedText.replacing(/<.*/, with: "")
        cell.descriptionLabel.text = relatedText
        cell.linkLabel.text = additionalDetails[indexPath.row].firstURL
        
        return cell
    }
    

}
