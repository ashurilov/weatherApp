//
//  PointInfoView.swift
//  weatherApp
//
//  Created by Shamil Ashurilov on 06.05.2023.
//

import UIKit
import MapKit

final class NewPointInfoView: UIView {
    // MARK: - Properties
    lazy var actualPoint = MKPointAnnotation() {
        didSet {
            infoTableView.reloadData()
        }
    }
    let infoTableView = UITableView(frame: .zero)
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Funcs
    func setupInfoWith(annotation: MKPointAnnotation) {
        actualPoint = annotation
    }
    
    private func setupUI() {
        backgroundColor = .white
        infoTableView.delegate = self
        infoTableView.dataSource = self
        infoTableView.isScrollEnabled = false
        infoTableView.register(PointOverviewTableViewCell.self, forCellReuseIdentifier: PointOverviewTableViewCell.reuseID)
        addSubview(infoTableView)
        infoTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoTableView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            infoTableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            infoTableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            infoTableView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension NewPointInfoView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PointOverviewTableViewCell.reuseID, for: indexPath) as? PointOverviewTableViewCell else { fatalError() }
        cell.setupInfoWith(annotation: actualPoint)
        cell.selectionStyle = .none
        return cell
    }
    
    
}
