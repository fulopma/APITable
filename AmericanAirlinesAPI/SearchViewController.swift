//
//  ViewController.swift
//  AmericanAirlinesAPI
//
//  Created by Marcell Fulop on 4/28/25.
//

import Foundation
import UIKit

// I would fire the backend intern who designed this output
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

    @IBOutlet weak var APITable: UITableView!
    @IBOutlet weak var searchBarAPI: UISearchBar!
    @IBOutlet weak var userInputSearchLabel: UILabel!
    
    private var outputArray: Output = Output(relatedTopics: [], results: [])
    private var offset = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // called delegation pattern
        APITable.dataSource = self
        APITable.delegate = self
        userInputSearchLabel.text = ""
        searchBarAPI.placeholder = "Search on 🦆🦆▶️"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int {
        
        switch section {
        case 0:
            return outputArray.results.count
        case 1:
            var linkedRelatedTopicsCount = 0
            for topic in outputArray.relatedTopics {
                if let _ = topic.firstURL {
                    linkedRelatedTopicsCount += 1
                }
                else {
                    break
                }
            }
            offset = linkedRelatedTopicsCount
            print("There are \(offset) normal topics that have URLs.")
            return linkedRelatedTopicsCount
        default:
            var moreTopics = 0
            for topic in outputArray.relatedTopics {
                if let _ = topic.firstURL {
                    continue
                }
                moreTopics += 1
            }
            print("There are \(moreTopics) normal topics that don't have URLs.")
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
            return "Additional Topicss"
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
            cell.linkLabel.text = outputArray.results[indexPath.row].firstURL
            cell.descriptionLabel.text = outputArray.results[indexPath.row].text
            break
        case 1:
            var relatedText =
                outputArray.relatedTopics[indexPath.row].result ?? ""
            relatedText = relatedText.replacing(/<a[^>]+>/, with: "")
            relatedText = relatedText.replacing(/<.*/, with: "")
            cell.descriptionLabel.text = relatedText
            cell.linkLabel.text =
                outputArray.relatedTopics[indexPath.row].firstURL
            break
        default:
            let correctIndex = indexPath.row + offset
            guard let redirectText = outputArray.relatedTopics[correctIndex].name else {
                print("You messed up somewhere")
                abort()
            }
            cell.descriptionLabel.text = redirectText
            cell.linkLabel.text = nil
            cell.linkLabel.font = UIFont.systemFont(ofSize: 0)
            cell.linkLabel.constraints.forEach { $0.isActive = false }
        }
        print(cell.descriptionLabel.text ?? "No text")
        return cell
    }

    func performAPIQuery(searchTerm: String) {
        if searchTerm.isEmpty {
            return
        }
        let searchQuery = searchTerm.replacing(/\s+/, with: "+")
        guard
            let url = URL(
                string:
                    "https://api.duckduckgo.com/?q=\(searchQuery)&format=json"
            )
        else {
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        URLSession.shared.dataTask(with: urlRequest) {
            _data,
            response,
            error in
            guard let data = _data else {
                print("No data returned")
                abort()
            }
            let jsonDecoder = JSONDecoder()
            do {
                self.outputArray = try jsonDecoder.decode(
                    Output.self,
                    from: data
                )
                // This line below culls if related topics includes groups of links
                //  self.outputArray.relatedTopics = self.outputArray.relatedTopics.filter {$0.topics != nil}
            } catch {
                print("Error parsing JSON: \(error)")
                abort()
            }
            DispatchQueue.main.async {
                self.APITable.reloadData()
                self.userInputSearchLabel.text = "Results for \"\(searchTerm)\""
            }
        }.resume()
    }

}

extension SearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let input = searchBarAPI.text else {
            return
        }
        performAPIQuery(searchTerm: input)
    }

}

extension SearchViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        switch indexPath.section{
        case 0:
            break
        case 1:
            break
        default:
            let sb = UIStoryboard(name: "Main", bundle: nil)
            guard let vc = sb.instantiateViewController(withIdentifier: "SearchDetailsViewController")
                    as? SearchDetailsViewController else{
                return
            }
            vc.additionalDetails = Array( outputArray.relatedTopics[offset..<outputArray.relatedTopics.count])
            self.navigationController?.pushViewController(vc, animated: true)
            print("default")
            
        }
    }

}
