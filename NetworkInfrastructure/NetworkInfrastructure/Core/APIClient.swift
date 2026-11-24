//
//  APIClient.swift
//  NetworkInfrastructure
//
//  Created by Alonso on 11/3/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import Foundation

private struct NetworkingManager: Sendable {
    let session: URLSession

    func start(_ request: URLRequest, completion: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) {
        session.dataTask(with: request, completionHandler: completion).resume()
    }
}

protocol APIClient {

    var session: URLSession { get }

    func fetch<T: Decodable>(with request: URLRequest,
                             decode: @escaping (Decodable) -> T?, completion: @escaping (Result<T, APIError>) -> Void)

}

extension APIClient {

    typealias JSONTaskCompletionHandler = (Result<Decodable, APIError>) -> Void

    private func decodingTask<T: Decodable>(with request: URLRequest,
                                            decodingType _: T.Type,
                                            completion: @escaping JSONTaskCompletionHandler) {
        NetworkingManager(session: session).start(request) { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.requestFailed))
                return
            }
            guard 200..<300 ~= httpResponse.statusCode else {
                completion(.failure(APIError(response: httpResponse)))
                return
            }
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            do {
                let decoder = JSONDecoder()
                let genericModel = try decoder.decode(T.self, from: data)
                completion(.success(genericModel))
            } catch {
                completion(.failure(.requestFailed))
            }
        }
    }

    func fetch<T: Decodable>(with request: URLRequest,
                             decode: @escaping (Decodable) -> T?,
                             completion: @escaping (Result<T, APIError>) -> Void) {
        decodingTask(with: request, decodingType: T.self) { result in
            let deliver = {
                switch result {
                case .success(let json):
                    if let value = decode(json) {
                        completion(.success(value))
                    } else {
                        completion(.failure(.requestFailed))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }

            // The request owns one terminal delivery, even if its caller has gone away.
            if #available(iOS 13.0, *) {
                Task { @MainActor in deliver() }
            } else {
                // This framework still supports iOS 12, before Swift Concurrency.
                RunLoop.main.perform(inModes: [.common], block: deliver)
            }
        }
    }

}
