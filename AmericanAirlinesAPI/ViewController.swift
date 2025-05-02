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

class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var APITable: UITableView!
    @IBOutlet weak var searchBarAPI: UISearchBar!
    @IBOutlet weak var userInputSearchLabel: UILabel!
    
    var outputArray: Output = Output(relatedTopics: [], results: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // called delegation pattern
        APITable.dataSource = self
        APITable.delegate = self
        userInputSearchLabel.text = ""
        searchBarAPI.placeholder = "Search on Duckduckgo 🤫"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int {
        return section == 0 ? outputArray.results.count : outputArray.relatedTopics.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Results" : "Related Topics"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "searchCell",
                for: indexPath
            ) as? APITableCell else{
            print("Casting failed")
            abort()
        }
            if indexPath.section == 0 {
                cell.linkLabel.text = outputArray.results[indexPath.row].firstURL
                cell.descriptionLabel.text = outputArray.results[indexPath.row].text
            }
            
        return cell
    }
    

    func performAPIQuery(searchTerm: String) {
        if searchTerm.isEmpty {
            return
        }
        let searchQuery = searchTerm.replacing(/\s+/, with: "+")
        guard let url = URL(string: "https://api.duckduckgo.com/?q=\(searchQuery)&format=json")
        else{
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        URLSession.shared.dataTask(with: urlRequest) {
            _data, response, error in
            guard let data = _data else {
                print("No data returned")
                abort()
            }
            let jsonDecoder = JSONDecoder()
            do{
                self.outputArray = try jsonDecoder.decode(Output.self, from: data)
                // This line below culls if related topics includes groups of links
              //  self.outputArray.relatedTopics = self.outputArray.relatedTopics.filter {$0.topics != nil}
                print(self.outputArray.results)
            }
            catch {
                print("Error parsing JSON: \(error)")
                abort()
            }
            DispatchQueue.main.async {
                self.APITable.reloadData()
            }
        }.resume()
    }
    
}

extension ViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let input = searchBarAPI.text else {
            return
        }
        performAPIQuery(searchTerm: input)
    }
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Tap to Expand view
    }
    
}
