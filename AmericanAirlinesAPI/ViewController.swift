//
//  ViewController.swift
//  AmericanAirlinesAPI
//
//  Created by Marcell Fulop on 4/28/25.
//

import Foundation
import UIKit

struct Result: Decodable {
    let RelatedTopics: [RelatedTopic]
}
struct RelatedTopic: Decodable {
    let FirstURL: String?
    let Text: String?
    let Name: String?
    let Topics: [RelatedTopic]?
}

class ViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var APITable: UITableView!
    @IBOutlet weak var searchTextField: UITextField!

    @IBOutlet weak var userInputSearchLabel: UILabel!

    
    var outputArray: [RelatedTopic] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        APITable.dataSource = self
        userInputSearchLabel.text = ""
        searchTextField.placeholder = "Search on Bing–I mean–Duckduckgo"
    }

    @IBAction func searchButtonPress(_ sender: Any) {
        Task { @MainActor in
            // fetch results
            await performAPIQuery(searchTerm: searchTextField.text ?? "")
            // put the results into the table
            APITable.reloadData()

        }
        userInputSearchLabel.text =
            "Results for \"\(searchTextField.text ?? "Input failed")\""
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return outputArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "searchCell",
                for: indexPath
            ) as? APITableCell
        cell?.cellLinkLabel.text = outputArray[indexPath.row].FirstURL
        cell?.cellResultLabel.text = outputArray[indexPath.row].Text
        return cell ?? UITableViewCell()
    }

    func performAPIQuery(searchTerm: String) async {
        let searchQuery = searchTerm.replacing(/\s+/, with: "+")
        let url = URL(
            string: "https://api.duckduckgo.com/?q=\(searchQuery)&format=json"
        )
        do {
            let (data, _) = try await URLSession.shared.data(
                from: url ?? URL(fileURLWithPath: "")
            )
            var results: Result = try JSONDecoder().decode(Result.self, from: data)
            outputArray.removeAll(keepingCapacity: true)
            for result in results.RelatedTopics {
                if let _ = result.FirstURL {
                    outputArray.append(result)
                }
                else{
                    // thumb through the subtopics
                    for subtopic in result.Topics ?? [] {
                        outputArray.append(subtopic)
                    }
                }
            }

        } catch {
            print("\(error)")
            abort()
        }

    }

}
