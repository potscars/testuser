//
//  MockService.swift
//  TestUser
//
//  Created by owner on 07/07/2023.
//

import Foundation
import Combine

public class MockSuccessService: BaseService {
    
    public func request<T: Codable>(with urlString: String,
                           expecting: T.Type) -> AnyPublisher<T, NetworkError> {
        
        guard let path = Bundle.main.path(forResource: "users", ofType: "json") else {
            return Fail<T, NetworkError>(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return Just(path)
            .tryMap({ path in
                
                let url = URL(fileURLWithPath: path)
                
                print("MOCKED: - \(path)")

                guard let data = try? Data(contentsOf: url) else {
                    throw NetworkError.failedToDecode
                }
                return data
            })
            .receive(on: DispatchQueue.main)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                // return error if json decoding fails
                NetworkError.failedToDecode
            }
            .eraseToAnyPublisher()
    }
}
