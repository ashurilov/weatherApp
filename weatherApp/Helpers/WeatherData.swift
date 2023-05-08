//
//  WeatherData.swift
//  weatherApp
//
//  Created by Shamil Ashurilov on 04.05.2023.
//

import Foundation

// MARK: - WeatherData
struct WeatherData: Codable {
    let main: Main
}

struct Main: Codable {
    let temp: Double
}

extension WeatherData {
    var tempToCelsius: Double {
        (self.main.temp - 32) * (5 / 9)
    }
}
