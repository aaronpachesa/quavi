//
//  MapViewController.swift
//  quavi
//
//  Created by Sunni Tang on 1/30/20.
//  Copyright © 2020 Sunni Tang. All rights reserved.
//

import UIKit
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

class MapViewController: UIViewController {
    // MARK: - Lazy UI Variables
    lazy var mapView: NavigationMapView = {
        // TODO: Refactor code, see what makes sense to go here
        let mapView = NavigationMapView(frame: view.bounds)
        mapView.styleURL = MGLStyle.darkStyleURL
        mapView.delegate = self
        mapView.setUserTrackingMode(.followWithCourse, animated: true, completionHandler: nil)
        mapView.tintColor = .yellow
        mapView.showsUserLocation = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return mapView
    }()
    
    // MARK: - Internal Properties
    var selectedRoute: Route?
    
    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        
        addSubviews()
        
        getSelectedRoute()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addConstraints()
        
    }
    
    func testSelectedRoute() {
        print("selectedRoute.routeOptions.waypoints:  \(selectedRoute!.routeOptions.waypoints)")
        print("selectedRoute.coordinates: \(selectedRoute!.coordinates)")
        print("selectedRoute.legs: \(selectedRoute!.legs)")
        print("selectedRoute.legs.first.distance: \(selectedRoute!.legs.first!.distance)")
    }


}
