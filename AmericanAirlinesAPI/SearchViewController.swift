//
//  ViewController.swift
//  AmericanAirlinesAPI
//
//  Created by Marcell Fulop on 4/28/25.
//

import Foundation
import UIKit

struct SearchResult: Decodable {
    let firstURL: String?
    let result: String?
    let text: String?
    let name: String?
    let topics: [SearchResult]?
    enum CodingKeys: String, CodingKey {
        case firstURL = "FirstURL"
        case result = "Result"
        case text = "Text"
        case name = "Name"
        case topics = "Topics"
    }
}

struct Output: Decodable {
    var relatedTopics: [SearchResult]
    let results: [SearchResult]
    enum CodingKeys: String, CodingKey {
        case relatedTopics = "RelatedTopics"
        case results = "Results"
    }
}

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

class SearchViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var apiTable: UITableView!
    @IBOutlet weak var apiSearchBar: UISearchBar!
    @IBOutlet weak var userInputSearchLabel: UILabel!
    
    private var searchOutput: Output = Output(relatedTopics: [], results: [])
    private var offset = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // called delegation pattern
        apiTable.dataSource = self
        apiTable.delegate = self
        userInputSearchLabel.text = ""
        apiSearchBar.placeholder = "Search on 🦆🦆▶️"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if searchOutput.relatedTopics.isEmpty && searchOutput.results.isEmpty {
            return 0
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int {
        
        switch section {
        case 0:
            return searchOutput.results.count
        case 1:
            var linkedRelatedTopicsCount = 0
            for topic in searchOutput.relatedTopics {
                if let _ = topic.firstURL {
                    linkedRelatedTopicsCount += 1
                }
                else {
                    break
                }
            }
            offset = linkedRelatedTopicsCount
            return linkedRelatedTopicsCount
        default:
            var moreTopics = 0
            for topic in searchOutput.relatedTopics {
                if let _ = topic.firstURL {
                    continue
                }
                moreTopics += 1
            }
            return moreTopics
        }

    }

    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        switch section {
        case 0:
            return "Results"
        case 1:
            return "Related Topics"
        default:
            return "Additional Topics"
        }
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
        
        switch indexPath.section {

        case 0:
            cell.linkLabel.text = searchOutput.results[indexPath.row].firstURL
            cell.descriptionLabel.text = searchOutput.results[indexPath.row].text
            break
        case 1:
            var relatedText =
                searchOutput.relatedTopics[indexPath.row].result ?? ""
            relatedText = relatedText.replacing(/<a[^>]+>/, with: "")
            relatedText = relatedText.replacing(/<.*/, with: "")
            cell.descriptionLabel.text = relatedText
            cell.linkLabel.text =
                searchOutput.relatedTopics[indexPath.row].firstURL
            break
        default:
            let correctIndex = indexPath.row + offset
            guard let redirectText = searchOutput.relatedTopics[correctIndex].name else {
                print("You messed up somewhere")
                abort()
            }
            cell.descriptionLabel.text = redirectText
            cell.linkLabel.text = ""
        }
        return cell
    }

    func performApiQuery(searchTerm: String) {
        if searchTerm.isEmpty {
            return
        }
        let endpoint = "https://api.duckduckgo.com/?q=" + searchTerm.replacing(/\s+/, with: "+") + "&format=json"
        ServiceManager().callService(endpoint: endpoint, modelName: Output.self) {output, error in
            if let error = error {
                print("Error: \(error)")
                abort()
            }
            self.searchOutput = output ?? Output(relatedTopics: [], results: [])
            DispatchQueue.main.async {
                self.apiTable.reloadData()
                self.userInputSearchLabel.text = "Results for \"\(searchTerm)\""
            }
        }
    }

}

extension SearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let input = apiSearchBar.text else {
            return
        }
        performApiQuery(searchTerm: input)
    }

}

extension SearchViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        switch indexPath.section {
        case 0:
            guard let url = URL(string: searchOutput.results[indexPath.row].firstURL ?? "") else {
                print("Failed to open \(searchOutput.results[indexPath.row].firstURL ?? "no link")")
                break
            }
            UIApplication.shared.open(url)
            break
        case 1:
            guard let url = URL(string: searchOutput.relatedTopics[indexPath.row].firstURL ?? "") else {
                print("Failed to open \(searchOutput.relatedTopics[indexPath.row].firstURL ?? "no link")")
                break
            }
            UIApplication.shared.open(url)
            break
        default:
            let sb = UIStoryboard(name: "Main", bundle: nil)
            guard let vc = sb.instantiateViewController(withIdentifier: "SearchDetailsViewController")
                    as? SearchDetailsViewController else{
                return
            }
            vc.additionalDetails =  searchOutput.relatedTopics[offset + indexPath.row].topics ?? []
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
