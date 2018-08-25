//
//  MapViewController.swift
//  carpoolApp
//
//  Created by Corde Lopez on 8/25/18.
//  Copyright © 2018 Corde Lopez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    // map view variables
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    
    // location
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    // firebase
    var dbReference: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true);
        // Permiso para utilizar ubicacion
        locationManager.requestWhenInUseAuthorization()
        startMap()
    }

    // MARK: - Mapa
    // inicializa el mapa y lo demuestra al usuario. Al usuario le aparece su ubicacion actual y agarra sus coordenadas
    func startMap() {
        mapView.delegate = self
        
        if(CLLocationManager.locationServicesEnabled()) {
            // setup
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            // cases
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                print("Location access denied")
                break
                
            case .authorizedAlways, .authorizedWhenInUse:
                print("Location access allowed")
                
                // coordenadas del usuario
                if let sourceCoor = locationManager.location?.coordinate {
                    let sourcePlacemark = MKPlacemark(coordinate: sourceCoor)
                    let sourceItem = MKMapItem(placemark: sourcePlacemark)
                    print("User coordinates: ", sourceCoor)
                    
                    // view del mapa
                    latitude = (sourceCoor.latitude)
                    longitude = (sourceCoor.longitude)
                    // tamano de la ventana
                    let lanDelta: CLLocationDegrees = 0.05
                    let lonDelta: CLLocationDegrees = 0.05
                    let span = MKCoordinateSpan(latitudeDelta: lanDelta, longitudeDelta: lonDelta)
                    let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let region = MKCoordinateRegion(center: coordinates, span: span)
                    mapView.setRegion(region, animated: true)
                    
                    mapView.showsUserLocation = true
                    //uploadUserCoordinates()
                    
                }
                
                break
            }
            
        } else {
            print("Location services are not enabled")
            // avisa al usuario que no tiene activado la ubicacion
            let alertVC = UIAlertController(title: "Ubicación no activada", message: "No se tiene activada la ubicación", preferredStyle: .alert)
            
            let alertActionOkay = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alertVC.addAction(alertActionOkay)
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Firebase
    
    // funcion que sube la coordenadas del usuario a la base de datos si es la primera vez
    func uploadUserCoordinates() {
        print("Uploading user coordinates...")
        dbReference = Database.database().reference().child("Locations")
        
        // sube el objeto con su informacion, hace una key automatica
        let key = dbReference.childByAutoId().key
        let location = ["latitude": String(latitude), "longitude": String(longitude), "description": "test"]
        let childUpdates = ["/\(key)": location]
        dbReference.updateChildValues(childUpdates)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
