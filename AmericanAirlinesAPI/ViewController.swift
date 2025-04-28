//
//  ViewController.swift
//  AmericanAirlinesAPI
//
//  Created by Marcell Fulop on 4/28/25.
//

import UIKit
import Foundation

struct Result: Decodable {
    let RelatedTopics: [RelatedTopic]
}
struct RelatedTopic: Decodable {
    let FirstURL: String?
    let Text: String?
}

class ViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var APITable: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    
    var results: Result? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        APITable.dataSource = self
    }

    @IBAction func searchButtonPress(_ sender: Any) {
        Task { @MainActor in
            // fetch results
            await performAPIQuery(searchTerm: searchTextField.text ?? "")
            // put the results into the table
            APITable.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int {
            return results?.RelatedTopics.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
        let cell =
        tableView.dequeueReusableCell(
            withIdentifier: "searchCell",
            for: indexPath
        ) as? APITableCell
        cell?.cellResultLabel.text = results?.RelatedTopics[indexPath.row].Text ?? "🤔 Result not found"
        cell?.cellLinkLabel?.text = results?.RelatedTopics[indexPath.row].FirstURL ?? "www.🙂‍↔️.com"
        return cell ?? UITableViewCell()
    }
    
    func performAPIQuery(searchTerm: String) async {
        let searchQuery = searchTerm.replacing(/\s+/, with: "+")
        let url = URL(string: "https://api.duckduckgo.com/?q=\(searchQuery)&format=json")
        do{
            let (data, _) = try await URLSession.shared.data(from: url ?? URL(fileURLWithPath: ""))
            results = try JSONDecoder().decode(Result.self, from: data)
//            for topic in results!.RelatedTopics {
//                print(topic.FirstURL ?? "No URL found")
//            }
            
        }
        catch {
            print("\(error)")
            abort()
        }
        
    }
    
    
}

