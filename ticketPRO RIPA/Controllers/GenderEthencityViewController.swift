//
//  GenderEthencityViewController.swift
//  ticketPRO RIPA
//
//  Created by mac on 16/08/23.
//

import UIKit

class GenderEthencityViewController: UIViewController,UserSettingModelDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var userSettingsModel = UserSettingViewModel()
    var userSettingArray = UserSettingModel()
    
    var genderStr : String = ""
    var ethnicityStr : String = ""
    var isVisible : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userSettingsModel.userDelegate = self
        self.userSettingsModel.getUserSettings()
        tableView.register(UINib(nibName: "RadioTextCell", bundle: nil), forCellReuseIdentifier: "RadioTextCell")
       
    }
    
    func getUserSettingData(settingData:UserSettingModel?){
        self.userSettingArray = settingData!
        if self.userSettingArray.gender_option?.count ?? 0 > 0 {
            isVisible = 1
        }
        self.showAlertIfGenderEthnicityNotAvailable()
    }
    
    func updateUserSettingData(msg: String) {
        DataManager.shared.loginDetails?.result?.Gender = genderStr
        DataManager.shared.loginDetails?.result?.Ethnicity = ethnicityStr
        AppManager.saveLoginDetails()
        let vc2 = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UserSettingsViewController") as! UserSettingsViewController
        vc2.userSettingArray = userSettingArray
        vc2.flag = 9
        self.navigationController?.pushViewController(vc2, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
           navigationController?.setNavigationBarHidden(true, animated: animated)
     }
    
    @IBAction func action_BackBtn(_ sender: Any) {
        AppManager.logout()
        AppConstants.bioLogin = "0"
        let story = UIStoryboard(name: "Main", bundle:nil)
        let vc = story.instantiateViewController(withIdentifier: "EnrollementViewController") as! EnrollementViewController
        UIApplication.shared.windows.first?.rootViewController = vc
        UIApplication.shared.windows.first?.makeKeyAndVisible()
        
       /* var countt : Int = 0
        countt = navigationController?.viewControllers.count ?? 0
        if countt > 0 {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            let story = UIStoryboard(name: "Main", bundle:nil)
            let vc = story.instantiateViewController(withIdentifier: "EnrollementViewController") as! EnrollementViewController
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        } */
    }
   
    @IBAction func action_submitBtn(_ sender: Any) {
        let genderItem = self.userSettingArray.gender_option?.filter({
            $0.isSelected == true
        })
        let ethncityItem = self.userSettingArray.ethncity_option?.filter({
            $0.isSelected == true
        })
        
        if isVisible == 1 && genderItem?.count == 0 {
            AppUtility.showAlertWithProperty("", messageString: "Please select your gender first.")
        }
        else if ethncityItem?.count == 0 {
            AppUtility.showAlertWithProperty("", messageString: "Please select atleast one Ethnicity.")
        }
        else {
            self.submitDataToServer()
        }
     /*
        if genderItem?.count ?? 0 > 0 && ethncityItem?.count ?? 0 > 0 {
            self.submitDataToServer()
        }
        else if genderItem?.count == 0 {
            AppUtility.showAlertWithProperty("", messageString: "Please select your gender first.")
        }
        else if ethncityItem?.count == 0 {
            AppUtility.showAlertWithProperty("", messageString: "Please select atleast one Ethnicity.")
        }  */
     }
    
    func showAlertIfGenderEthnicityNotAvailable(){
        let alert = UIAlertController(title: nil, message: DataManager.shared.loginDetails?.result?.message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            self.tableView.reloadData()
         })
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    func submitDataToServer() {
        var gender : String = ""
        var ethencity : String = ""
        var genderAtrribute : String = ""
        let genderItem = self.userSettingArray.gender_option?.filter({
            $0.isSelected == true
        })
        let ethncityItem = self.userSettingArray.ethncity_option?.filter({
            $0.isSelected == true
        })
        
        if genderItem?.count ?? 0 > 0 {
            genderStr = genderItem?[0].option_id ?? ""
            gender = genderItem?[0].option_value ?? ""
            genderAtrribute = genderItem?[0].physical_attribute ?? ""
        }
        
        if let data = ethncityItem {
            for options in data {
                if ethnicityStr == "" {
                    ethnicityStr = options.option_id ?? ""
                    ethencity = options.option_value ?? ""
                }
                else {
                    ethnicityStr = String(format: "%@,%@", ethnicityStr,options.option_id ?? "")
                    ethencity = String(format: "%@,%@", ethencity,options.option_value ?? "")
                }
            }
        }
       
        UserDefaults.standard.set(gender, forKey: "gender")
        UserDefaults.standard.set(genderAtrribute, forKey: "officerGenderAttribute")
        UserDefaults.standard.set(ethencity, forKey: "ethencity")
        userSettingsModel.sendGenderEthenicityInfo(ethnicity: ethnicityStr, gender: genderStr)
        
    }

}

extension GenderEthencityViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let ethCount = self.userSettingArray.ethncity_option?.count ?? 0
        let genCount = self.userSettingArray.gender_option?.count ?? 0
        if section == 0 && ethCount == 0{
            return 0
        }
        else if section == 1 && genCount == 0{
            return 0
        }
        return 50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isVisible == 1 {
            return 2
        }
        else {
            return 1
        }
    }
  
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = UIView(frame: CGRect(x:0,y:0,width: self.view.frame.size.width,height:50))
        
        let requiredImg = UIImageView(frame: CGRect(x:0,y:(headerV.frame.size.height - 20)/2,width: 20,height:20))
        requiredImg.image = UIImage(named: "required_icon")
        headerV.addSubview(requiredImg)
        requiredImg.isHidden = false
        
       
        
        let label = UILabel()
        label.frame = CGRect.init(x: 30, y: 0, width: headerV.frame.width-20, height: headerV.frame.height)
        if section == 0 {
            label.text = "Ethnicity of Officer"
        }
        else {
            label.text = "Gender of Officer"
        }
        
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .black
        headerV.addSubview(label)
        
        let ethCount = self.userSettingArray.ethncity_option?.count ?? 0
        let genCount = self.userSettingArray.gender_option?.count ?? 0
        if ethCount == 0 && genCount == 0 {
            requiredImg.isHidden = true
            requiredImg.frame = CGRect(x:0,y:0,width: 0,height:0)
        }
        if section == 0 && ethCount == 0{
            headerV.frame = CGRect(x:0,y:0,width: self.view.frame.size.width,height:0)
            label.frame = CGRect(x:0,y:0,width: self.view.frame.size.width,height:0)
            label.text = ""
        }
        else if section == 1 && genCount == 0{
            headerV.frame = CGRect(x:0,y:0,width: self.view.frame.size.width,height:0)
            label.frame = CGRect(x:0,y:0,width: self.view.frame.size.width,height:0)
            label.text = ""
            requiredImg.isHidden = true
        }
        
        print(isVisible)
        if isVisible == 0 && section == 1 {
            requiredImg.isHidden = true
            requiredImg.frame = CGRect(x:0,y:0,width: 0,height:0)
        }
        
        return headerV
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return self.userSettingArray.ethncity_option?.count ?? 0
        }
        return self.userSettingArray.gender_option?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 , let check = self.userSettingArray.ethncity_option?[indexPath.row].isSelected{
            self.userSettingArray.ethncity_option?[indexPath.row].isSelected = !check
        }
        else {
            self.userSettingArray.gender_option?.forEach({
                $0.isSelected = false
            })
            self.userSettingArray.gender_option?[indexPath.row].isSelected = true
        }
        self.tableView.reloadData()
    }
    
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RadioTextCell", for: indexPath as IndexPath) as! RadioTextCell
            cell.selectionStyle = .none
        if indexPath.section == 0, let data = self.userSettingArray.ethncity_option{
            cell.setEthncity(data: data[indexPath.row])
            cell.lineView.isHidden = false
            if indexPath.row == data.count - 1 {
                cell.lineView.isHidden = true
            }
        }
        else if let data = self.userSettingArray.gender_option{
            cell.setGender(data: data[indexPath.row])
            cell.lineView.isHidden = false
            if indexPath.row == data.count - 1 {
                cell.lineView.isHidden = true
            }
        }
        cell.backgroundColor = UIColor(red:236/255.0, green:236/255.0, blue:236/255.0, alpha: 1.0)
            return cell
    }

    
}

extension UILabel{

public var requiredHeight: CGFloat {
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.font = font
    label.text = text
    label.attributedText = attributedText
    label.sizeToFit()
    return label.frame.height
  }
}

