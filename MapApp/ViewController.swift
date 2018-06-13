//
//  ViewController.swift
//  MapApp
//
//  Created by TakahashiNobuhiro on 2018/06/13.
//  Copyright © 2018 feb19. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var trackingButton: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    var annotations = Array<MKPointAnnotation>()
    
    let locTokyo    = CLLocationCoordinate2D(latitude: 35.690553, longitude: 139.699579)
    let locYokohama = CLLocationCoordinate2D(latitude: 35.531365, longitude: 139.696889)
    let locKawasaki = CLLocationCoordinate2D(latitude: 35.454954, longitude: 139.6313859)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        mapView.mapType = .standard
        mapView.showsScale = true
        mapView.camera.pitch = 0.0
        mapView.delegate = self
        toolbar.tintColor = UIColor.black
        toolbar.alpha = 0.8
        
        // add annotation
        let coord = CLLocationCoordinate2D(latitude: 35.34362, longitude: 131.3243)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coord
        annotation.title = "hige"
        mapView.addAnnotation(annotation)
        annotations.append(annotation)
        
        // draw
        let locs = [locTokyo, locKawasaki, locYokohama]
        for loc in locs {
            let circle = MKCircle(center: loc, radius: 300)
            mapView.add(circle)
        }
        let line = MKPolyline(coordinates: locs, count: locs.count)
        mapView.add(line)
        
        // 地球の球面に合わせて線を引く
        // MKGeodesicPolyline
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func toolBarButtonWasTapped(_ sender: Any) {
        let lat = 35.4454545
        let lon = 139.43124
        let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
        
        
    }
    
    @IBAction func trackingButtonWasTapped(_ sender: Any) {
        switch mapView.userTrackingMode {
        case .none:
            mapView.setUserTrackingMode(.follow, animated: true)
            trackingButton.title = "トラッキング"
        case .follow:
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
            trackingButton.title = "トラッキングHead"
        case .followWithHeading:
            mapView.setUserTrackingMode(.none, animated: true)
            trackingButton.title = "停止"
            
        }
        
        print("\(mapView.userTrackingMode.hashValue)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            trackingButton.isEnabled = true
        default:
            locationManager.stopUpdatingLocation()
            mapView.setUserTrackingMode(.none, animated: true)
            trackingButton.isEnabled = false
            trackingButton.title = "停止"
        }
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        trackingButton.title = "停止"
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinView = MKPinAnnotationView()
        pinView.animatesDrop = true
        pinView.isDraggable = true
        pinView.canShowCallout = true
        pinView.pinTintColor = UIColor.blue
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer: MKOverlayPathRenderer
        switch overlay {
        case is MKPolyline:
            renderer = MKPolylineRenderer(overlay: overlay)
            renderer.lineWidth = 2
            renderer.strokeColor = UIColor.blue
        case is MKCircle:
            renderer = MKCircleRenderer(overlay: overlay as! MKCircle)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 2
            renderer.fillColor = UIColor.blue
            renderer.alpha = 0.2
        default:
            renderer = MKPolylineRenderer(overlay: overlay)
        }
        return renderer
    }
    
    @IBAction func removeAnnotationButtonWasTapped(_ sender: UIButton) {
        if annotations.count > 0 {
            let lastPin = annotations.removeLast()
            mapView.removeAnnotation(lastPin)
        }
    }
    
    @IBAction func mapViewWasLongPressed(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == UIGestureRecognizerState.ended else {
            return
        }
        let point = sender.location(in: mapView)
        let coord = mapView.convert(point, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coord
        annotation.title = "tit"
        mapView.addAnnotation(annotation)

        annotations.append(annotation)
    }
}

