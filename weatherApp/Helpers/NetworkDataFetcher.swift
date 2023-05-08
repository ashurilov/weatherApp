//
//  NetworkDataFetcher.swift
//  weatherApp
//
//  Created by Shamil Ashurilov on 06.05.2023.
//

import Foundation

protocol DataFetcher {
    func fetchWeather(urlString: String, completion: @escaping (WeatherData?) -> Void)
}

class NetworkDataFetcher: DataFetcher {
    var networkService: Networking
    
    init(networkService: Networking = NetworkService()) {
        self.networkService = networkService
    }
        
    // Декодируем полученные JSON данные в конкретную модель данных
    func fetchWeather(urlString: String, completion: @escaping (WeatherData?) -> Void ) {
        networkService.request(urlString: urlString) { data, error in
            let decoder = JSONDecoder()
            guard let data = data else { return }
            let response = try? decoder.decode(WeatherData.self, from: data)
            completion(response)
        }
    }
    
}
