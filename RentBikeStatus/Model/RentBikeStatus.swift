//
//  RentBikeStatus.swift
//  RentBikeStatus
//
//  Created by mobile on 2023/02/06.
//

import Foundation

// MARK: - RentBikeStatus
struct RentBikeStatus: Codable {
    let rentBikeStatus: RentBikeStatusClass
}

// MARK: - RentBikeStatusClass
struct RentBikeStatusClass: Codable {
    let listTotalCount: Int
    let result: Result
    let row: [Row]

    enum CodingKeys: String, CodingKey {
        case listTotalCount = "list_total_count"
        case result = "RESULT"
        case row
    }
}

// MARK: - Result
struct Result: Codable {
    let code, message: String

    enum CodingKeys: String, CodingKey {
        case code = "CODE"
        case message = "MESSAGE"
    }
}

// MARK: - Row
struct Row: Codable {
    let rackTotCnt, stationName, parkingBikeTotCnt, shared: String
    let stationLatitude, stationLongitude, stationID: String

    enum CodingKeys: String, CodingKey {
        case rackTotCnt, stationName, parkingBikeTotCnt, shared, stationLatitude, stationLongitude
        case stationID = "stationId"
    }
}
