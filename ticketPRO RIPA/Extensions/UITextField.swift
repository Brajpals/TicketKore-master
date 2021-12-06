//
//  UITextField.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 19/11/21.
//

import UIKit

extension UITextField {
    
func setHeight(_ h:CGFloat, animateTime:TimeInterval?=nil) {

    if let c = self.constraints.first(where: { $0.firstAttribute == .height && $0.relation == .equal }) {
        c.constant = CGFloat(h)

        if let animateTime = animateTime {
            UIView.animate(withDuration: animateTime, animations:{
                self.superview?.layoutIfNeeded()
            })
        }
        else {
            self.superview?.layoutIfNeeded()
        }
    }
}

    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }

}

