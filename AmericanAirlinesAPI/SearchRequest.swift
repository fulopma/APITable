//
//  SearchRequest.swift
//  AmericanAirlinesAPI
//
//  Created by Marcell Fulop on 5/6/25.
//

import Foundation

// searchTerm.replacing(/\s+/, with: "+") + "&format=json"

struct SearchRequest: Request{
    var baseURL: String = "https://api.duckduckgo.com"
    var path: String = ""
    var httpMethod: HttpMethod = .get
    var params: [String: String]?
    var header: [String: String]? = nil
    
    static func createRequest(text: String)->SearchRequest {
        let param = ["q" : text, "format": "json"]
        return SearchRequest(params: param)
        
    }
}
