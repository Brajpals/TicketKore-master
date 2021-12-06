//
//  LocationEditViewController.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 05/06/21.
//

import UIKit


protocol LocationEditViewDelegate: class {
    func setLocationEdit(locationObject:RejectedApplicationLocation,address:String, city:String)
}

class LocationEditViewController: UIViewController, LocationDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate {
    func countyChanged(resetLoc: Bool) {
         
    }
    
   
    
     weak var locationEditDelegate : LocationEditViewDelegate?

    @IBOutlet weak var streetBtn: UIButton!
    @IBOutlet weak var intersectionBtn: UIButton!
    
    @IBOutlet weak var removeBlockBtn: UIButton!
    @IBOutlet weak var removeIntersectionBtn: UIButton!
    
    @IBOutlet weak var intersectionTxt: UITextField!
    @IBOutlet weak var blockTxt: UITextField!
    @IBOutlet weak var streetTxt: UITextField!
    @IBOutlet weak var locationLbl: UILabel!
    
    @IBOutlet weak var cityBtn: UIButton!
    @IBOutlet weak var cityLbl: UITextField!
    
    
    var updateRipaLocation : RejectedApplicationLocation?
    var newRipaViewModel = NewRipaViewModel()
    var cityId = ""
    var locationArray = [LocationResult]()
    var location:Location?
    var city:String?
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        trackApplicationTime()
        super.touchesEnded(touches , with: event)
    }
    
     func trackApplicationTime(){
        print(AppConstants.applicationtime)
        print(String(MyGlobalTimer.sharedTimer.time))
        AppConstants.applicationtime = String(Int(AppConstants.applicationtime)! + MyGlobalTimer.sharedTimer.time)
        print(AppConstants.applicationtime)
        MyGlobalTimer.sharedTimer.stopTimer()
        MyGlobalTimer.sharedTimer.startTimer()
     }
    
    
    func countyChanged() {
        
    }
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
      
        streetTxt.text =   updateRipaLocation!.street
        blockTxt.text =  updateRipaLocation!.block
        intersectionTxt.text =  updateRipaLocation!.intersection
        string = updateRipaLocation!.block
        blockTxt.delegate = self
        cityLbl.text = city
        
         createAddress()
     }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    if AppConstants.theme == "1"{
        overrideUserInterfaceStyle = .dark
        }
    else{
       overrideUserInterfaceStyle = .light
        AppConstants.theme = "0"
     }
        }
    
    

    @IBAction func actionRemoveBlk(_ sender: Any) {
        blockTxt.text = ""
        string = ""
        createAddress()
    }
    

    @IBAction func actionRemoveInter(_ sender: Any) {
        intersectionTxt.text = ""
        createAddress()
    }
    
    
    @IBAction func actionUpdate(_ sender: Any) {
        updateRipaLocation!.block =  blockTxt.text ?? ""
        self.locationEditDelegate?.setLocationEdit(locationObject:updateRipaLocation!,address:address, city: city ?? "")
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
    @IBAction func actionOpenCity(_ sender: Any) {
        openList(index:0)
    }
    
    
    @IBAction func openStreetList(_ sender: Any) {
        openList(index:1)
    }
    
    
    @IBAction func openIntersection(_ sender: Any) {
        openList(index:2)
    }
    
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func refreshLocationLists(list: [Any]?, listType: String) {
        for listObj in list! {
            
            if  listType == "Location" ||   listType == "Intersection"{
            if (listObj as! LocationResult).isSelected{
                 if listType == "Location"{
                    updateRipaLocation!.street = (listObj as! LocationResult).location
                    streetTxt.text =   updateRipaLocation!.street
                   }
                else if listType == "Intersection"{
                    updateRipaLocation!.intersection = (listObj as! LocationResult).location
                    intersectionTxt.text =  updateRipaLocation!.intersection
                 }
                break
            }
            }
                else{
                    if (listObj as! CityResult).isSelected{
                         updateRipaLocation?.street = ""
                        updateRipaLocation?.intersection = ""
                        updateRipaLocation?.block = ""
                        intersectionTxt.text = ""
                        streetTxt.text = ""
                        blockTxt.text = ""
                        cityId = (listObj as! CityResult).city_id
                        
                        DispatchQueue.background(delay: 0.2, completion:{
                            self.openList(index:1)
                    })
                        
                        city = (listObj as! CityResult).city_name
                       cityLbl.text = city
                    
                        break
                    }
                 }
         }
         createAddress()
          }
 
   
    
    func openList(index:Int){
        
        let locDetail = newRipaViewModel.getLocation(cityID: cityId)
        locationArray = locDetail.0
        location = locDetail.1
 
        let listView = self.storyboard?.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        listView.locationdelegate = self
        listView.locationArray = locationArray
        listView.location = location!
        
        if index == 0{
            let cityArr = newRipaViewModel.getCities()
            listView.cityArray = cityArr
             listView.listType = "City"
            }
        else if index == 1{
            listView.listType = "Location"
            }
        else{
            listView.listType = "Intersection"
        }
        listView.cityID = cityId
        listView.streetName = updateRipaLocation!.street
        listView.intersectionName = updateRipaLocation!.intersection
        self.navigationController?.present(listView, animated: true, completion: nil)
    
    
}
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)

        if let intValue = Int(newString), intValue > 999999{
            return false
        }
        self.string = newString
          createAddress()
        return true
    }
    
    var string = ""
    
    
    var address = ""
   func createAddress(){
    let street = streetTxt.text
    var inter = intersectionTxt.text
    var blk = string
    
    if blk != "" && (street != "" || inter != ""){
        blk = blk + " BLK "
    }
    if street != "" && inter != ""{
        inter = " & " + inter!
    }
    
    address = blk + street! + inter!
    locationLbl.text = address
    }
    
    
}
