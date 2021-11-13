
import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    let mapView : MKMapView = {
        let mapview = MKMapView()
        mapview.translatesAutoresizingMaskIntoConstraints = false
        return mapview
    }()
    
    let addAdressButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Add"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let routeButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "route"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    let resetButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "reset-button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    var annotationsArray = [MKPointAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        setConstrains()
        
        addAdressButton.addTarget(self, action: #selector(addAdressButtonTapped), for: .touchUpInside)
        routeButton.addTarget(self, action: #selector(routeButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
    }
    
    @objc func addAdressButtonTapped() {
        alertAddAdress(title: "Добавить", placeholder: "Введите адресс") { [self] (text) in
            setupPlacemark(adressPlase: text)
        }
    }
    
    @objc func routeButtonTapped() {
        
        for index in 0...annotationsArray.count - 2 {
            createDirectionRequest(startCoordinate: annotationsArray[index].coordinate, destinationCoordinate: annotationsArray[index + 1].coordinate)
        }
        
        mapView.showAnnotations(annotationsArray, animated: true)
    }
    
    @objc func resetButtonTapped() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        annotationsArray = [MKPointAnnotation]()
        routeButton.isHidden = true
        resetButton.isHidden = true
    }
    
    private func setupPlacemark(adressPlase: String) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(adressPlase) { [self] (placemarks, error) in
            
            if let error = error {
                print(error);
                allertError(title: "Ошибка", message: "Сервер недоступен. Попробуйте добавить адресс еще раз")
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = "\(adressPlase)"
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            annotationsArray.append(annotation)
            
            if annotationsArray.count > 2 {
                routeButton.isHidden = false
                resetButton.isHidden = false

            }
            
            mapView.showAnnotations(annotationsArray, animated: true)
        }
    }
    
    private func createDirectionRequest(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        let diraction = MKDirections(request: request)
        diraction.calculate { (responce, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let responce = responce else {
                self.allertError(title: "Ошибка", message: "Маршрут недоступен")
                return
            }
            
            var minRoute = responce.routes[0]
            for route in responce.routes{
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
            
            self.mapView.addOverlay(minRoute.polyline)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .red
        return renderer
    }
}

extension ViewController {
    func setConstrains() {
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        
        mapView.addSubview(addAdressButton)
        NSLayoutConstraint.activate([
            addAdressButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant : 50),
            addAdressButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant : -20),
            addAdressButton.heightAnchor.constraint(equalToConstant: 70),
            addAdressButton.widthAnchor.constraint(equalToConstant: 70)
        
        ])
        
        mapView.addSubview(resetButton)
        NSLayoutConstraint.activate([
            resetButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant : 20),
            resetButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant : -30),
            resetButton.heightAnchor.constraint(equalToConstant: 100),
            resetButton.widthAnchor.constraint(equalToConstant: 100)
        
        ])
        
        mapView.addSubview(routeButton)
        NSLayoutConstraint.activate([
            routeButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant : -25),
            routeButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant : -35),
            routeButton.heightAnchor.constraint(equalToConstant: 90),
            routeButton.widthAnchor.constraint(equalToConstant: 90)
        
        ])
    }
    
}
