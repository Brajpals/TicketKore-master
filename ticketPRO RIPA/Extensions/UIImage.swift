
import UIKit

extension UIImage {
    
    func maskWithColor(_ color: UIColor) -> UIImage? {
        let maskImage = self.cgImage
        let width = self.size.width
        let height = self.size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let bitmapContext = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) //needs rawValue of bitmapInfo
        
        bitmapContext?.clip(to: bounds, mask: maskImage!)
        bitmapContext?.setFillColor(color.cgColor)
        bitmapContext?.fill(bounds)
        
        if let cImage = bitmapContext?.makeImage() {
            let coloredImage = UIImage(cgImage: cImage)
            
            return coloredImage
        } else {
            return nil
        }
    }
    
    func resizeImage(targetSize: CGSize, completion: @escaping(_ image: UIImage) -> Void) {
        DispatchQueue.global(qos: .default).async {
            let size = self.size
            
            let widthRatio  = targetSize.width  / size.width
            let heightRatio = targetSize.height / size.height
            
            // Figure out what our orientation is, and use that to form the rectangle
            var newSize: CGSize
            if(widthRatio > heightRatio) {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
            }
            
            // This is the rect that we've calculated out and this is what is actually used below
            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
            
            // Actually do the resizing to the rect using the ImageContext stuff
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            self.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            DispatchQueue.main.async {
                completion(newImage!)
            }
        }
    }
    
    static func defaultProfile() -> UIImage? {
        return UIImage(named: "default_profile")
    }
    
    static func noImage() -> UIImage? {
        return UIImage(named: "no_image")
    }
}

extension UIImageView {
    
    @IBInspectable var imageColor: UIColor? {
        get { return nil }
        set(newValue) {
            if let color = newValue, let image = self.image?.maskWithColor(color) {
                self.image = image
            }
        }
    }
}

extension UIButton {
    
    @IBInspectable var imageColor: UIColor? {
        get { return nil }
        set(newValue) {
            if let color = newValue, let image = self.imageView?.image?.maskWithColor(color) {
                self.setImage(image, for: .normal)
            }
        }
    }
}
