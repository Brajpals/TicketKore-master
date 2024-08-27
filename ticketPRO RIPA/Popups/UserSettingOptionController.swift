//
//  UserSettingOptionController.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 29/11/21.
//

import UIKit


protocol supervisorDelegate: AnyObject {
    func getUserSupervisor(sData:Supervisor?,index : Int)
    func removeView()
}

class UserSettingOptionController: UIViewController {

     
    var supervisorArray = [Supervisor]()
   
    var  delegate : supervisorDelegate?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let obj = supervisorArray.filter {
            $0.isSelected == true
        }
        if obj.count == 0 {
            supervisorArray[0].isSelected = true
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "RadioTextCell", bundle: nil), forCellReuseIdentifier: "RadioTextCell")
    }
    
  @IBAction func removeOptionView(_ sender: Any) {
      self.dismiss(animated: true, completion: nil)
      self.delegate?.removeView()
  }
    
}

extension UserSettingOptionController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return supervisorArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RadioTextCell", for: indexPath as IndexPath) as! RadioTextCell
        if let lName = supervisorArray[indexPath.row].LastName,let fName = supervisorArray[indexPath.row].FirstName {
            cell.titleLbl.text = lName + " " + fName
        }
        
        cell.radioImage.image = UIImage(named: "Unselect")
        cell.titleLbl.font = UIFont.systemFont(ofSize: 17.0)
        if supervisorArray[indexPath.row].isSelected{
            cell.titleLbl.font = UIFont.boldSystemFont(ofSize: 16.0)
            cell.radioImage.image = UIImage(named: "Select")
        }
        cell.backgroundColor = UIColor(red:236/255.0, green:236/255.0, blue:236/255.0, alpha: 1.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.getUserSupervisor(sData: supervisorArray[indexPath.row],index : indexPath.row)
        self.dismiss(animated: true, completion: nil)
        self.delegate?.removeView()
    }
}


extension UIViewController {

func showToast(message : String, font: UIFont) {

    let toastLabel = UILabel(frame: CGRect(x: (self.view.frame.size.width - 300)/2, y: self.view.frame.size.height - 500, width: 300, height: 45))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.numberOfLines = 2
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 2.0, delay: 0.0, options: .curveEaseOut, animations: {
         toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
} }
