//
//  SearchDetailsViewModel.swift
//  AmericanAirlinesAPI
//
//  Created by Marcell Fulop on 5/13/25.
//

import Foundation

class SearchDetailsViewModel{
    private var additionalDetails: [SearchResult] = []
    
    init(additionalDetails: [SearchResult]) {
        self.additionalDetails = additionalDetails
        if additionalDetails.count == 0 {
            print("Something went wrong. You sent an empty array.")
            abort()
        }
    }
    
    func getNumberOfRows() -> Int {
        return additionalDetails.count
    }
    
    func getText(for row: Int) -> String {
        var relatedText = additionalDetails[row].result ?? "no description"
        relatedText = relatedText.replacing(/<a[^>]+>/, with: "")
        relatedText = relatedText.replacing(/<.*/, with: "")
        return relatedText
    }
    
    func getLink(for row: Int) -> String {
        return additionalDetails[row].firstURL ?? "no link"
    }
    
}
