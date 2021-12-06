//
//  AllQuestionViewController.swift
//  ticketPRO RIPA
//
//  Created by Nitin on 5/5/21.
//

import UIKit

protocol FilterPopupDelegate: class {
    func selectedOptionFromPopup(filteredList:[FilterList], fromDate:String,toDate:String)
}


class FilterPopup: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    static func instantiateOption() -> FilterPopup? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(FilterPopup.self)") as? FilterPopup
    }
    
    
    weak var filterPopupDelegate : FilterPopupDelegate?
    // var optionsArray : [Questionoptions1]?
    var filterList : [FilterList]?
    
    
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneView: UIView!
    
    @IBOutlet weak var fromField: UITextField!
    @IBOutlet weak var toField: UITextField!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var checkBox: UIButton!
    
    
    let datePicker = UIDatePicker()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if AppConstants.theme == "1"{
            overrideUserInterfaceStyle = .dark
        }
        else{
            overrideUserInterfaceStyle = .light
            AppConstants.theme = "0"
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ListCell", bundle: nil), forCellReuseIdentifier: "ListCell")
        checkStatusSelection()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "optionFilter"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showDatePicker()
     
    }
    
    
    
    
    func showDatePicker(){
         //Formate Date
        datePicker.datePickerMode = .date
        // Posiiton date picket within a view
        datePicker.frame = CGRect(x: 10, y: 50, width: self.view.frame.width, height: 200)
        let now = Date();
        datePicker.maximumDate = now
        // Set some of UIDatePicker properties
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = UIColor.white
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let toolbar2 = UIToolbar();
        toolbar2.sizeToFit()
        
        //  toolbar = UIToolbar(frame: CGRect (x:0,y:0,width:self.view.frame.width,height:400))
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneFromDatePicker));
        let doneButton2 = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneToDatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        let cancelButton2 = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        toolbar2.setItems([doneButton2,spaceButton,cancelButton2], animated: false)
        
        fromField.inputAccessoryView = toolbar
        fromField.inputView = datePicker
        
        toField.inputAccessoryView = toolbar2
        toField.inputView = datePicker
    }
    
    var datetime = ""
    
    @objc func doneFromDatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        fromField.text = formatter.string(from: datePicker.date)
        datetime = fromField.text!
     
        self.view.endEditing(true)
    }
    
    @objc func doneToDatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        toField.text = formatter.string(from: datePicker.date)
        datetime = toField.text!
 
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        fromField.resignFirstResponder()
        toField.resignFirstResponder()
    }
    
    
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterList!.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath as IndexPath) as! ListCell
        print(indexPath.row)
        cell.label.text = filterList![indexPath.row].statusName
        
        if filterList![indexPath.row].isSelected == false{
            cell.checkImg.image =  UIImage(named: "checkboxEmpty")
        }
        else{
            cell.checkImg.image =  UIImage(named: "checked-1")
        }
        
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        filterList![indexPath.row].isSelected = !filterList![indexPath.row].isSelected
        checkStatusSelection()
        tableView.reloadData()
    }
    
    
    
    
    func checkNone(index:Int){
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 50
    }
    
    
    @IBAction func actionDone(_ sender: Any) {
        self.filterPopupDelegate?.selectedOptionFromPopup(filteredList:filterList! , fromDate: fromField.text!, toDate: toField.text!)
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func actionClear(_ sender: Any) {
        fromField.text = ""
        toField.text = ""
    }
    
    
    @IBAction func selectAllAction(_ sender: Any) {
        let allSelected = checkStatusSelection()
        if allSelected == true{
            selectDeselect(toSelect:false)
            checkBox.setImage(UIImage(named:"unchecked"), for: .normal)
        }
        else{
            selectDeselect(toSelect:true)
            checkBox.setImage(UIImage(named:"checked"), for: .normal)
        }
    }
    
    
    func checkStatusSelection()->Bool{
         for opt in filterList!{
            if opt.isSelected == false{
            checkBox.setImage(UIImage(named:"unchecked"), for: .normal)
               return false
            }
        }
        checkBox.setImage(UIImage(named:"checked"), for: .normal)
        return true
    }
    
    
    func selectDeselect(toSelect:Bool){
        var i = 0
         for opt in filterList!{
             filterList![i].isSelected = toSelect
            i += 1
        }
         tableView.reloadData()
     }
    
    
    
    @objc func refresh() {
        self.tableView.reloadData()
    }
    
    
 }
