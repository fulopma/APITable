//
//  SearchViewModel.swift
//  AmericanAirlinesAPI
//
//  Created by Marcell Fulop on 5/13/25.
//

import Foundation

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

class SearchViewModel {
    private var searchApi: ServiceAPI = ServiceManager()
    private var results: [SearchResult] = []
    private var relatedTopics: [SearchResult] = []
    private var additionalTopics: [SearchResult] = []
    private var areThereResults = false
    private var areThereRelatedTopics = false
    private var areThereAdditionalTopics = false
    private var offset = 0
    weak var delegate : SearchViewDelegate?
    private var count = 0
    
    func getLinkText(section: Int, row: Int) -> String {
        switch section {
        case 0:
            if areThereResults {
                return results[row].firstURL ?? "No URL available"
            }
            else {
                return relatedTopics[row].firstURL ?? "No URL available"
            }
        case 1:
            if areThereResults {
                return relatedTopics[row].firstURL ?? "No URL"
            }
            if areThereAdditionalTopics {
                return ""
            }
            else {
                return "You messed up"
            }
        default:
            return "You Messed Up"
        }
    }
    
    func getDescriptionLabel(section: Int, row: Int) -> String {
        switch section {
        case 0:
            if areThereResults {
                return results[row].text ?? "No description available"
            }
            else {
                return relatedTopics[row].result?.replacing(/<a[^>]+>/, with: "").replacing(/<.+/, with: "") ?? "No result"
            }
        case 1:
            if areThereResults {
                return relatedTopics[row].result?.replacing(/<a[^>]+>/, with: "").replacing(/<.+/, with: "") ?? "No result"
            }
            else {
                return additionalTopics[row].name ?? "No text available"
            }
        default:
            return "You Messed Up"
            
        }
    }
    
    private func setBooleanMarkers() {
        if results.isEmpty {
            areThereResults = false
        }
        else {
            areThereResults = true
        }
        if relatedTopics.isEmpty {
            areThereRelatedTopics = false
        }
        else {
            areThereRelatedTopics = true
        }
        if additionalTopics.isEmpty {
            areThereAdditionalTopics = false
        }
        else {
            areThereAdditionalTopics = true
        }
    }
    
    func querySearch(userInput: String) async {
        let query = userInput.replacing(/\s+/, with: "+")

        guard let output = try? await searchApi.execute(request: SearchRequest.createRequest(text: query), modelName: Output.self) else {
            print("Nil ouput returned")
            abort()
        }
        results = output.results
        relatedTopics = output.relatedTopics.filter(({
            $0.firstURL != nil
        }))
        additionalTopics = output.relatedTopics.filter(({
            $0.firstURL == nil
        }))
        setBooleanMarkers()
    }
    
    func getNumberOfRowsInSection(section: Int) -> Int {
        return getSearchResults(fromCategory: section).count
    }
    
    func getSearchResults(fromCategory: Int) -> [SearchResult] {
        switch fromCategory {
        case 0:
            return areThereResults ? results : relatedTopics
        case 1:
            return areThereResults ? relatedTopics : additionalTopics
        default:
            return additionalTopics
        }
    }
    
    func setNumberOfSections() -> Int {
        var count = 0
        if !results.isEmpty {
            count += 1
        }
        if !relatedTopics.isEmpty {
            count += 1
        }
        if !additionalTopics.isEmpty {
            count += 1
        }
        if (count == 3){
            print("Something went wrong . . .")
            abort()
        }
        return count
    }
    
    func getSearchResult(at indexPath: IndexPath) -> SearchResult {
        switch indexPath.section {
        case 0:
            if areThereResults{
                return results[indexPath.row]
            }
            else {
                return relatedTopics[indexPath.row]
            }
        case 1:
            if areThereResults {
                return relatedTopics[indexPath.row]
            }
            else {
                return additionalTopics[indexPath.row]
            }
        default:
            return additionalTopics[indexPath.row]
        }
    }
    
    func getSectionTitle(forSection section: Int) -> String {
        switch section {
        case 0:
            if areThereResults {
                return "Results"
            }
            else {
                return "Related Topics"
            }
        case 1:
            if areThereResults {
                return "Related Topics"
            }
            else {
                return "Additional Topics"
            }
        default:
            return "Additional Topics"
        }
        
    }
    
}
