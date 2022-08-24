//
//  Forecast.swift
//  Forecast
//
//  Created by 1 on 2022/08/24.
//

import Foundation

struct Forecast: Codable {
    let cod: String
    let message: Int
    let cnt: Int
    
    struct ListItem: Codable {
        let dt: Int
        
        struct Main: Codable {
            let temp: Double
        }
        let main: Main
        
        struct Weather: Codable {
            let description: String
            let icon: String
            
        }
        let weather: [Weather]
    }
    let list: [ListItem]
}


struct ForecastData {
    let date: Date
    let icon: String
    let weather: String
    let temperature: Double
}
