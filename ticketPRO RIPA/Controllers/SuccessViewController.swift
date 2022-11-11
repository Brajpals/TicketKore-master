//
//  SuccessViewController.swift
//  ticketPRO RIPA
//
//  Created by Nitin on 5/7/21.
//

import UIKit

class SuccessViewController: UIViewController {

    @IBOutlet weak var backHomeBtn: UIButton!
    @IBOutlet weak var successLbl: UILabel!
    
    var viewType : String = ""
    var isPendingEdit:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewType == "Saved" || isPendingEdit{
            successLbl.text = "Your Ripa Report has been successfully Updated."
        }

        // Do any additional setup after loading the view.
        
        
        //Your Ripa Report has been successfully submitted.
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
    
    
    override func viewDidAppear(_ animated: Bool) {
        setGradientBackground()
     }
    
    func setGradientBackground() {
        //self.mainView.backgroundlayer()
        self.backHomeBtn.orangeGradientButton()
    }
    
 

    @IBAction func backHomeAction(_ sender: Any) {
        
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                    let navigationController = UINavigationController(rootViewController: nextViewController)
                    UIApplication.shared.windows.first?.rootViewController = navigationController
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
 
    }
}
