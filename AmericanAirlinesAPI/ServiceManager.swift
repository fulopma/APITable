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

enum HttpMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

protocol Request {
    var baseURL: String {get set}
    var path: String {get set}
    var httpMethod: HttpMethod {get set}
    var params: [String: String]? {get set}
    var header: [String: String]? {get set}
}
extension Request {
    func createRequest() -> URLRequest? {
        var urlComponents = URLComponents(string: baseURL + path)
        urlComponents?.queryItems = params?.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        guard let url = urlComponents?.url else {
            
            return nil
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = header
        return urlRequest
    }
}

protocol ServiceAPI {
    func callService<T: Decodable>(endpoint: String, modelName: T.Type, completion: @escaping (Result<T, ServiceError>) -> Void)
    func execute<T: Decodable>(request: Request, modelName: T.Type, completion: @escaping (Result<T, ServiceError>) -> Void)
}

class ServiceManager: ServiceAPI{
    func execute<T: Decodable>(request: Request, modelName: T.Type, completion: @escaping (Result<T, ServiceError>) -> Void) {
        guard let urlRequest = request.createRequest() else {
            return completion(.failure(.invalidURL))
        }
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data else {
                completion(.failure(.fetchFailed))
                return
            }
            do {
                let searchResponse = try JSONDecoder().decode(
                    modelName.self, from: data)

                completion(.success(searchResponse))
            } catch {
                completion(.failure(.decodingFailed))
            }
            
        }.resume()
        
    }
    
    func callService<T: Decodable>(endpoint: String, modelName: T.Type, completion: @escaping (Result<T, ServiceError>) -> Void) {
        guard let url = URL(string: endpoint) else {
            completion(.failure(.invalidURL))
            return
        }
        let urlRequest = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data else {
                completion(.failure(.fetchFailed))
                return
            }
            do {
                let searchResponse = try JSONDecoder().decode(
                    modelName.self, from: data)

                completion(.success(searchResponse))
            } catch {
                completion(.failure(.decodingFailed))
            }
        }.resume()
    }
}
