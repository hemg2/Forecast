//
//  ApiError.swift
//  Forecast
//
//  Created by 1 on 2022/08/24.
//

import Foundation

enum ApiError : Error {
    case unknown
    case invalidUrl(String)
    case invalidResponse
    case failed(Int)
    case emptyData
}
