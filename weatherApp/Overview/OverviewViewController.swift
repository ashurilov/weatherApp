//
//  ViewController.swift
//  weatherApp
//
//  Created by Shamil Ashurilov on 04.05.2023.
//

import UIKit
import MapKit

// MARK: - MapScreenDelegate
protocol MapScreenDelegate: AnyObject {
    func send(point: MKPointAnnotation)
}


final class OverviewViewController: UIViewController {

    // MARK: Properties
    weak var delegate : MapScreenDelegate?
    private var weatherTableView = UITableView(frame: .zero)
    private var points = [MKPointAnnotation]()
    
    private let networking: NetworkService = NetworkService()
    lazy private var networkDataFetcher: DataFetcher = NetworkDataFetcher(networkService: networking)
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        weatherTableView.register(PointOverviewTableViewCell.self, forCellReuseIdentifier: PointOverviewTableViewCell.reuseID)
        weatherTableView.dataSource = self
        weatherTableView.delegate = self
    }
    
    // MARK: Funcs
    private func setupUI() {
        view.backgroundColor = .white
        for _ in 0..<5 { points.append(RandomPointFactory.createRandomPoint() ) }
        
        title = "Здесь могла бы быть ваша реклама"        
        weatherTableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(weatherTableView)
        NSLayoutConstraint.activate([
            weatherTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            weatherTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            weatherTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            weatherTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}


// MARK: - UITableViewDelegate & UITableViewDataSourse
extension OverviewViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        points.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PointOverviewTableViewCell.reuseID, for: indexPath) as? PointOverviewTableViewCell else { fatalError() }
        let point = points[indexPath.row]
        cell.setupInfoWith(annotation: point)
        cell.selectionStyle = .default
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let point = points[indexPath.row]
        delegate?.send(point: point)
        navigationController?.popViewController(animated: true)
    }
}
