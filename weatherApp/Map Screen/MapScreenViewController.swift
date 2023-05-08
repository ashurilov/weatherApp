//
//  MapViewController.swift
//  weatherApp
//
//  Created by Shamil Ashurilov on 04.05.2023.
//

import UIKit
import MapKit
import CoreLocation


final class MapScreenViewController: UIViewController {
    
    // MARK: Properties
    lazy private var pointInfoView: NewPointInfoView = {
        let view = NewPointInfoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
            
    lazy private var mapView: MKMapView = {
       let map = MKMapView()
        map.delegate = self
        map.showsUserLocation = true
        map.isUserInteractionEnabled = true
        return map
    }()

    private lazy var poinInfoViewTopAnchor = pointInfoView.topAnchor.constraint(equalTo: view.bottomAnchor)
    
    private var isPointSelected = false
    
    private let locationManager = CLLocationManager()
    
    lazy private var righthBarButtonItem = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(rightBarButtonClicked))
        
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    // MARK: - Funcs
    private func setupUI() {
        view.backgroundColor = .white
        title = "Карта"

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addAnnotation(gesture:)))
          mapView.addGestureRecognizer(tapGesture)
        if let image = UIImage(named: "tap")?.withRenderingMode(.alwaysOriginal) {
            righthBarButtonItem.image = image
        }
        navigationItem.rightBarButtonItem = righthBarButtonItem
        [mapView, pointInfoView].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            pointInfoView.heightAnchor.constraint(equalToConstant: 200),
            pointInfoView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            pointInfoView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            poinInfoViewTopAnchor,
        ])
    }
    
    private func createNewPointInMap(point: MKPointAnnotation) {
        if !isPointSelected {
            addPoint(point: point)
        } else {
            removePoint()
        }
    }
    
    private func addPoint(point: MKPointAnnotation) {
        mapView.addAnnotation(point)
        let coordinate = point.coordinate
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 600, longitudinalMeters: 600)
        mapView.setRegion(region, animated: true)

        pointInfoView.setupInfoWith(annotation: point)
                    
        poinInfoViewTopAnchor.constant = -200
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.view.layoutIfNeeded()
        }
        isPointSelected = true
    }
    
    private func removePoint() {
        poinInfoViewTopAnchor.constant = 0
        isPointSelected = false
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    // MARK: Objc funcs
    @objc private func rightBarButtonClicked() {
        let overviewVC = OverviewViewController()
        overviewVC.delegate = self
        navigationController?.pushViewController(overviewVC, animated: true)
    }
    
    
    @objc private func addAnnotation(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        createNewPointInMap(point: annotation)
    }
}

// MARK: - CLLocationManager Delegate
extension MapScreenViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            manager.stopUpdatingLocation()
            render(location)
        }
    }

    private func render(_ location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: false)
    }
}


// MARK: - MKMapView Delegate
extension MapScreenViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "customPin")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "customPin")
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        annotationView?.image = UIImage(named: "pin")?.withRenderingMode(.alwaysOriginal)
        return annotationView
    }
}


// MARK: - MapScreenVC Delegate
extension MapScreenViewController: MapScreenDelegate {
    func send(point: MKPointAnnotation) {
        isPointSelected = false
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        createNewPointInMap(point: point)
    }
}
