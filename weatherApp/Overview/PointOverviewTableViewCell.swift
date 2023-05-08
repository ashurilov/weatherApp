//
//  PointOverviewTableViewCell.swift
//  weatherApp
//
//  Created by Shamil Ashurilov on 07.05.2023.
//

import UIKit
import MapKit

final class PointOverviewTableViewCell: UITableViewCell {
    // MARK: - Properties
    static let reuseID = "PointOverviewCell"
    
    private var actualWeather: WeatherData? {
        didSet {
            changeWeatherInfo(weather: actualWeather)
        }
    }
    
    private var isSelectedCelc: Bool = true  {
        didSet {
            changeWeatherInfo(weather: actualWeather)
        }
    }
    
    private let networking: NetworkService = NetworkService()
    lazy private var networkDataFetcher: DataFetcher = NetworkDataFetcher(networkService: networking)
    
    private let coordinatesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.numberOfLines = 2
        return label
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 19)
        return label
    }()

    private let itemsForTemperatureSC = ["°C", "℉"]
    lazy private var temperatureSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: itemsForTemperatureSC)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(temperatureSegmentedValueChange(sender:)), for: .valueChanged)
        return segmentedControl
    }()
        
    // MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Funcs
    func setupInfoWith(annotation: MKPointAnnotation) {
        let coordinate = annotation.coordinate
        coordinatesLabel.text = "Lat: \(coordinate.latitude), Lon: \(coordinate.longitude)"
        setupLocation(annotation: annotation)
        fetchWeatherWithCoordinate(coordinate)
    }
    
    private func fetchWeatherWithCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let stringURL = "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&units=imperial&appid=c7beee20230706cca64a80fb42139d68"
        networkDataFetcher.fetchWeather(urlString: stringURL) { [weak self]  weather in
            self?.actualWeather = weather
        }
    }
    
    private func changeWeatherInfo(weather: WeatherData?) {
        guard let weather = weather else {
            self.temperatureLabel.text = "Температура не определена"
            self.temperatureSegmentedControl.alpha = 0
            return
        }
        
        switch isSelectedCelc {
        case true:
            let formattedValue = self.formatObjects(weather.tempToCelsius)
            self.temperatureLabel.text = "Температура: \(formattedValue) °C"
        case false:
            let formattedValue = self.formatObjects(weather.main.temp)
            self.temperatureLabel.text = "Температура: \(formattedValue) ℉"
        }
    }
    
    private func setupLocation(annotation: MKPointAnnotation) {
        if let pointAnnotation = annotation as? MKPointAnnotation {
            let location = CLLocation(latitude: pointAnnotation.coordinate.latitude, longitude: pointAnnotation.coordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
                if let placemark = placemarks?.first {
                    if let city = placemark.locality {
                        self?.cityLabel.text = "Местоположение: \(city)"
                    } else {
                        self?.cityLabel.text = "Местоположение: Не определено"
                    }
                }
            }
        }
    }
    
    private func setupUI() {
        [coordinatesLabel, cityLabel, temperatureLabel, temperatureSegmentedControl].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        NSLayoutConstraint.activate([
            coordinatesLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            coordinatesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            coordinatesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            coordinatesLabel.heightAnchor.constraint(equalToConstant: 20),
            
            cityLabel.topAnchor.constraint(equalTo: coordinatesLabel.bottomAnchor, constant: 5),
            cityLabel.leadingAnchor.constraint(equalTo: coordinatesLabel.leadingAnchor),
            cityLabel.trailingAnchor.constraint(equalTo: coordinatesLabel.trailingAnchor),
            cityLabel.heightAnchor.constraint(equalToConstant: 30),

            
            temperatureLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 5),
            temperatureLabel.leadingAnchor.constraint(equalTo: cityLabel.leadingAnchor),
            temperatureLabel.trailingAnchor.constraint(equalTo: cityLabel.trailingAnchor),
            temperatureLabel.heightAnchor.constraint(equalToConstant: 30),
            
            temperatureSegmentedControl.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor),
            temperatureSegmentedControl.leadingAnchor.constraint(equalTo: temperatureLabel.leadingAnchor),
            temperatureSegmentedControl.trailingAnchor.constraint(equalTo: temperatureLabel.trailingAnchor),
            temperatureSegmentedControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            temperatureSegmentedControl.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    private func formatObjects(_ double: Double) -> String {
        let roundedValue = round(double * 100) / 100
        let formattedValue = String(format: "%.0f", roundedValue)
        return formattedValue
    }
    
    //MARK: - Objc funcs
    @objc private func temperatureSegmentedValueChange(sender: UISegmentedControl) {
        guard let weather = actualWeather else { return }
        switch sender.selectedSegmentIndex {
        case 0:
            isSelectedCelc = true
        case 1:
            isSelectedCelc = false
        default: break
        }
    }
}
