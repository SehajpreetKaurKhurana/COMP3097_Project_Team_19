//
//  MapVC.swift
//  COMP3097_Project_Team_19
//
//  Created by Graphic on 2022-04-19.
//

import UIKit
import GoogleMaps
import CoreLocation
import Alamofire //sending request
import SwiftyJSON //response from google is JSON fromat so will pass swiftyjson


class MapVC:UIViewController , CLLocationManagerDelegate{
    
    @IBOutlet var myMap: GMSMapView!
    var selectedAddress = " "
    
    @IBOutlet weak var label: UILabel!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationManager.delegate = self
        
        if(CLLocationManager.locationServicesEnabled()){
            locationManager.requestLocation()//will return lat and long
            
            // Block for the route
            
            let originLatitude = locationManager.location?.coordinate.latitude
            let originLongitude = locationManager.location?.coordinate.longitude
            
            
            
            var destinationLatitude : CLLocationDegrees = 0.0
            var destinationLongitude : CLLocationDegrees = 0.0
            var latitudeLongitude : JSON = ""
            
            //add input address instead of Dubai
            let urlPlaces =
             "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?fields=geometry&input=\(selectedAddress)&inputtype=textquery&locationbias=circle%3A2000%4047.6918452%2C-122.2226413&key=AIzaSyA-6W6CceBEHQGL2ttxW9Afm9AS_bTBMVQ"
            
            AF.request(urlPlaces).responseJSON{(AFResponse) in
                guard let JSONData = AFResponse.data else{
                    return
                }
               
                do{
                    //for fetching coordinates // from candidates to location to lat long
                    if let jMapData = try? JSON(data: JSONData){
                        for oCandidate in jMapData["candidates"].arrayValue{
                            for location in oCandidate {
                                for latlong in location.1{
                                    if(latlong.0.description == "location"){
                                        //place to fetch
                                        latitudeLongitude = latlong.1
                                        
                                        destinationLatitude = latitudeLongitude.dictionaryValue["lat"]?.doubleValue ?? 0.0
                                        destinationLongitude = latitudeLongitude.dictionaryValue["lng"]?.doubleValue ?? 0.0
                                        
                                        let marker = GMSMarker()
                                        marker.position = CLLocationCoordinate2D(latitude:destinationLatitude, longitude: destinationLongitude)
                                        
                                        marker.title = "Your destination"
                                        marker.snippet = "Restaurant Address"
                                        
                                        marker.map = self.myMap
                                        
                                        if(destinationLatitude != 0.0){
                                            let url = "https://maps.googleapis.com/maps/api/directions/json?origin=Toronto&destination=Brampton&mode=driving&key=AIzaSyA-6W6CceBEHQGL2ttxW9Afm9AS_bTBMVQ"
                                                    
                                            AF.request(url).responseJSON{(AFResponse) in
                                                guard let JSONData = AFResponse.data else{
                                                    return
                                                }
                                                
                                                do {
                                                    let jMapData = try JSON(data: JSONData)
                                                    //route in arrray
                                                    let ArrRoute = jMapData["routes"].arrayValue
                                                    print(ArrRoute)
                                                    
                                                    for route in ArrRoute {
                                                        let overView = route["overview_polyline"].dictionary
                                                        let points = overView?["points"]?.string
                                                        let paths = GMSPath.init(fromEncodedPath: points ?? "")
                                                        
                                                        let polyline = GMSPolyline(path: paths)
                                                        
                                                        polyline.strokeColor = .systemRed
                                                        
                                                        polyline.strokeWidth = 10.0
                                                        
                                                        polyline.map = self.myMap
                                                        
                                                        
                                                        
                                                
                                                        
                                    }
                                                    
                                                }
                                                catch let error {print (error.localizedDescription)}
                                                
                                                
                                            }
                                            
                                        }
                                        
                                        
                                        
                                        
                                        
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
            
            
        }else{
            locationManager.requestWhenInUseAuthorization()
        }
        
        
    }
    //for capturing user coordinates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        myMap.camera = GMSCameraPosition(
            target: CLLocationCoordinate2D(
                latitude: locationManager.location?.coordinate.latitude ?? 0.0,
                longitude: locationManager.location?.coordinate.longitude ?? 0.0),
            zoom: 8, bearing: 0, viewingAngle: 0.0)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.latitude ?? 0.0, longitude: locationManager.location?.coordinate.longitude ?? 0.0)
        
        marker.title = "Current Location"
        //marker.snippet = "U r here"
        
        marker.map = myMap
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            return
        case .authorizedWhenInUse:
            return
        case .denied:
            return
        case .restricted:
            locationManager.requestWhenInUseAuthorization()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    
}
