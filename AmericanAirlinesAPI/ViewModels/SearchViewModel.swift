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
    private var searchOutput: Output = Output(relatedTopics: [], results: [])
    private var offset = 0
    weak var delegate : SearchViewDelegate?
    private var count = 0
    
    func getLinkText(section: Int, row: Int) -> String {
        switch section {
        case 0:
            if !searchOutput.results.isEmpty {
                return searchOutput.results[row].firstURL ?? "What?"
            }
            else{
                return searchOutput.relatedTopics[row].firstURL ?? "What?"
            }
        case 1:
            if !searchOutput.relatedTopics.filter(({
                $0.firstURL != nil
            })).isEmpty {
                return searchOutput.relatedTopics[row].firstURL ?? "What?"
            }
        default:
            return ""
        }
        return ""
    }
    
    func getDescriptionLabel(section: Int, row: Int) -> String {
        switch section {
        case 0:
            if !searchOutput.results.isEmpty {
                return searchOutput.results[row].text ?? "What?"
            }
            else {
                var text = searchOutput.relatedTopics[row].text ?? "What?"
                text = text.replacing(/<a[^>]+>/, with: "")
                text = text.replacing(/<.*/, with: "")
                return text
            }
           
        case 1:
            if !searchOutput.relatedTopics.filter(({
                $0.firstURL != nil
            })).isEmpty {
                var text = searchOutput.relatedTopics[row].text ?? "What?"
                text = text.replacing(/<a[^>]+>/, with: "")
                text = text.replacing(/<.*/, with: "")
                return text
            }
            else {
                return searchOutput.relatedTopics.filter({
                    $0.name != nil
                })[row].name ?? "No name"
            }
        default:
            return "Should not reach here"
        }
    }
    
    func querySearch(userInput: String) async {
        let query = userInput.replacing(/\s+/, with: "+")

        guard let output = try? await searchApi.execute(request: SearchRequest.createRequest(text: query), modelName: Output.self) else {
            print("Nil ouput returned")
            abort()
        }
        searchOutput = output
        
    }
    
    func getSearchOutput() -> Output {
        return searchOutput
    }
    
    func getNumberOfRowsInSection(section: Int) -> Int {
        return getSearchResults(fromCategory: section).count
    }
    
    func getSearchResults(fromCategory: Int) -> [SearchResult] {
        switch fromCategory {
        case 0:
            return !searchOutput.results.isEmpty ? searchOutput.results : searchOutput.relatedTopics.filter(({
                $0.firstURL != nil
            }))
        case 1:
            return !searchOutput.results.isEmpty ? searchOutput.relatedTopics.filter(({
                $0.firstURL != nil
            })) : searchOutput.relatedTopics.filter(({
                $0.firstURL == nil
            }))
        default:
            return searchOutput.relatedTopics
        }
    }
    
    func setNumberOfSections() -> Int {
        var count = 0
        if !(searchOutput.results.isEmpty) {
            count += 1
        }
        if !(searchOutput.relatedTopics.filter(({
            $0.firstURL != nil
        })).isEmpty){
            count += 1
        }
        if !(searchOutput.relatedTopics.filter(({
            $0.firstURL == nil
        })).isEmpty){
            count += 1
        }
        self.count = count
        return count
    }
    
    func getSectionTitle(forSection section: Int) -> String {
        if count == 0 {
            abort()
        }
        if count == 1 {
            if searchOutput.results.isEmpty {
                if searchOutput.relatedTopics.filter(({$0.firstURL != nil })).isEmpty {
                    return "Additional Topics"
                }
                else {
                    return "Related Topics"
                }
            }
            else {
                return "Results"
            }
        }
        else if count == 2 {
            if section == 0 {
                if searchOutput.results.isEmpty {
                    return "Related Topics"
                }
                else {
                    return "Results"
                }
            }
            else {
                if searchOutput.relatedTopics.filter(({
                    $0.firstURL != nil
                })).isEmpty {
                    return "Related Topics"
                }
                else {
                    return "Additional Topics"
                }
            }
        }
        abort()
    }
    
}
