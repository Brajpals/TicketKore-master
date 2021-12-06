//
//  Location.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 26/04/21.
//

import Foundation
import CoreLocation
import MapKit
import Alamofire
import SwiftyJSON



protocol GPSLocationDelegate: class {
    func fetchedLocationDetails(location: CLLocation, countryCode: String, city: String, street: String , intersection:String , county:String)
    func failedFetchingLocationDetails(error: Error)
 }

class GPSLocation: UIViewController,CLLocationManagerDelegate {
 
    weak var delegate: GPSLocationDelegate?
    var locManager = CLLocationManager()
    var locationModel : Address?
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    getGPSLocation()
                }
            }
        }
    }
    
    
    func fetchCountryAndCity(location: CLLocation, completion: @escaping (String, String, String, String, String) -> (), errorHandler: @escaping (Error) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            var street = ""
            var blk = ""
            if let error = error {
                debugPrint(error)
                errorHandler(error)
            } else if let countryCode = placemarks?.first?.isoCountryCode,
                      let city = placemarks?.first?.locality,
                      let subAdministrativeArea = placemarks?.first?.subAdministrativeArea{
                //print(placemarks?.first?.subLocality)
                if placemarks?.first?.thoroughfare != nil{
                    street = (placemarks?.first?.thoroughfare)!
                }
                if street == ""{
                    if placemarks?.first?.subLocality != nil{
                    street = (placemarks?.first?.subLocality)!
                    }
                }
                
                if placemarks?.first?.subThoroughfare != nil{
                    blk = (placemarks?.first?.subThoroughfare)!
                }
                completion(countryCode, city, street, blk, subAdministrativeArea)
            }
        }
    }
    
    
    
    public func getGPSLocation() {
        
        var currentLocation: CLLocation!
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
            
            currentLocation = locManager.location
            if currentLocation != nil{
                let latitude = String(format: "%.7f", currentLocation.coordinate.latitude)
                let longitude = String(format: "%.7f", currentLocation.coordinate.longitude)
                let location = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
                
//                fetchCountryAndCity(location: location, completion: { [self] countryCode, city, street ,blk, county  in
//                    delegate?.fetchedLocationDetails(location: location, countryCode: countryCode, city: city, street: street, blk: blk, county: county)
//                }) { [self] in delegate?.failedFetchingLocationDetails(error: $0)
//                }
                
                let url = "https://geocode-api.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?f=json&featureTypes=StreetInt&locationType=street&token=AAPK52f779365f014640aebc9782ca67ecf90HcqmuUuKRRGi02MVHTgfoZQpIoJKZovMq4J_yov7-bHM8KArWw3dOMuoFgQB15B&location=\(longitude),\(latitude)"
                
                updateEditedRipa(url: URL(string: url)!, location: location, completion: { [self] countryCode, city, street ,intersection, county  in
                    delegate?.fetchedLocationDetails(location: location, countryCode: countryCode, city: city, street: street, intersection: intersection, county: county)
                }) { [self] in delegate?.failedFetchingLocationDetails(error: $0)
                }
                
                debugPrint("Latitude:", latitude)
                debugPrint("Longitude:", longitude)
            }
            else{
//                let location = CLLocation(latitude: 37.3230, longitude: -122.0322)
//                fetchCountryAndCity(location: location, completion: { [self] countryCode, city, street, blk, county in
//                    delegate?.fetchedLocationDetails(location: location, countryCode: countryCode, city: city,  street: street, blk: blk, county: county)
//                }) { [self] in delegate?.failedFetchingLocationDetails(error: $0)
//                }
            }
        }
        else{
 
            self.locManager.delegate = self
            // locManager.requestAlwaysAuthorization()
            self.locManager.requestWhenInUseAuthorization()
            
            if  (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied){
                GPSLocation.showLocationEnableAlert()
             }
            
         }
    }
    
    
    
    class func showLocationEnableAlert(){
         let alertController = UIAlertController (title: "Enable Location Service", message: "Allow location permission for app to get current location of the place where RIPA was done. Go to settings and enable location?", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async{
            UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
        }
        
 
    }
    
    
    
    func updateEditedRipa(url:URL,location: CLLocation, completion: @escaping (String, String, String, String, String) -> (), errorHandler: @escaping (Error) -> ()){
        AppUtility.showProgress(nil, title: nil)
       // let headers = ["Content-Type" : "application/json"] as [String : String]
        
        Alamofire.request(url, method: .get , encoding: JSONEncoding.default).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                 if let responseValue = response.result.value {
                    //  let jsonString = String(data: response.data!, encoding: .utf8)!
                    
                    let json = JSON(responseValue)
                    
                    // let result = json["address"]["Match_addr"].stringValue
                     
                     let address = Address(matchAddr: json["address"]["Match_addr"].stringValue, longLabel: json["address"]["LongLabel"].stringValue, shortLabel: json["address"]["ShortLabel"].stringValue, addrType: json["address"]["Addr_type"].stringValue, type: json["address"]["Type"].stringValue, placeName: json["address"]["PlaceName"].stringValue, addNum: json["address"]["AddNum"].stringValue, address: json["address"]["Address"].stringValue, block: json["address"]["Block"].stringValue, sector: json["address"]["Sector"].stringValue, neighborhood: json["address"]["Neighborhood"].stringValue, district: json["address"]["District"].stringValue, city: json["address"]["City"].stringValue, metroArea: json["address"]["MetroArea"].stringValue, subregion: json["address"]["Subregion"].stringValue, region: json["address"]["Region"].stringValue, territory: json["address"]["Territory"].stringValue, postal: json["address"]["Postal"].stringValue, postalEXT: json["address"]["PostalExt"].stringValue, countryCode: json["address"]["CountryCode"].stringValue)
                     
                  
                     let fullName = address.address
                     let fullNameArr = fullName.components(separatedBy: " & ")

                     let intersection = fullNameArr[0]
                     var street : String = ""
                     if fullName.count > 0 {
                         street = fullNameArr[1]
                     }
                     
                     address.subregion = address.subregion.replacingOccurrences(of: " County", with: "", options: NSString.CompareOptions.literal, range: nil)
                     
                     completion(address.address, address.city, street, intersection, address.subregion)
                     AppUtility.hideProgress()
                 } else {
                   // completion("Something Went Wrong", "Fail")
                     AppUtility.hideProgress()
                }
                break
             case .failure(let error):
//                failure(error,response.response?.statusCode,ApiManager.getErrorMessage(response: response, false))
                 AppUtility.showAlertWithProperty("Alert", messageString: "Unable to get current location")
                 AppUtility.hideProgress()
//                completion("", "Fail")
            }
        }
    }
    
    
    
    
}
