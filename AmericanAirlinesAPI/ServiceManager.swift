//
//  ServiceManager.swift
//  AmericanAirlinesAPI
//
//  Created by Marcell Fulop on 5/5/25.
//

import Foundation

enum ServiceError: Error {
    case invalidURL
    case decodingFailed
    case fetchFailed
}

class ServiceManager {
    func callService<T: Decodable>(endpoint: String, modelName: T.Type, completion: @escaping (T?, ServiceError?) -> Void) {
        guard let url = URL(string: endpoint) else {
            completion(nil, ServiceError.invalidURL)
            return
        }
        let urlRequest = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in

            guard let data = data else {
                completion(nil, ServiceError.fetchFailed)
                return
            }

            do {

                let searchResponse = try JSONDecoder().decode(
                    modelName.self, from: data)

                completion(searchResponse, nil)
                print(searchResponse)

            } catch {
                completion(nil, ServiceError.decodingFailed)
            }
        }.resume()
    }
}
