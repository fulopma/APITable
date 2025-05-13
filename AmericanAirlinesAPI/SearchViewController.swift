//
//  ViewController.swift
//  AmericanAirlinesAPI
//
//  Created by Marcell Fulop on 4/28/25.
//

import Foundation
import UIKit


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

class SearchViewController: UIViewController, UITableViewDataSource {

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

extension SearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)  {
        apiSearchBar.resignFirstResponder()
        guard let input = apiSearchBar.text
        else {
            return
        }
        Task{
            await searchViewModel?.querySearch(userInput: input)
            apiTable.reloadData()
        }
    }

}

extension SearchViewController: SearchViewDelegate {
    func didSelectRow(at indexPath: IndexPath) {
        let output = searchViewModel?.getSearchOutput()
        switch indexPath.section {
           case 0:
               guard
                   let url = URL(
                    string: output?.results[indexPath.row].firstURL ?? ""
                   )
               else {
                   print(
                    "Failed to open \(output?.results[indexPath.row].firstURL ?? "no link")"
                   )
                   break
               }
               UIApplication.shared.open(url)
               break
           case 1:
               guard
                   let url = URL(
                    string: output?.relatedTopics[indexPath.row].firstURL
                           ?? ""
                   )
               else {
                   print(
                    "Failed to open \(output?.relatedTopics[indexPath.row].firstURL ?? "no link")"
                   )
                   break
               }
               UIApplication.shared.open(url)
               break
           default:
               let sb = UIStoryboard(name: "Main", bundle: nil)
               guard
                   let vc = sb.instantiateViewController(
                       withIdentifier: "SearchDetailsViewController"
                   )
                       as? SearchDetailsViewController
               else {
                   return
               }
               vc.additionalDetails =
            output?.relatedTopics.filter(({
                $0.firstURL == nil
            }))[indexPath.row].topics ?? []
               self.navigationController?.pushViewController(vc, animated: true)
           }
    }
    
    
}

extension SearchViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        // find indexPath.section
//
    }

}


