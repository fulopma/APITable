//
//  SearchDetailsViewController.swift
//  AmericanAirlinesAPI
//
//  Created by Marcell Fulop on 5/2/25.
//

import UIKit
import SafariServices

class SearchDetailsViewController: UIViewController, UITableViewDataSource {

    var additionalDetails: [SearchResult]? = []
    var searchDetailsViewModel: SearchDetailsViewModel?
    
    @IBOutlet weak var additionalDetailsViewTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        additionalDetailsViewTable.dataSource = self
        additionalDetailsViewTable.delegate = self
        searchDetailsViewModel = SearchDetailsViewModel(additionalDetails: additionalDetails ?? [])
        // I don't know how to pass data between different
        // MVVMs
        additionalDetails = nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int {
            return searchDetailsViewModel?.getNumberOfRows() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
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
     
        cell.descriptionLabel.text = searchDetailsViewModel?.getText(for: indexPath.row)
        cell.linkLabel.text = searchDetailsViewModel?.getLink(for: indexPath.row)

        return cell
    }

}

extension SearchDetailsViewController: UITableViewDelegate, SFSafariViewControllerDelegate  {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let link = searchDetailsViewModel?.getLink(for: indexPath.row) ?? "no link found"
        guard let url = URL(string: link)
        else {
            print("Failed to open \(link)")
            return
        }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
        safariViewController.delegate = self
       
    }
}
