//
//  NetworkError.swift
//  RentBikeStatus
//
//  Created by mobile on 2023/02/06.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidJSON
    case networkError
    
    var message: String {
        switch self {
        case .invalidURL, .invalidJSON:
            return "데이터를 불러올 수 없습니다."
        case .networkError:
            return "네트워크 상태를 확인해주세요."
        }
    }
}
