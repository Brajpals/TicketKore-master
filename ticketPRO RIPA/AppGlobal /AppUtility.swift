
import UIKit
import MBProgressHUD
import IQKeyboardManagerSwift

class AppUtility {
    
    
    func setRootView(view:String) {
         let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: view) as! EnrollementViewController
        UIApplication.shared.windows.first?.rootViewController = viewController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
     }
    
    class func showProgress(_ view:  UIView? = nil, title: String?){
        var hud: MBProgressHUD?
        if view != nil {
            hud = MBProgressHUD.showAdded(to: view!, animated: true)
        }else {
            if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
                hud = MBProgressHUD.showAdded(to: window, animated: true)
            } else if let window = UIApplication.shared.windows.last {
                hud = MBProgressHUD.showAdded(to: window, animated: true)
            }
        }
        
        hud?.bezelView.color = UIColor.black.withAlphaComponent(0.4)
        hud?.bezelView.style = .solidColor
        hud?.label.textColor = UIColor.white
        hud?.contentColor = .white
        hud?.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        
        if title != nil {
            hud!.label.text = title
        }
        hud!.show(animated: true)
    }
    
    
    class func hideProgress(_ view: UIView? = nil){
        if view != nil {
            MBProgressHUD.hide(for: view!, animated: true)
        }else {
            if let window = UIApplication.shared.keyWindow {
                MBProgressHUD.hide(for: window, animated: true)
            } else if let window = UIApplication.shared.windows.last {
                MBProgressHUD.hide(for: window, animated: true)
            }
        }
    }
    
    class func showAlertWithProperty(_ title: String, messageString: String) -> Void {
        let alertController = UIAlertController.init(title: title, message: messageString, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
         DispatchQueue.main.async{
            UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
        }
      }
    
    
    
    func changeDefaultButtonBackground (Button: UIButton) {
         //Button.layer.sublayers?.remove(at: 0)
         if let layer = Button.layer.sublayers? .first {
            print ("Button.layer.sublayers:", Button.layer.sublayers as Any)
             layer.removeFromSuperlayer ()
         }
     }
   
    
    class func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    class func hasNoSpecialCharacter(text: String) -> Bool {
        let specialRegEx = "\\p{L}+(?:[\\W_]\\p{L}+)*"
        
        let stringTest = NSPredicate(format:"SELF MATCHES %@", specialRegEx)
        return stringTest.evaluate(with: text)
    }
    
    class func isStrongPassword(text: String) -> Bool {
       // let regex = "(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@\\$%^&*-]).{8,}"
        
         let regex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{6,}$"
        
        let stringTest = NSPredicate(format:"SELF MATCHES %@", regex)
        return stringTest.evaluate(with: text)
    }
    
    class func isValidPhone(phone: String) -> Bool {
                   let PHONE_REGEX = "^[0-9+]{0,1}+[0-9]{5,16}$"
                  let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
                  let result = phoneTest.evaluate(with: phone)
                  return result
            
    }
    
    class func matchedWithTopViewControllerType(classType: AnyClass) -> Bool {
        return (UIApplication.shared.windows.first?.rootViewController as? UINavigationController)?.children.last?.isKind(of: classType) ?? false
    }
    
   
    
    class func isiPad() -> Bool {
        if UIDevice.current.model == "iPad" || UIDevice.current.model == "iPad Simulator" {
            return true
        }
        return false
    }
    
    class func isSimulator() -> Bool {
        var simulatorStatus = false
        #if targetEnvironment(simulator)
        simulatorStatus = true
        #endif
        return simulatorStatus
    }
    
   
    
    static func getPhoneWithCountryCode(value: String) -> String {
        if value.count >= 10 {
            let finalValue = value.suffix(10)
            return ""+finalValue
        }
        return ""
    }
    
    static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    static func isValidUrl (urlString: String?) -> Bool {
        if let urlString = urlString, let url = URL(string: urlString) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    
  
    
}




//MARK: Navigation methods
extension AppUtility {
    
//    static func navigationContains(controllerClass: AnyClass) -> Bool {
//        var isContains = false
//        for controller in UIApplication.topViewController()?.navigationController?.viewControllers ?? [] {
//            if controller.isKind(of: controllerClass) {
//                isContains = true
//                break
//            }
//        }
//        return isContains
//    }
}

extension UINavigationController {

  func popToViewController(ofClass: AnyClass, animated: Bool = true) {
    if let vc = viewControllers.filter({$0.isKind(of: ofClass)}).last {
      popToViewController(vc, animated: animated)
    }
  }

  func popViewControllers(viewsToPop: Int, animated: Bool = true) {
    if viewControllers.count > viewsToPop {
      let vc = viewControllers[viewControllers.count - viewsToPop - 1]
      popToViewController(vc, animated: animated)
    }
  }

}

 

extension UIViewController {
    func showAlertMessage(titleStr:String, messageStr:String) {
        let alert = UIAlertController(title: titleStr, message: messageStr, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    public func setRootView(view:String) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "BottomTabBar") as! EnrollementViewController
        UIApplication.shared.windows.first?.rootViewController = viewController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
     }
    
    public func setNavigationBar( hide: Bool,view:String) {
    navigationController?.setNavigationBarHidden(hide, animated: true)
    self.navigationController?.navigationBar.topItem?.title = view
    navigationController?.navigationBar.barTintColor =  #colorLiteral(red: 0.2279148102, green: 0.6577388644, blue: 0.9657549262, alpha: 1)
    UINavigationBar.appearance().tintColor = UIColor.white
    self.navigationController?.navigationBar.isTranslucent = false
    UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
    
}



