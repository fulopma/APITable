//
//  ViewController.swift
//  AmericanAirlinesAPI
//
//  Created by Marcell Fulop on 4/28/25.
//

import Foundation
import UIKit
import SafariServices


// FirstUrl and Text or Name and Topics
// Base Url/path/httpRequest/?key=param&key2=param2
// ^ typical get request structure & ampersand seperates key=value pairs
// also header = is dictionary
// Http body is usually filled with JSON data like for POST requests

// REST / HTTP request equivalent
// Create POST
// Read   GET
// Update PUT
// Delete DELETE

protocol SearchViewDelegate: AnyObject {
    func didSelectRow(at indexPath: IndexPath)
}

class SearchView: UIViewController, UITableViewDataSource {

    @IBOutlet weak var apiTable: UITableView!
    @IBOutlet weak var apiSearchBar: UISearchBar!
    @IBOutlet weak var userInputSearchLabel: UILabel!
    private var searchViewModel: SearchViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // called delegation pattern
        apiTable.dataSource = self
        apiTable.delegate = self
        userInputSearchLabel.text = ""
        apiSearchBar.placeholder = "Search on 🦆🦆▶️"
        apiSearchBar.delegate = self
        searchViewModel = SearchViewModel()
        searchViewModel?.delegate = self
        self.title = "Search"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return searchViewModel?.setNumberOfSections() ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return searchViewModel?.getNumberOfRowsInSection(section: section) ?? 0
    }

    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        return searchViewModel?.getSectionTitle(forSection: section) ?? " Out of Bounds"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
        guard
            let cell =
                tableView.dequeueReusableCell(
                    withIdentifier: "searchCell",
                    for: indexPath
                ) as? APITableCell
        else {
            print("Casting failed")
            abort()
        }
        cell.descriptionLabel.text = searchViewModel?.getDescriptionLabel(section: indexPath.section, row: indexPath.row)
        cell.linkLabel.text = searchViewModel?.getLinkText(section: indexPath.section, row: indexPath.row)
        return cell
    }

//    func performApiQuery(searchTerm: String) {
//
//        
//    }

}

extension SearchView: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)  {
        apiSearchBar.resignFirstResponder()
        guard let input = apiSearchBar.text
        else {
            return
        }
        Task{
            await searchViewModel?.querySearch(userInput: input)
            apiTable.reloadData()
            userInputSearchLabel.text = "\"\(input)\""
        }
        
    }

}

extension SearchView: SearchViewDelegate, SFSafariViewControllerDelegate {
    func didSelectRow(at indexPath: IndexPath) {
        let result = searchViewModel?.getSearchResult(at: indexPath)
        if let url = URL(string: result?.firstURL ?? "") {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true, completion: nil)
            safariViewController.delegate = self
        }
        else {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            guard let vc = sb.instantiateViewController(withIdentifier: "SearchDetailsViewController") as? SearchDetailsViewController else {
                print("Could not instantitate view controller")
                abort()
            }
            vc.additionalDetails = result?.topics ?? []
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}

extension SearchView: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        didSelectRow(at: indexPath)
    }

}


