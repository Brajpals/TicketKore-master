//
//  EnterTextPopupViewController.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 26/02/21.
//

import UIKit
import CoreLocation
import MapKit

protocol AddOptionDelegate: class {
    func addEnteredOption(option:Questionoptions1)
}

protocol AddLocationDelegate: class {
    func addEnteredOption(option:Any)
}

class EnterTextPopupViewController: UIViewController,UITextFieldDelegate, GPSLocationDelegate {
   

    
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var inputField2: UITextField!
    @IBOutlet weak var firstInputView: UIView!
    @IBOutlet weak var secondInputView: UIView!
    @IBOutlet weak var locationBtn: UIButton!
    
    
    
    weak var delegate: AddOptionDelegate?
    weak var addLocationDelegate: AddLocationDelegate?
    
    let gpsLocation = GPSLocation()

    var titleString: String?
    var messageString: String?
    var ripaId: String?
    var inputType: String?
    var question: String?
    var validation = Validation()
    var popupType = ""
    var cityId = ""
    var countyID = AppManager.getLastSavedLoginDetails()?.result?.county_id
    
    let set = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ ")
    
    static func instantiate() -> EnterTextPopupViewController? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(EnterTextPopupViewController.self)") as? EnterTextPopupViewController
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
        locationBtn.tintColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        inputField.delegate = self
        inputField2.delegate = self
        inputField.text = ""
        inputField2.text = ""
        secondInputView.isHidden = true
        setInputType()
        inputField.becomeFirstResponder()
        
        locationBtn.isHidden = true
        if popupType == "Location" ||  popupType == "Intersection"{
            locationBtn.isHidden = false
        }
     }
    
    
    
    @IBAction func actionClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func actionSubmit(_ sender: Any) {
        var text = inputField.text!.uppercased()
        
        if inputField.text != ""{
            
//            if popupType == "City"{
//                let option = CityResult(city_id: "", custid: "", city_name: text, county_id: countyID!, order_number: "", isSelected: false)
//                self.addLocationDelegate?.addEnteredOption(option: option)
//            }
//            else
            if popupType == "Location" || popupType == "Intersection"{
                let option = LocationResult(location_id: "", custid: "", location: text, zone_id: "", order_number: "", is_active: "", county_id: countyID!, city_id: cityId, isSelected: false)
                self.addLocationDelegate?.addEnteredOption(option: option)
            }
    
            else if popupType == "School"{
                let option = SchoolResult(schoolsID: "", custid: "", cdsCode: "", ncesDist: "", ncesSchool: "", statusType: "", countyid: countyID!, county: "", district: "", school: text, street: "", streetABR: "", cityid: "", city: cityId, zip: "", state: "", phone: "", ext: "", faxNumber: "", email: "", webSite: "", doc: "", docType: "", soc: "", socType: "", edOpsCode: "", edOpsName: "", eilCode: "", eilName: "", gSoffered: "", gSserved: "", latitude: "", longitude: "", isK12School: "", isActive: "", orderNumber: "", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false)
                
                self.addLocationDelegate?.addEnteredOption(option: option)
            }
            else if popupType == "EducationCode"{
                let option = EducationCodeSection(educationCodeSectionID: "", educationCode: "", educationCodeDesc: text, physicalAttribute: "", orderNumber: "", isActive: "", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true)
                
                self.addLocationDelegate?.addEnteredOption(option: option)
            }
            else if popupType == "EducationSubCode"{
                let option = EducationCodeSubsection(educationCodeSubsectionID: "", educationCodeSectionID: "1", educationCodeSubsection: text, educationCodeSubsectionDesc: "", physicalAttribute: "", orderNumber: "", isActive: "", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true)
                
                self.addLocationDelegate?.addEnteredOption(option: option)
            }
//           else  if popupType == "Violation"{
//                let option = ViolationsResult(violationID: "", custid: "", violation: text, code: "", orderNumber: "", violationDisplay: text, isActive: "", violationType: "", violationGroup: "", travelMethod: "", isSelected: true
//                )
//                self.addLocationDelegate?.addEnteredOption(option: option)
//            }
            else{
                if ((question?.contains("Height")) != nil){
                    if inputField2.text! == ""{
                        text = inputField.text!
                    }else{
                    text = inputField.text! + "'" + inputField2.text!
                    }
                }
                
                if ((question?.contains("Weight")) != nil){
                    if inputField.text! != ""{
                        let weight = Int(inputField.text!)
                        if weight! >= 50{
                            text = inputField.text!
                        }
                        else{
                            AppUtility.showAlertWithProperty("Alert", messageString: "Weight cannot be less than 50")
                            return
                        }
                 }
                }
                
                
                let option = Questionoptions1(mainQuestId: "", mainQuestOrder:"",option_id: "", ripa_id: ripaId ?? "", custid: "", option_value: text, cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion : "", isDescription_Required : "",inputTypeCode: "", questionTypeCode: "", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "", isExpanded: false, questionoptions: [])
                
                self.delegate?.addEnteredOption(option: option)
            }
            inputField.text = ""
            dismiss(animated: true, completion: nil)
        }
        
        else{
            AppUtility.showAlertWithProperty("Alert", messageString: "Invalid Input")
        }
    }
    
    
    func setInputType() {
        if  inputType == "H "{
            self.inputField.keyboardType = UIKeyboardType.numberPad
            self.inputField2.keyboardType = UIKeyboardType.numberPad
            secondInputView.isHidden = false
        }
        if  inputType == "AN"{
            self.inputField.keyboardType = UIKeyboardType.default
        }
        if  inputType == "A "{
            self.inputField.keyboardType = UIKeyboardType.default
        }
        if  inputType == "N "{
            self.inputField.keyboardType = UIKeyboardType.numberPad
        }
        if  inputType == "V "{
            // self.inputField.keyboardType = UIKeyboardType.numbersAndPunctuation
        }
        if  inputType == "L "{
            self.inputField.keyboardType = UIKeyboardType.numbersAndPunctuation
        }
        if  inputType == "C "{
            self.inputField.keyboardType = UIKeyboardType.numbersAndPunctuation
        }
        
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
       // let newLength:Int = newString.count
        
        if ((question?.contains("Weight")) != nil){
               // let newText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
                if newString.isEmpty {
                    return true
                }
                else if let intValue = Int(newString), intValue <= 500 {
                    return true
                }
                return false
            }
            
        if ((question?.contains("Height")) != nil){
                if textField == inputField{
                  //  let newText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
                    if newString.isEmpty {
                        return true
                    }
                    else if let intValue = Int(newString), intValue <= 6 && intValue >= 4 {
                        return true
                    }
                    return false
                }
                if textField == inputField2{
                  //  let newText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
                    if newString.isEmpty {
                        return true
                    }
                    else if let intValue = Int(newString), intValue <= 11 {
                        return true
                    }
                    return false
                }
                
            }
            
            if inputType == "A "{
                do {
                    let regex = try NSRegularExpression(pattern: ".*[^A-Za-z].*", options: [])
                    if regex.firstMatch(in: string, options: [], range: NSMakeRange(0, string.count)) != nil {
                        return false
                    }
                }
                catch {
                    print("ERROR")
                }
                return true
            }
            return true
       
    }
    
    
    
    @IBAction func getLocation(_ sender: Any) {
        gpsLocation.delegate = self
        gpsLocation.getGPSLocation()
    }
    
   
    func fetchedLocationDetails(location: CLLocation, countryCode: String, city: String, street: String, intersection: String, county: String) {
        inputField.text = street
        if popupType == "Intersection"{
            inputField.text = intersection
        }
    }
    
    func failedFetchingLocationDetails(error: Error) {
        print("Error")
    }
    
    
 
    
}
