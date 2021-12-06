//
//  Extension.swift
//  ticketPRO RIPA
//
//  Created by Mamta yadav on 07/01/21.
//

import Foundation
import UIKit
import OTPFieldView

var vSpinner : UIView?
extension UIViewController{
    
    // MARK: -  Global Alert
    public func openAlert(title: String,
                          message: String,
                          alertStyle:UIAlertController.Style,
                          actionTitles:[String],
                          actionStyles:[UIAlertAction.Style],
                          actions: [((UIAlertAction) -> Void)]){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        for(index, indexTitle) in actionTitles.enumerated(){
            let action = UIAlertAction(title: indexTitle, style: actionStyles[index], handler: actions[index])
            alertController.addAction(action)
        }
        self.present(alertController, animated: true)
    }
    
    
 
    
    
    
    
    func dismissKeyboarOnClickBlank()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action: #selector(UIViewController.dismissKeyboardBlankArea))
        tap.cancelsTouchesInView = false; view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboardBlankArea()
    {
        view.endEditing(true)
    }
    
 }


//Empty Text Field check

extension UITextField {
    var isEmpty: Bool {
        return text?.isEmpty ?? true
    }
}



func getUIColor(hex: String, alpha: Double = 1.0) -> UIColor? {
    var cleanString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cleanString.hasPrefix("#")) {
        cleanString.remove(at: cleanString.startIndex)
    }
    
    if ((cleanString.count) != 6) {
        return nil
    }
    
    var rgbValue: UInt32 = 0
    Scanner(string: cleanString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}


extension DispatchQueue {

    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }

}

extension UITextField{
   @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}


extension UIView {
    func orangeGradientButton() {
        let colorTop = UIColor(red: 242 / 255.0, green: 171.0 / 255.0, blue: 27.0 / 255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 187.0 / 255.0, green: 95.0 / 255.0, blue: 2.0 / 255.0, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = 5
        //gradientLayer.frame = self.bounds
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    func disablebutton() {
        let colorTop = UIColor(red: 90.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 181.0 / 255.0, green: 181.0 / 255.0, blue: 181.0 / 255.0, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = 5
        //gradientLayer.frame = self.bounds
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    func blueGradientButton() {
        let colorTop = UIColor(red: 242 / 255.0, green: 171.0 / 255.0, blue: 27.0 / 255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 187.0 / 255.0, green: 95.0 / 255.0, blue: 2.0 / 255.0, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = 5
        //gradientLayer.frame = self.bounds
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    func  backgroundlayer() {
        let colorTop = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 89.0 / 255.0, green: 91.0 / 255.0, blue: 104.0 / 255.0, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        //gradientLayer.frame = self.bounds
        gradientLayer.frame = self.bounds
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        
        
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.red.cgColor,
                           UIColor.green.cgColor,
                           UIColor.black.cgColor]   // your colors go here
        gradient.locations = [0.0, 0.8, 1.0]
        gradient.frame = self.bounds
        self.layer.insertSublayer(gradient, at: 0)
    }
    
}






