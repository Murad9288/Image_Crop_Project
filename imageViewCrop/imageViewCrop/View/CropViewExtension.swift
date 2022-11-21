//
//  CropViewExtension.swift
//  imageViewCrop
//
//  Created by Md Murad Hossain on 19/11/22.

/* MARK: Email --> muradhossianm01@gmail.com */

import UIKit

//MARK: Extending View to get constraint Value

extension UIView {
    var imageWithView: UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        if let cgContext = UIGraphicsGetCurrentContext() {
            self.layer.render(in: cgContext)
        }
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func edgesConstraint(subView: UIView, constant: CGFloat = 0) {
        leadingConstraint(subView: subView, constant: constant)
        trailingConstraint(subView: subView, constant: constant)
        topConstraint(subView: subView, constant: constant)
        bottomConstraint(subView: subView, constant: constant)
    }
    
    func sizeConstraint(subView: UIView, constant: CGFloat = 0) {
        widthConstraint(subView: subView, constant: constant)
        heightConstraint(subView: subView, constant: constant)
    }
    
    func sizeConstraint(constant: CGFloat = 0) {
        widthConstraint(constant: constant)
        heightConstraint(constant: constant)
    }
    
    @discardableResult
    func leadingConstraint(subView: UIView,
                           constant: CGFloat = 0,
                           multiplier: CGFloat = 1,
                           relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .leading,
                                            relatedBy: relatedBy,
                                            toItem: subView,
                                            attribute: .leading,
                                            multiplier: multiplier,
                                            constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func trailingConstraint(subView: UIView,
                            constant: CGFloat = 0,
                            multiplier: CGFloat = 1,
                            relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .trailing,
                                            relatedBy: relatedBy,
                                            toItem: subView,
                                            attribute: .trailing,
                                            multiplier: multiplier,
                                            constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func topConstraint(subView: UIView,
                       constant: CGFloat = 0,
                       multiplier: CGFloat = 1,
                       relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .top,
                                            relatedBy: relatedBy,
                                            toItem: subView,
                                            attribute: .top,
                                            multiplier: multiplier,
                                            constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func bottomConstraint(subView: UIView,
                          constant: CGFloat = 0,
                          multiplier: CGFloat = 1,
                          relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .bottom,
                                            relatedBy: relatedBy,
                                            toItem: subView,
                                            attribute: .bottom,
                                            multiplier: multiplier,
                                            constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func centerXConstraint(subView: UIView,
                           constant: CGFloat = 0,
                           multiplier: CGFloat = 1,
                           relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .centerX,
                                            relatedBy: relatedBy,
                                            toItem: subView,
                                            attribute: .centerX,
                                            multiplier: multiplier,
                                            constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func centerYConstraint(subView: UIView,
                           constant: CGFloat = 0,
                           multiplier: CGFloat = 1,
                           relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .centerY,
                                            relatedBy: relatedBy,
                                            toItem: subView,
                                            attribute: .centerY,
                                            multiplier: multiplier,
                                            constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func leadingConstraint(item: UIView,
                           subView: UIView,
                           constant: CGFloat = 0,
                           multiplier: CGFloat = 1,
                           relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: item,
                                            attribute: .leading,
                                            relatedBy: relatedBy,
                                            toItem: subView,
                                            attribute: .leading,
                                            multiplier: multiplier,
                                            constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func trailingConstraint(item: UIView,
                            subView: UIView,
                            constant: CGFloat = 0,
                            multiplier: CGFloat = 1,
                            relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: item,
                                            attribute: .trailing,
                                            relatedBy: relatedBy,
                                            toItem: subView,
                                            attribute: .trailing,
                                            multiplier: multiplier,
                                            constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func topConstraint(item: UIView,
                       subView: UIView,
                       constant: CGFloat = 0,
                       multiplier: CGFloat = 1,
                       relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: item,
                                            attribute: .top,
                                            relatedBy: relatedBy,
                                            toItem: subView,
                                            attribute: .top,
                                            multiplier: multiplier,
                                            constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func bottomConstraint(item: UIView,
                          subView: UIView,
                          constant: CGFloat = 0,
                          multiplier: CGFloat = 1,
                          relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: item,
                                            attribute: .bottom,
                                            relatedBy: relatedBy,
                                            toItem: subView,
                                            attribute: .bottom,
                                            multiplier: multiplier,
                                            constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func centerXConstraint(item: UIView,
                           subView: UIView,
                           constant: CGFloat = 0,
                           multiplier: CGFloat = 1,
                           relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: item,
                                            attribute: .centerX,
                                            relatedBy: relatedBy,
                                            toItem: subView,
                                            attribute: .centerX,
                                            multiplier: multiplier,
                                            constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func centerYConstraint(item: UIView,
                           subView: UIView,
                           constant: CGFloat = 0,
                           multiplier: CGFloat = 1,
                           relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: item,
                                            attribute: .centerY,
                                            relatedBy: relatedBy,
                                            toItem: subView,
                                            attribute: .centerY,
                                            multiplier: multiplier,
                                            constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func widthConstraint(item: UIView,
                         subView: UIView,
                         constant: CGFloat = 0,
                         multiplier: CGFloat = 1,
                         relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: item,
                                            attribute: .width,
                                            relatedBy: relatedBy,
                                            toItem: subView,
                                            attribute: .width,
                                            multiplier: multiplier,
                                            constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func heightConstraint(item: UIView,
                          subView: UIView,
                          constant: CGFloat = 0,
                          multiplier: CGFloat = 1,
                          relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: item,
                                            attribute: .height,
                                            relatedBy: relatedBy,
                                            toItem: subView,
                                            attribute: .height,
                                            multiplier: multiplier,
                                            constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func widthConstraint(subView: UIView,
                         constant: CGFloat = 0,
                         multiplier: CGFloat = 1,
                         relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .width,
                                            relatedBy: relatedBy,
                                            toItem: subView,
                                            attribute: .width,
                                            multiplier: multiplier,
                                            constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func heightConstraint(subView: UIView,
                          constant: CGFloat = 0,
                          multiplier: CGFloat = 1,
                          relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .height,
                                            relatedBy: relatedBy,
                                            toItem: subView,
                                            attribute: .height,
                                            multiplier: multiplier,
                                            constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func widthConstraint(constant: CGFloat = 0,
                         multiplier: CGFloat = 1,
                         relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .width,
                                            relatedBy: relatedBy,
                                            toItem: nil,
                                            attribute: .width,
                                            multiplier: multiplier,
                                            constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func heightConstraint(constant: CGFloat = 0,
                          multiplier: CGFloat = 1,
                          relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .height,
                                            relatedBy: relatedBy,
                                            toItem: nil,
                                            attribute: .height,
                                            multiplier: multiplier,
                                            constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
}
extension NSLayoutConstraint {
    func priority(_ value: CGFloat) -> NSLayoutConstraint {
        self.priority = UILayoutPriority(Float(value))
        return self
    }
}
extension UIBezierPath {
    @discardableResult
    func move(_ x: CGFloat, _ y: CGFloat) -> UIBezierPath{
        self.move(to: CGPoint(x: x, y: y))
        return self
    }
    
    @discardableResult
    func line(_ x: CGFloat, _ y: CGFloat) -> UIBezierPath {
        self.addLine(to: CGPoint(x: x, y: y))
        return self
    }
    
    @discardableResult
    func closed() -> UIBezierPath {
        self.close()
        return self
    }
    
    @discardableResult
    func strokeFill(_ color: UIColor, lineWidth: CGFloat = 1) -> UIBezierPath {
        color.set()
        self.lineWidth = lineWidth
        self.stroke()
        self.fill()
        return self
    }
    
    @discardableResult
    func stroke(_ color: UIColor, lineWidth: CGFloat = 1) -> UIBezierPath {
        color.set()
        self.lineWidth = lineWidth
        self.stroke()
        return self
    }
}
//MARK: Extending FrameworkClasses
//MARK:UIIMageView Extension to get Frame
extension UIImageView {
    var frameForImageInImageViewAspectFit: CGRect {
        if  let img = self.image {
            let imageRatio = img.size.width / img.size.height
            let viewRatio = self.frame.size.width / self.frame.size.height
            if(imageRatio < viewRatio) {
                let scale = self.frame.size.height / img.size.height
                let width = scale * img.size.width
                let topLeftX = (self.frame.size.width - width) * 0.5
                return CGRect(x: topLeftX, y: 0, width: width, height: self.frame.size.height)
            } else {
                let scale = self.frame.size.width / img.size.width
                let height = scale * img.size.height
                let topLeftY = (self.frame.size.height - height) * 0.5
                return CGRect(x: 0, y: topLeftY, width: self.frame.size.width, height: height)
            }
        }
        return CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    
    var imageFrame: CGRect {
        let imageViewSize = self.frame.size
        guard let imageSize = self.image?.size else { return CGRect.zero }
        let imageRatio = imageSize.width / imageSize.height
        let imageViewRatio = imageViewSize.width / imageViewSize.height
        if imageRatio < imageViewRatio {
            let scaleFactor = imageViewSize.height / imageSize.height
            let width = imageSize.width * scaleFactor
            let topLeftX = (imageViewSize.width - width) * 0.5
            return CGRect(x: topLeftX, y: 0, width: width, height: imageViewSize.height)
        } else {
            let scalFactor = imageViewSize.width / imageSize.width
            let height = imageSize.height * scalFactor
            let topLeftY = (imageViewSize.height - height) * 0.5
            return CGRect(x: 0, y: topLeftY, width: imageViewSize.width, height: height)
        }
    }
}
