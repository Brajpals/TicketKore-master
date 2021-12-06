
import UIKit

extension UIView {
    
 
   
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
         let border = CALayer()
         border.backgroundColor = color.cgColor
         border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
         self.layer.addSublayer(border)
     }

     func addRightBorderWithColor(color: UIColor, width: CGFloat) {
         let border = CALayer()
         border.backgroundColor = color.cgColor
         border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width-10, height: self.frame.size.height)
         self.layer.addSublayer(border)
     }

    func addBottomBorderWithColor(color: UIColor, width: CGFloat , tillWidth: CGFloat) {
         let border = CALayer()
         border.backgroundColor = color.cgColor
         border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width - tillWidth, height: width)
         self.layer.addSublayer(border)
     }

     func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
         let border = CALayer()
         border.backgroundColor = color.cgColor
         border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
         self.layer.addSublayer(border)
     }
  
    
  
  func dropShadow(scale: Bool = true, shadowOpacity : Float ,  shadowRadius : CGFloat) {
      layer.masksToBounds = false
      layer.shadowColor = UIColor.black.cgColor
      layer.shadowOpacity = shadowOpacity
      layer.shadowOffset = .zero
      layer.shadowRadius = shadowRadius
      layer.shouldRasterize = true
      layer.rasterizationScale = scale ? UIScreen.main.scale : 1
  }
  
  
    func animateScaleIn(desiredView: UIView) {
      let backgroundView = superview
      backgroundView!.addSubview(desiredView)
      desiredView.center = backgroundView!.center
          desiredView.isHidden = false
          
          desiredView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
          desiredView.alpha = 0
          
          UIView.animate(withDuration: 0.2) {
              desiredView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
              desiredView.alpha = 1
  //            desiredView.transform = CGAffineTransform.identity
          }
      }
      
      /// Animates a view to scale out remove from the display
      func animateScaleOut(desiredView: UIView) {
          UIView.animate(withDuration: 0.2, animations: {
              desiredView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
              desiredView.alpha = 0
          }, completion: { (success: Bool) in
              desiredView.removeFromSuperview()
          })
          
          UIView.animate(withDuration: 0.2, animations: {
              
          }, completion: { _ in
              
          })
      }
    
    

    
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor ?? UIColor.white.cgColor)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            //            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable
    var makeCircular: Bool {
        get {
            return false
        }
        set {
            if newValue {
                layer.cornerRadius = self.frame.size.width/2.0
                //                layer.masksToBounds = true
            }
        }
    }
    
    @IBInspectable var makeAutoRound: Bool {
        get {
            return false
        }
        set {
            layer.cornerRadius = min(bounds.width, bounds.height)/2
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    func asImage() -> UIImage? {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
            defer { UIGraphicsEndImageContext() }
            guard let currentContext = UIGraphicsGetCurrentContext() else {
                return nil
            }
            self.layer.render(in: currentContext)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
    }
    
    
    func round(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    
}


@IBDesignable
final class GradientView: UIView {
    @IBInspectable var startColor: UIColor = UIColor.clear
    @IBInspectable var endColor: UIColor = UIColor.clear

    override func draw(_ rect: CGRect) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = CGRect(x: CGFloat(0),
                                y: CGFloat(0),
                                width: superview!.frame.size.width,
                                height: superview!.frame.size.height)
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.zPosition = -1
        layer.addSublayer(gradient)
    }
}
