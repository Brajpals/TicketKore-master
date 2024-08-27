//
//  ListViewController.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 25/03/21.
//

import UIKit
import EzPopup



protocol LocationDelegate:AnyObject {
    func refreshLocationLists(list:[Any]?, listType: String)
    func countyChanged(resetLoc:Bool)
}



class ListViewController: UIViewController,PopupViewControllerDelegate, AddLocationDelegate,GetListDelegate, UITextFieldDelegate {
   
   
    
    weak var locationdelegate: LocationDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var refreshBtn: UIButton!
    @IBOutlet weak var search: UITextField!
    @IBOutlet weak var viewLbl: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    
    let db = SqliteDbStore()
    
    var listType:String?
    var cityArray : [CityResult]?
    var locationArray : [LocationResult]?
    var schoolArray : [SchoolResult]?
    var violationArray : [ViolationsResult]?

    var countyArray : [CountyResult]?
    var location = Location()
    
    var isResultStop : Bool = false
    var streetName : String?
    var cityID : String?
    var intersectionName : String?
   
    
    var educationCodeSectionArray : [EducationCodeSection]?
    var educationCodeSubSectionArray : [EducationCodeSubsection]?
    
    let enterTextPopup = EnterTextPopupViewController.instantiate()
    
    var dashboardViewModel = DashboardViewModel()
    var newRipaViewModel = NewRipaViewModel()
    
 
    var listArray:[Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ListCell", bundle: nil), forCellReuseIdentifier: "ListCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        search.delegate = self
        search.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        search.becomeFirstResponder()
        
        onload()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.showProgress(nil, title:"")
        
    if AppConstants.theme == "1"{
        overrideUserInterfaceStyle = .dark
        }
    else{
       overrideUserInterfaceStyle = .light
        AppConstants.theme = "0"
     }
 }
 
    
    
    func onload(){
        submitBtn.isHidden = true
       
        if listType == "County"{
            listArray = countyArray
            search.placeholder = "Search County"
            viewLbl.text = listType
            addBtn.isHidden = true
            refreshBtn.isHidden = true
        }
      else if listType == "City or Unincorporated Area"{
            listArray = cityArray
            search.placeholder = "Search City"
            viewLbl.text = "Cities or Unincorporated Area"
            addBtn.isHidden = true
        }
        else if listType == "Location" || listType == "First Intersection" || listType == "Street" || listType == "Second Intersection" {
            listArray = locationArray
            search.placeholder = "Search"
            viewLbl.text = "Street"
            if listType == "First Intersection" || listType ==  "Second Intersection" {
                viewLbl.text = "Cross street"
            }
        }
        else if listType == "Highway" || listType == "Closest Highway Exit"{
            listArray = locationArray
            search.placeholder = "Search Highway"
            viewLbl.text = "Highway"
            if listType == "Closest Highway Exit"{
                viewLbl.text = "Closest Highway Exit"
            }
        }
        else if listType == "Violation"{
            listArray = violationArray
            search.placeholder = "Search Violation"
            viewLbl.text = listType
            addBtn.isHidden = true
            submitBtn.setTitle("ACCEPT", for: .normal)
         }
        else if listType == "EducationCode"{
            listArray = educationCodeSectionArray
            search.placeholder = "Search Education Code"
            viewLbl.text = listType
           // addBtn.setTitle("BACK", for: .normal)
            addBtn.isHidden = true
        }
        else if listType == "EducationSubCode"{
            listArray = educationCodeSubSectionArray
            search.placeholder = "Search Education Code Subsection"
            viewLbl.text = listType
            refreshBtn.isHidden = true
            //addBtn.setTitle("BACK", for: .normal)
            addBtn.isHidden = true
        }
        else{
            listArray = schoolArray
            search.placeholder = "Search School"
            viewLbl.text = listType
            addBtn.isHidden = true
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        AppUtility.hideProgress(nil)
      }
    
    
    @IBAction func action_add(_ sender: Any) {
        if listType == "EducationCode" || listType == "EducationSubCode" {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            guard let customAlertVC = enterTextPopup else { return }
            // customAlertVC.ripaId = questionArray![questNumber!].id
            customAlertVC.inputType = "AN"
            customAlertVC.popupType = listType!
            customAlertVC.cityId = cityID!
            customAlertVC.addLocationDelegate = self
            let popupVC = PopupViewController(contentController: customAlertVC, position: .bottom(10), popupWidth: UIScreen.main.bounds.size.width, popupHeight: 220)
            popupVC.cornerRadius = 5
            popupVC.delegate = self
            present(popupVC, animated: true, completion: nil)
        }
    }
    
    func addEnteredOption(option: Any) {
        if listType == "County"{
            countyArray?.append(option as! CountyResult)
             listArray = countyArray
         }
       else if listType == "City or Unincorporated Area"{
            cityArray?.append(option as! CityResult)
             listArray = cityArray
         }
        else if listType == "Location" || listType == "First Intersection" || listType == "Second Intersection" || listType == "Street" || listType == "Highway" || listType == "Closest Highway Exit"{
            
            let ast = (option as! LocationResult).location
             let filteredLocation = location.result.filter({($0.city_id).contains(cityID!) && ($0.location).contains(ast) })
 
             if filteredLocation.count < 1{
                  locationArray!.append(option as! LocationResult)
                 listArray = locationArray
 
            location.result.append(option as! LocationResult)
 
            let encodedData = try! JSONEncoder().encode(location)
            let newString = String(data: encodedData,
                                    encoding: .utf8)
 
            db.openDatabase()
            db.deleteAllfrom(table: "locationTable")
            db.insertData(jsonString : newString!, tableName:"locationTable")
            }
             else{
                DispatchQueue.background(delay: 1, completion:{
                    AppUtility.showAlertWithProperty("Alert", messageString: "Street already exists in list.")
             })
//                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                    AppUtility.showAlertWithProperty("Alert", messageString: "Street already exists in list.")
//              }
             }
            
        }
        else if listType == "EducationCode"{
            educationCodeSectionArray!.append(option as! EducationCodeSection)
            listArray = educationCodeSectionArray
        }
        else if listType == "EducationSubCode"{
            educationCodeSubSectionArray!.append(option as! EducationCodeSubsection)
            listArray = educationCodeSubSectionArray
        }
        else if listType == "Violation"{
            violationArray!.append(option as! ViolationsResult)
            listArray = violationArray
        }
        else{
            schoolArray!.append(option as! SchoolResult)
            listArray = schoolArray
        }
        tableView.reloadData()
    }
    
    
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        print(textField.text!)
        var text = textField.text!.lowercased()
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if listType == "County"{
            listArray = countyArray!.filter{ $0.countyName.lowercased().contains(text) }
            if text == ""{
                listArray = countyArray
            }
        }
       else if listType == "City or Unincorporated Area"{
            listArray = cityArray!.filter{ $0.city_name.lowercased().contains(text) }
            if text == ""{
                listArray = cityArray
            }
        }
        else if listType == "Location" || listType == "First Intersection" || listType == "Second Intersection" || listType == "Street" || listType == "Highway" || listType == "Closest Highway Exit"{
            listArray = locationArray!.filter{ $0.location.lowercased().contains(text) }
            if text == ""{
                listArray = locationArray
            }
        }
        else if listType == "Violation"{
            listArray = violationArray!.filter{ $0.violationDisplay.lowercased().contains(text) }
            if text == ""{
                listArray = violationArray
            }
        }
        else if listType == "EducationCode"{
            listArray = educationCodeSectionArray!.filter{ $0.educationCodeDesc.lowercased().contains(text) }
            if text == ""{
                listArray = educationCodeSectionArray
            }
        }
        else if listType == "EducationSubCode"{
            listArray = educationCodeSubSectionArray!.filter{ $0.educationCodeSubsectionDesc.lowercased().contains(text) }
            if text == ""{
                listArray = educationCodeSubSectionArray
            }
        }
        else{
            listArray = schoolArray!.filter{ $0.school.lowercased().contains(text) }
            if text == ""{
                listArray = schoolArray
            }
        }
         tableView.reloadData()
    }
    
    
    @IBAction func action_refresh(_ sender: Any) {
        
        search.text = ""
        tableView.reloadData()
        AppUtility.showProgress(nil, title:"")
        dashboardViewModel.getListDelegate = self
        dashboardViewModel.forListRefresh = true
        
         if listType == "City or Unincorporated Area"{
            dashboardViewModel.setCityParam()
        }
        else if listType == "Location" || listType == "First Intersection" || listType == "Second Intersection" || listType == "Street"{
            dashboardViewModel.setLocationParam()
        }
        else if listType == "Highway" || listType == "Closest Highway Exit"{
            newRipaViewModel.getHighways(cityID: cityID ?? "")
        }
        else if listType == "Violation"{
            dashboardViewModel.setViolationsParam()
        }
        else if listType == "EducationCode"{
            dashboardViewModel.setEducationParam()
        }
         else{
            dashboardViewModel.setSchoolParam()
        }
    }
    
    
    @IBAction func action_back(_ sender: Any) {
        if listType == "Violation"{
            //violationArray?.forEach({$0.isSelected = false})
            listArray = violationArray
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func action_submit(_ sender: Any) {
          if listType == "Violation"{
             listArray = violationArray
        }
        else if listType == "EducationCode"{
             listArray = educationCodeSectionArray
        }
        self.locationdelegate?.refreshLocationLists(list:listArray, listType: listType!)
        self.dismiss(animated: true, completion: nil)
    }
    
 
    func getList(success: String) {
        AppUtility.hideProgress()
        if success == "true"{
            if listType == "City or Unincorporated Area"{
                cityArray = newRipaViewModel.getCities()
                listArray = cityArray
            }
            else if listType == "Location" || listType == "First Intersection" || listType == "Second Intersection" || listType == "Street" || listType == "Highway" || listType == "Closest Highway Exit"{
                let locDetail = newRipaViewModel.getLocation(cityID: cityID!)
                locationArray = locDetail.0
                location =  locDetail.1
                listArray = locationArray
            }
            else if listType == "Violation"{
                let newVio = newRipaViewModel.getViolations()
                if  let selectedVio = violationArray?.filter({$0.isSelected == true}) {
                    for obj in selectedVio {
                        if let index = newVio.firstIndex(where: {$0.violationDisplay.capitalized == obj.violationDisplay.capitalized}) {
                            newVio[index].isSelected = true
                        }
                    }
                }
                violationArray =  newVio
                listArray = violationArray
            }
            else if listType == "EducationCode"{
                educationCodeSectionArray = newRipaViewModel.getEducationCode().0
                listArray = educationCodeSectionArray
            }
             else{
                 schoolArray = newRipaViewModel.getSchool(cityID: cityID!)
 
            }
        }
        
        tableView.reloadData()
    }
    
    
}



extension ListViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(listArray!.count)
        return listArray!.count
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
        var text:String?
       //cell.checkImg.image =  UIImage(named: "checkboxEmpty")
        cell.checkImg.image =  UIImage(named: "uncheck")
      //  cell.checkImg.isHidden = true
        cell.label.font = UIFont.systemFont(ofSize: 18.0)
        if listType == "EducationCode"{
            text = (listArray![indexPath.row] as! EducationCodeSection).educationCodeDesc
            cell.checkImg.image =  UIImage(named: "Unselect")
            if (listArray![indexPath.row] as! EducationCodeSection).isSelected == true{
                cell.checkImg.isHidden = false
                cell.checkImg.image =  UIImage(named: "Select")
                cell.label.font = UIFont.boldSystemFont(ofSize: 18.0)
            }
        }
        else if listType == "EducationSubCode"{
            text = (listArray![indexPath.row] as! EducationCodeSubsection).educationCodeSubsectionDesc
        }
        else if listType == "Violation"{
            text = (listArray![indexPath.row] as! ViolationsResult).violationDisplay
             if (listArray![indexPath.row] as! ViolationsResult).isSelected == true{
                 cell.checkImg.isHidden = false
                 cell.checkImg.image =  UIImage(named: "Check")
                 cell.label.font = UIFont.boldSystemFont(ofSize: 18.0)
             }
        }
        else{
            cell.checkImg.isHidden = true
            if listType == "County"{
                text = (listArray![indexPath.row] as! CountyResult).countyName + " COUNTY"
            }
           else if listType == "City or Unincorporated Area"{
                text = (listArray![indexPath.row] as! CityResult).city_name
            }
            else if listType == "Location" || listType == "First Intersection" || listType == "Second Intersection" ||  listType == "Street" || listType == "Highway" || listType == "Closest Highway Exit"{
                text = (listArray![indexPath.row] as! LocationResult).location
            }
            else{
                text = (listArray![indexPath.row] as! SchoolResult).school
            }
        }
        cell.label.text = text
        return cell
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if listType == "Violation"{
            if isResultStop {
                let violationId = (listArray![indexPath.row] as! ViolationsResult).violationID
                let check = violationArray?.contains(where: {
                    $0.violationID == violationId && $0.isSelected == true
                })
               
                if (listArray![indexPath.row] as! ViolationsResult).isNewAdded == false && check == true {
                }
                else if (listArray![indexPath.row] as! ViolationsResult).isNewAdded == true {
                    (listArray![indexPath.row] as! ViolationsResult).isNewAdded = !(listArray![indexPath.row] as! ViolationsResult).isNewAdded
                    (listArray![indexPath.row] as! ViolationsResult).isSelected = !(listArray![indexPath.row] as! ViolationsResult).isSelected
                }
                else if check == false {
                    (listArray![indexPath.row] as! ViolationsResult).isNewAdded = !(listArray![indexPath.row] as! ViolationsResult).isNewAdded
                    (listArray![indexPath.row] as! ViolationsResult).isSelected = !(listArray![indexPath.row] as! ViolationsResult).isSelected
                }
            }
            else {
                (listArray![indexPath.row] as! ViolationsResult).isSelected = !(listArray![indexPath.row] as! ViolationsResult).isSelected
            }
            submitBtn.isHidden = false
            tableView.reloadData()
        }
        else{
            if listType == "County"{
             
                 if AppManager.getLastSavedLoginDetails()?.result?.county_id != (listArray![indexPath.row] as! CountyResult).countyID{
                    AppManager.getLastSavedLoginDetails()?.result?.county_id = (listArray![indexPath.row] as! CountyResult).countyID
                     AppManager.saveLoginDetails()
                    self.locationdelegate?.countyChanged(resetLoc:true)
                }
                 else{
                    self.locationdelegate?.countyChanged(resetLoc:false)
                  }
             }
          else if listType == "City or Unincorporated Area"{
                (listArray![indexPath.row] as! CityResult).isSelected = !(listArray![indexPath.row] as! CityResult).isSelected
               print(listArray)
               print( (listArray![indexPath.row] as! CityResult).city_id)
              (listArray![indexPath.row] as! CityResult).isSelected = true
                let dict = ["City or Unincorporated Area": (listArray![indexPath.row] as! CityResult).city_name, "Id": (listArray![indexPath.row] as! CityResult).city_id]
                UserDefaults.standard.set(dict, forKey: "DefaultCity")
                UserDefaults.standard.synchronize()
                
                self.locationdelegate?.refreshLocationLists(list:listArray, listType: "City or Unincorporated Area")
            }
            else if listType == "Location" || listType == "First Intersection" || listType == "Second Intersection" || listType ==  "Street" || listType == "Highway" || listType == "Closest Highway Exit"{
                
                if listType == "Location"{
                    if  (listArray![indexPath.row] as! LocationResult).location == intersectionName{
                        AppUtility.showAlertWithProperty("Alert", messageString: "Cross Street2 Can't be same as Cross Street1.")
                        return
                    }
                 }
                  if listType == "Second Intersection"{
                      if  (listArray![indexPath.row] as! LocationResult).location == AppConstants.firstIntersection{
                        AppUtility.showAlertWithProperty("Alert", messageString: "Cross Street2 Can't be same as Cross Street1.")
                        return
                    }
                }
                if listType == "First Intersection"{
                    if  (listArray![indexPath.row] as! LocationResult).location == AppConstants.secondIntersection{
                      AppUtility.showAlertWithProperty("Alert", messageString: "Cross Street1 Can't be same as Cross Street2.")
                      return
                  }
              }
                if (listArray![indexPath.row] as! LocationResult).location.count < 5 || (listArray![indexPath.row] as! LocationResult).location.count > 250 {
                    AppUtility.showAlertWithProperty("Alert", messageString: "Street should be between 5 to 250 in length.")
                    return
                }
                   (listArray![indexPath.row] as! LocationResult).isSelected = !(listArray![indexPath.row] as! LocationResult).isSelected
                  self.locationdelegate?.refreshLocationLists(list:listArray, listType: listType!)
            }
            else if listType == "EducationCode"{
                listArray?.forEach({
                    ($0 as! EducationCodeSection).isSelected = false
                })
                (listArray![indexPath.row] as! EducationCodeSection).isSelected = !(listArray![indexPath.row] as! EducationCodeSection).isSelected
                self.locationdelegate?.refreshLocationLists(list:listArray, listType: listType!)
             }
            else if listType == "EducationSubCode"{
                (listArray![indexPath.row] as! EducationCodeSubsection).isSelected = !(listArray![indexPath.row] as! EducationCodeSubsection).isSelected
                self.locationdelegate?.refreshLocationLists(list:listArray, listType: listType!)
            }
            else{
                (listArray![indexPath.row] as! SchoolResult).isSelected = !(listArray![indexPath.row] as! SchoolResult).isSelected
                self.locationdelegate?.refreshLocationLists(list:listArray, listType: listType!)
            }
           
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        search.resignFirstResponder()
    }
    
    
}

extension Array {
    func filtered<T>(by _: T.Type) -> [T] {
        return filter { type(of: $0) == T.self } as! [T]
   }
}
