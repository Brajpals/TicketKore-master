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



protocol GPSLocationDelegate: AnyObject {
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
        
        let authorizationStatus: CLAuthorizationStatus

        if #available(iOS 14, *) {
            authorizationStatus = locManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        

        self.checkLocationManagerAuthorization()
        
        if (authorizationStatus == CLAuthorizationStatus.authorizedWhenInUse || authorizationStatus == CLAuthorizationStatus.authorizedAlways) {
            
            currentLocation = locManager.location
            if currentLocation != nil{
                
                let latflt =  Float(String(currentLocation.coordinate.latitude))
                let longflt =  Float(String(currentLocation.coordinate.longitude))
                AppConstants.lati = String(format: "%.3f", latflt!)
                AppConstants.longi = String(format: "%.3f", longflt!)
                 UserDefaults.standard.set(String(format: "%.3f", latflt!), forKey: "latitude")
                 UserDefaults.standard.set(String(format: "%.3f", longflt!), forKey: "longitude")
               
                
                let latitude = String(format: "%.7f", currentLocation.coordinate.latitude)
                let longitude = String(format: "%.7f", currentLocation.coordinate.longitude)
                let location = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
                
                
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
            
            let authorizationStatus: CLAuthorizationStatus

            if #available(iOS 14, *) {
                authorizationStatus = self.locManager.authorizationStatus
            } else {
                authorizationStatus = CLLocationManager.authorizationStatus()
            }
            
             if  (authorizationStatus == CLAuthorizationStatus.denied){
                GPSLocation.showLocationEnableAlert()
                self.updateLocationStatus(status: "false")
             }
         }
    }
    
    private func checkLocationManagerAuthorization() {
          let authorizationStatus: CLAuthorizationStatus
          authorizationStatus = locManager.authorizationStatus
          switch authorizationStatus{
              case .notDetermined:
                  print("::: -> Location: notDetermined")
                 
              case .authorizedAlways, .authorizedWhenInUse:
                  print("::: -> Location: authorizedWhenInUse")
                 self.updateLocationStatus(status: "true")
                 
              case .denied, .restricted:
                  print("::: -> Location: denied")
              default:
                  break
          }
      }
  
    func updateLocationStatus(status : String) {
        var userId : String = ""
        if let uId = AppManager.getLastSavedLoginDetails()?.result?.userid{
            userId = uId
        }
        var custId : String = ""
        if let idUser = AppManager.getLastSavedLoginDetails()?.result?.custid{
            custId = idUser
        }
        
        if AppConstants.deviceToken.count == 0 {
            AppConstants.deviceToken = "ios"
        }
       
        let param:[String : Any] = ["custId": custId,"userId":userId, "deviceId" : AppConstants.deviceToken ,"platform" : "ios", "locStatus" : status]
        let params:[String : Any] = ["id": "82F85DB43CBF6", "method":"ripaLocationTrack", "params":param,"jsonrpc": "2.0"]
        updateLocationStatusType(params: params)
    }
    
    
    func updateLocationStatusType(params: [String:Any]) {
        var URL:String?
        print(params)
        URL = AppConstants.Api.updateVersion
        
        ApiManager.updateLocationStatus(params: params, methodTyPe: .post, url: URL!, completion: {  (success) in
            // AppUtility.hideProgress(nil)
            if success == true{
               
              print("Update Location Status Successfully.")
            }
            else {
                print("Update Location Status Failed.")
            }
        })
        
        { (error, code, message) in
            AppUtility.hideProgress(nil)
            if let errorMessage = message {
                print(errorMessage)
                //  AppUtility.showAlertWithProperty("Alert", messageString: errorMessage)
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
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 60
        manager.request(url, method: .get , encoding: JSONEncoding.default).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                 if let responseValue = response.result.value {
                    //  let jsonString = String(data: response.data!, encoding: .utf8)!
                    
                    let json = JSON(responseValue)
                    print(json)
                    // let result = json["address"]["Match_addr"].stringValue
                     
                     let address = Address(matchAddr: json["address"]["Match_addr"].stringValue, longLabel: json["address"]["LongLabel"].stringValue, shortLabel: json["address"]["ShortLabel"].stringValue, addrType: json["address"]["Addr_type"].stringValue, type: json["address"]["Type"].stringValue, placeName: json["address"]["PlaceName"].stringValue, addNum: json["address"]["AddNum"].stringValue, address: json["address"]["Address"].stringValue, block: json["address"]["Block"].stringValue, sector: json["address"]["Sector"].stringValue, neighborhood: json["address"]["Neighborhood"].stringValue, district: json["address"]["District"].stringValue, city: json["address"]["City"].stringValue, metroArea: json["address"]["MetroArea"].stringValue, subregion: json["address"]["Subregion"].stringValue, region: json["address"]["Region"].stringValue, territory: json["address"]["Territory"].stringValue, postal: json["address"]["Postal"].stringValue, postalEXT: json["address"]["PostalExt"].stringValue, countryCode: json["address"]["CountryCode"].stringValue,latitude: json["location"]["y"].stringValue,longitude: json["location"]["x"].stringValue)
                     
                     var latt = address.latitude
                     var longg = address.longitude
                     if latt.count > 11 {
                         latt = String(latt.prefix(11))
                     }
                     if longg.count > 11 {
                         longg = String(longg.prefix(11))
                     }
                     
                     let latflt =  Float(latt )
                     let longflt =  Float(longg)
                      UserDefaults.standard.set(String(format: "%.3f", latflt!), forKey: "latitude")
                      UserDefaults.standard.set(String(format: "%.3f", longflt!), forKey: "longitude")
                     
                     
                     AppConstants.lati = String(format: "%.3f", latflt!)
                     AppConstants.longi = String(format: "%.3f", longflt!)
                     
                  
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
                print(error)
//                failure(error,response.response?.statusCode,ApiManager.getErrorMessage(response: response, false))
                 AppUtility.showAlertWithProperty("Alert", messageString: "Unable to get current location")
                 AppUtility.hideProgress()
//                completion("", "Fail")
            }
        }
    }
    
    
    
    
}
