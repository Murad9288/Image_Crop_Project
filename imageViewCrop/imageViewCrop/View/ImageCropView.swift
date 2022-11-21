//
//  ImageCropView.swift
//  imageViewCrop
//
//  Created by Md Murad Hossain on 19/11/22.
//

/****
 
 MARK: Email --> muradhossianm01@gmail.com
 
 ****/


import UIKit

// CropPickerView Delegate
protocol CropPickerViewDelegate: AnyObject {
    
    // Called when the image or error.
    //func cropPickerView(_ cropPickerView: ImageCropView, result: CropResult)
    func cropPickerView(_ cropPickerView: ImageCropView, didChange frame: CGRect)
}

extension CropPickerViewDelegate {
    func cropPickerView(_ cropPickerView: ImageCropView, didChange frame: CGRect) {

    }
}

@IBDesignable
class ImageCropView: UIView {
    
    var defaultWidth : CGFloat = 250
    var defaultHeight : CGFloat = 400
    var buttonSize = CGSize(width: 50, height: 50)
    var middleButtonSize = CGSize(width: 50, height: 50)
    var centerButtonSize = CGSize(width: 100, height: 100)
    
    // MARK: Public Property
    // Set Image
    
    @IBInspectable
    public var image: UIImage? {
        get {
            return self.imageView.image
        }
        set {
            self.imageView.image = newValue
            self.scrollView.setZoomScale(1, animated: false)
            if self.scrollView.delegate == nil {
                self.initVariables()
            }
            self.cropLineHidden(newValue)
            self.scrollView.layoutIfNeeded()
            self.dimLayerMask(animated: false)
            DispatchQueue.main.async { [weak self] in
                self?.imageMinAdjustment(animated: true)
            }
        }
    }
    
    // Background color of scroll
    @IBInspectable
    public var scrollViewBackgroundColor: UIColor? {
        get {
            return self.scrollView.backgroundColor
        }
        set {
            self.scrollView.backgroundColor = newValue
        }
    }
    
    // Background color of image
    @IBInspectable
    public var imageViewBackgroundColor: UIColor? {
        get {
            return self.imageView.backgroundColor
        }
        set {
            self.imageView.backgroundColor = newValue
        }
    }
    // Minimum zoom for scrolling
    @IBInspectable
    public var scrollViewMinimumZoomScale: CGFloat {
       get {
           return self.scrollView.minimumZoomScale
       }
       set {
           self.scrollView.minimumZoomScale = newValue
       }
    }
       
    // Maximum zoom for scrolling
    @IBInspectable
    public var scrollViewMaximumZoomScale: CGFloat {
       get {
           return self.scrollView.maximumZoomScale
       }
       set {
           self.scrollView.maximumZoomScale = newValue
       }
    }
    
    // MARK: Private Property
     lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        edgesConstraint(subView: scrollView)
        return scrollView
    }()
    
     lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        scrollView.addSubview(imageView)
        imageView.center = self.scrollView.center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.edgesConstraint(subView: imageView)
        scrollView.sizeConstraint(subView: imageView)
        return imageView
    }()
    
     lazy var dimView: CropDimView = {
        scrollView.alpha = 1
        let view = CropDimView()
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        edgesConstraint(subView: view)
        return  view
    }()
    
    // Color of dim view not in the crop area
    @IBInspectable
    public var dimBackgroundColor: UIColor? {
        get {
            return dimView.backgroundColor
        }
        set {
            dimView.backgroundColor = newValue
        }
    }
   
    //MARK: CropView Properities
    lazy var cropView: CropView = {
        dimView.alpha = 1
        let cropView = CropView()
        addSubview(cropView)
        cropView.translatesAutoresizingMaskIntoConstraints = false
        
        cropLeadingConstraint = leadingConstraint(subView: cropView,
                                                  constant: 0).priority(945)
        
        cropTrailingConstraint = trailingConstraint(subView: cropView,
                                                    constant: 0).priority(945)
        
        cropTopConstraint = topConstraint(subView: cropView,
                                          constant: 0).priority(945)
        
        cropBottomConstraint = bottomConstraint(subView: cropView,
                                                constant: 0).priority(945)
        
        cropLeadingInitialConstraint = leadingConstraint(subView: cropView,
                                                         constant: 0).priority(945)
        
        cropTrailingInitialConstraint = trailingConstraint(subView: cropView,
                                                           constant: 0).priority(945)
        
        cropTopInitialConstraint = topConstraint(subView: cropView,
                                                 constant: 0).priority(945)
        
        cropBottomInitialConstraint = bottomConstraint(subView: cropView, constant: 0).priority(945)
        
           return cropView
    }()
    
    public var isCrop = true {
        willSet {
            leftTopButton.isHidden = !newValue
            leftBottomButton.isHidden = !newValue
            rightTopButton.isHidden = !newValue
            rightBottomButton.isHidden = !newValue
            dimView.isHidden = !newValue
            cropView.isHidden = !newValue
            topButton.isHidden = !newValue
            bottomButton.isHidden = !newValue
            leftButton.isHidden = !newValue
            rightButton.isHidden = !newValue
        }
    }

    // Line color of crop view
    @IBInspectable
    public var cropLineColor: UIColor? {
        get {
            return cropView.lineColor
        }
        set {
            cropView.lineColor = newValue
            leftTopButton.edgeLine(newValue)
            leftBottomButton.edgeLine(newValue)
            rightTopButton.edgeLine(newValue)
            rightBottomButton.edgeLine(newValue)
        }
    }
    
    var cropLeadingConstraint: NSLayoutConstraint?
    var cropTrailingConstraint: NSLayoutConstraint?
    var cropTopConstraint: NSLayoutConstraint?
    var cropBottomConstraint: NSLayoutConstraint?
    var lineButtonTouchPoint: CGPoint?
    var cropLeadingInitialConstraint: NSLayoutConstraint?
    var cropTrailingInitialConstraint: NSLayoutConstraint?
    var cropTopInitialConstraint: NSLayoutConstraint?
    var cropBottomInitialConstraint: NSLayoutConstraint?
    
    // Side button and corner button of crop
    lazy var leftTopButton: LineButton = {
        let button = LineButton(.leftTop, buttonSize: buttonSize)
        let cropView = cropView
        addSubview(button)
        topConstraint(item: cropView, subView: button, constant: 10)
        leadingConstraint(item: cropView, subView: button, constant: 10)
        button.addTarget(self, action: #selector(self.cropButtonLeftTopDrag(_:forEvent:)), for: .touchDragInside)
        return button
    }()
    
    lazy var leftBottomButton: LineButton = {
        let button = LineButton(.leftBottom, buttonSize: buttonSize)
        let cropView = self.cropView
        addSubview(button)
        bottomConstraint(item: cropView, subView: button, constant: -14)
        leadingConstraint(item: cropView, subView: button, constant: 10)
        button.addTarget(self, action: #selector(self.cropButtonLeftBottomDrag(_:forEvent:)), for: .touchDragInside)
        return button
    }()
    
    lazy var rightTopButton: LineButton = {
        let button = LineButton(.rightTop, buttonSize: buttonSize)
        let cropView = self.cropView
        addSubview(button)
        topConstraint(item: cropView, subView: button, constant: 10)
        trailingConstraint(item: cropView, subView: button, constant: -10)
        button.addTarget(self, action: #selector(self.cropButtonRightTopDrag(_:forEvent:)), for: .touchDragInside)
        return button
    }()
    
    lazy var rightBottomButton: LineButton = {
        let button = LineButton(.rightBottom, buttonSize: buttonSize)
        let cropView = self.cropView
        addSubview(button)
        bottomConstraint(item: cropView, subView: button, constant: -14)
        trailingConstraint(item: cropView, subView: button, constant: -10)
        button.addTarget(self, action: #selector(self.cropButtonRightBottomDrag(_:forEvent:)), for: .touchDragInside)
        return button
    }()
    
    lazy var topButton: LineButton = {
        let button = LineButton(.top, buttonSize: middleButtonSize)
        let cropView = self.cropView
        addSubview(button)
        topConstraint(item: cropView, subView: button, constant: 20)
        centerXConstraint(item: cropView, subView: button)
        widthConstraint(constant: 50)
        button.addTarget(self, action: #selector(self.cropButtonTopDrag(_:forEvent:)), for: .touchDragInside)
        return button
    }()
    
    lazy var leftButton: LineButton = {
        let button = LineButton(.left, buttonSize: middleButtonSize)
        let cropView = self.cropView
        addSubview(button)
        centerYConstraint(item: cropView, subView: button)
        leadingConstraint(item: cropView, subView: button, constant: 10)
        heightConstraint(constant: 50)
        button.addTarget(self, action: #selector(self.cropButtonLeftDrag(_:forEvent:)), for: .touchDragInside)
        return button
    }()
    
    lazy var rightButton: LineButton = {
        let button = LineButton(.right, buttonSize: middleButtonSize)
        let cropView = self.cropView
        addSubview(button)
        centerYConstraint(item: cropView, subView: button)
        trailingConstraint(item: cropView, subView: button, constant: -10)
        heightConstraint(constant: 50)
        button.addTarget(self, action: #selector(self.cropButtonRightDrag(_:forEvent:)), for: .touchDragInside)
        return button
    }()
    
    lazy var bottomButton: LineButton = {
        let button = LineButton(.bottom, buttonSize: middleButtonSize)
        let cropView = self.cropView
        addSubview(button)
        bottomConstraint(item: cropView, subView: button, constant: -10)
        centerXConstraint(item: cropView, subView: button)
        widthConstraint(constant: 50)
        button.addTarget(self, action: #selector(self.cropButtonBottomDrag(_:forEvent:)), for: .touchDragInside)
        return button
    }()
        
    // MARK: Init
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        if scrollView.delegate == nil {
            initVariables()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        if scrollView.delegate == nil {
            initVariables()
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateConstraintsIfNeeded()
    }
    
    // MARK: Public Method
    /**
     crop method.
     If there is no image to crop, Error 404 is displayed.
     If there is no image in the crop area, Error 503 is displayed.
     If the image is successfully cropped, the success delegate or callback function is called.
     **/
    
    public func crop(_ handler: ((Error?, UIImage?) -> Void)? = nil) {
        guard let image = imageView.image else {
            let error = NSError(domain: "Image is empty.", code: 404, userInfo: nil)
            handler?(error, nil)
            return
        }
        
        DispatchQueue.main.async {
            let imageSize = self.imageView.frameForImageInImageViewAspectFit
            let widthRate =  self.bounds.width / imageSize.width
            let heightRate = self.bounds.height / imageSize.height
            var factor: CGFloat
            if widthRate < heightRate {
                
                factor = image.size.width / self.scrollView.frame.width
            } else {
                
                factor = image.size.height / self.scrollView.frame.height
            }
            
            let scale = 1 / self.scrollView.zoomScale
            let imageFrame = self.imageView.imageFrame
            let x = (self.scrollView.contentOffset.x + self.cropView.frame.origin.x - imageFrame.origin.x) * scale * factor
            let y = (self.scrollView.contentOffset.y + self.cropView.frame.origin.y - imageFrame.origin.y) * scale * factor
            let width = self.cropView.frame.size.width * scale * factor
            let height = self.cropView.frame.size.height * scale * factor
            let cropArea = CGRect(x: x, y: y, width: width, height: height)
            
            guard let cropCGImage = image.cgImage?.cropping(to: cropArea) else {
                let error = NSError(domain: "There is no image in the Crop area.", code: 503, userInfo: nil)
                handler?(error, nil)
                return
            }
            
            let cropImage = UIImage(cgImage: cropCGImage)
            handler?(nil, cropImage)
        }
    }
    
}
// MARK: Private Method Init
extension ImageCropView {
    // Side button and corner button group of crops
    var lineButtonGroup: [LineButton] {
        return [leftTopButton,
                leftBottomButton,
                rightTopButton,
                rightBottomButton,
                topButton,
                leftButton,
                bottomButton,
                rightButton]
    }

    // Init
    func initVariables() {
        
        scrollView.clipsToBounds = true
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
               
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
               
        cropLineHidden(self.image)
        
        //CropLineColor will be set below
        cropLineColor = self.cropLineColor ?? .white
        scrollViewMinimumZoomScale = 1.0
        scrollViewMaximumZoomScale = 5.0
        scrollViewBackgroundColor = .black
        imageViewBackgroundColor = .black
        dimBackgroundColor = self.dimBackgroundColor ?? UIColor(white: 0, alpha: 0.6)
        lineButtonGroup.forEach { (button) in
            button.delegate = self
                button.addTarget(self, action: #selector(self.cropButtonTouchDown(_:forEvent:)), for: .touchDown)
                button.addTarget(self, action: #selector(self.cropButtonTouchUpInside(_:forEvent:)), for: .touchUpInside)
        }
    }
    
    // Does not display lines when the image is nil.
    func cropLineHidden(_ image: UIImage?) {
        cropView.alpha = image == nil ? 0 : 1
        leftTopButton.alpha = image == nil ? 0 : 1
        leftBottomButton.alpha = image == nil ? 0 : 1
        rightBottomButton.alpha = image == nil ? 0 : 1
        rightTopButton.alpha = image == nil ? 0 : 1
        topButton.alpha = image == nil ? 0 : 1
        rightButton.alpha = image == nil ? 0 : 1
        bottomButton.alpha = image == nil ? 0 : 1
        leftButton.alpha = image == nil ? 0 : 1
     }
}

//MARK: ScrollViewDelegate Methods

extension ImageCropView : UIScrollViewDelegate{
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        if scrollView.zoomScale <= 1 {
            let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
            let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
            scrollView.contentInset = UIEdgeInsets(top: offsetY,
                                                   left: offsetX,
                                                   bottom: 0,
                                                   right: 0)
            
        } else {
            
            let imageSize = imageView.frameForImageInImageViewAspectFit
            if isImageRateHeightGreaterThan(imageSize) {
                let imageOffset = -imageSize.origin.y
                let scrollOffset = (scrollView.bounds.height - scrollView.contentSize.height) * 0.5
                
                if imageOffset > scrollOffset {
                    
                    scrollView.contentInset = UIEdgeInsets(top: imageOffset,
                                                           left: 0,
                                                           bottom: imageOffset,
                                                           right: 0)
                    
                } else {
                    scrollView.contentInset = UIEdgeInsets(top: scrollOffset,
                                                           left: 0,
                                                           bottom: scrollOffset,
                                                           right: 0)
                }
                
            } else {
                
                let imageOffset = -imageSize.origin.x
                let scrollOffset = (scrollView.bounds.width - scrollView.contentSize.width) * 0.5
                
                if imageOffset > scrollOffset {
                    scrollView.contentInset = UIEdgeInsets(top: 0,
                                                           left: imageOffset,
                                                           bottom: 0,
                                                           right: imageOffset)
                    
                } else {
                    
                    scrollView.contentInset = UIEdgeInsets(top: 0,
                                                           left: scrollOffset,
                                                           bottom: 0,
                                                           right: scrollOffset)
                }
            }
        }
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView,
                                        with view: UIView?,
                                        atScale scale: CGFloat) {
        
        cropLeadingInitialConstraint?.constant = 0
        cropTrailingInitialConstraint?.constant = 0
        cropTopInitialConstraint?.constant = 0
        cropBottomInitialConstraint?.constant = 0
    }

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

// MARK: Private Method Image
extension ImageCropView {
    // Modify the contentOffset of the scrollView so that the scroll view fills the image.
    private func imageRealSize(_ animated: Bool = false) {
        if imageView.image == nil { return }
        scrollView.setZoomScale(1, animated: false)
        
        let imageSize = imageView.frameForImageInImageViewAspectFit
        let widthRate =  bounds.width / imageSize.width
        let heightRate = bounds.height / imageSize.height
        if widthRate < heightRate {
            scrollView.setZoomScale(heightRate, animated: animated)
        } else {
            scrollView.setZoomScale(widthRate, animated: animated)
        }
        let x = scrollView.contentSize.width/2 - scrollView.bounds.size.width/2
        let y = scrollView.contentSize.height/2 - scrollView.bounds.size.height/2
        scrollView.contentOffset = CGPoint(x: x, y: y)
    }
}


// MARK: Private Method Crop

extension ImageCropView {
    func isImageRateHeightGreaterThan(_ imageSize: CGRect) -> Bool {
        let widthRate =  bounds.width / imageSize.width
        let heightRate = bounds.height / imageSize.height
        return widthRate < heightRate
    }
    // Max Image
    func imageMaxAdjustment(_ duration: TimeInterval = 0.4, animated: Bool) {
         imageAdjustment(.zero, duration: duration, animated: animated)
     }
     
     // Min Image
    func imageMinAdjustment(_ duration: TimeInterval = 0.4, animated: Bool) {
         var point: CGPoint
         let imageSize = imageView.frameForImageInImageViewAspectFit
         if isImageRateHeightGreaterThan(imageSize) {
             point = CGPoint(x: 0, y: imageSize.origin.y)
             
         } else {
             point = CGPoint(x: imageSize.origin.x, y: 0)
         }
         imageAdjustment(point, duration: duration, animated: animated)
     }
    
    func imageAdjustment(_ point: CGPoint,
                         duration: TimeInterval = 0.4,
                         animated: Bool) {
        
        cropLeadingConstraint?.constant = -point.x
        cropTrailingConstraint?.constant = point.x
        cropTopConstraint?.constant = -point.y
        cropBottomConstraint?.constant = point.y
        cropLeadingInitialConstraint?.constant = -point.x
        cropTrailingInitialConstraint?.constant = point.x
        cropTopInitialConstraint?.constant = -point.y
        cropBottomInitialConstraint?.constant = point.y
        
        if animated {
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: UIView.AnimationOptions.curveEaseInOut,
                           animations: {
                
                self.layoutIfNeeded()
                self.scrollView.layoutIfNeeded()
                self.scrollView.updateConstraintsIfNeeded()
                self.updateConstraintsIfNeeded()
            }, completion: nil)
        }
    }
}

// MARK: Private Method Dim
extension ImageCropView {
    
    // Modify the dim screen mask.
    func dimLayerMask(_ duration: TimeInterval = 0.4, animated: Bool) {
        guard let cropLeadingConstraint = cropLeadingConstraint,
            let cropTrailingConstraint = cropTrailingConstraint,
            let cropTopConstraint = cropTopConstraint,
            let cropBottomConstraint = cropBottomConstraint else { return }
        let width = scrollView.bounds.width - (-cropLeadingConstraint.constant + cropTrailingConstraint.constant)
        let height = scrollView.bounds.height - (-cropTopConstraint.constant + cropBottomConstraint.constant)
      

        for constraint in leftButton.constraints where constraint.firstAttribute == .height {
            constraint.constant = height - 100.0
        }
        
        for constraint in rightButton.constraints where constraint.firstAttribute == .height {
            constraint.constant = height - 100.0
        }
        
        for constraint in topButton.constraints where constraint.firstAttribute == .width {
            constraint.constant = width - 100.0
        }
        
        for constraint in bottomButton.constraints where constraint.firstAttribute == .width {
            constraint.constant = width - 100.0
        }
        
        dimView.layoutIfNeeded()
        
        let path = UIBezierPath(rect: CGRect(
            x: -cropLeadingConstraint.constant,
            y: -cropTopConstraint.constant,
            width: width,
            height: height
        ))
        
        path.append(UIBezierPath(rect: dimView.bounds))
        dimView.mask(path.cgPath, duration: duration, animated: animated)
    }
}

//MARK:  Crop LineView
class CropView: UIView {
    private let margin: CGFloat = 0
    private let lineSize: CGFloat = 4
    
    var lineColor: UIColor? = UIColor.cyan.withAlphaComponent(0.6) {
        willSet {
            topLineView.backgroundColor = newValue
            bottomLineView.backgroundColor = newValue
            leftLineView.backgroundColor = newValue
            rightLineView.backgroundColor = newValue
            horizontalRightLineView.backgroundColor = newValue
            horizontalLeftLineView.backgroundColor = newValue
            verticalTopLineView.backgroundColor = newValue
            verticalBottomLineView.backgroundColor = newValue
        }
    }
    
    lazy var topLineView: UIView = {
        let view = UIView()
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .leading,
                                         multiplier: 1,
                                         constant: margin).priority(950)
        )
        
        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: .trailing,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .trailing,
                                         multiplier: 1,
                                         constant: margin).priority(950)
        )
        
        
        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: .top,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .top,
                                         multiplier: 1,
                                         constant: margin).priority(950)
        )
        
        view.addConstraint(NSLayoutConstraint(item: view,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .height,
                                              multiplier: 1,
                                              constant: lineSize).priority(950)
        )
        
        return view
    }()
    
    lazy var leftLineView: UIView = {
        let view = UIView()
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .leading,
                                         multiplier: 1,
                                         constant: margin).priority(950)
        )
        
        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: .bottom,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .bottom,
                                         multiplier: 1,
                                         constant: margin).priority(950)
        )
        
        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: .top,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .top,
                                         multiplier: 1,
                                         constant: margin).priority(950)
        )
        
        view.addConstraint(NSLayoutConstraint(item: view,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .width,
                                              multiplier: 1,
                                              constant: lineSize).priority(950)
        )
        
        return view
    }()
    
    lazy var bottomLineView: UIView = {
        let view = UIView()
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .leading,
                                         multiplier: 1,
                                         constant: margin).priority(950)
        )
        
        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: .trailing,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .trailing,
                                         multiplier: 1,
                                         constant: margin).priority(950)
        )
        
        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: .bottom,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .top,
                                         multiplier: 1,
                                         constant: margin).priority(950)
        )
        
        view.addConstraint(NSLayoutConstraint(item: view,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .height,
                                              multiplier: 1,
                                              constant: lineSize).priority(950)
        )
        
        return view
    }()
    
    lazy var rightLineView: UIView = {
        let view = UIView()
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: .trailing,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .trailing,
                                         multiplier: 1,
                                         constant: margin).priority(950)
        )
        
        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: .bottom,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .bottom,
                                         multiplier: 1,
                                         constant: margin).priority(950)
        )
        
        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: .top,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .top,
                                         multiplier: 1,
                                         constant: margin).priority(950)
        )
        
        view.addConstraint(NSLayoutConstraint(item: view,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .width,
                                              multiplier: 1,
                                              constant: lineSize).priority(950)
        )
        
        return view
    }()
    
    lazy var horizontalLeftLineView: UIView = {
        let view = UIView()
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: horizontalLeftView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0).priority(950)
        )
        
        addConstraint(NSLayoutConstraint(item: bottomLineView,
                                         attribute: .top,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .bottom,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )
        
        addConstraint(NSLayoutConstraint(item: topLineView,
                                         attribute: .bottom,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .top,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )
        
        view.addConstraint(NSLayoutConstraint(item: view,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .width,
                                              multiplier: 1,
                                              constant: lineSize).priority(950)
        )
        
        return view
    }()
    
    lazy var horizontalRightLineView: UIView = {
        let view = UIView()
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: bottomLineView,
                                         attribute: .top,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .bottom,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )
        
        addConstraint(NSLayoutConstraint(item: topLineView,
                                         attribute: .bottom,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .top,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )
        
        view.addConstraint(NSLayoutConstraint(item: view,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .width,
                                              multiplier: 1,
                                              constant: lineSize).priority(950)
        )
        
        return view
    }()
    
    lazy var verticalTopLineView: UIView = {
        let view = UIView()
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: verticalTopView,
                                         attribute: .bottom,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .top,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )
        
        addConstraint(NSLayoutConstraint(item: leftLineView,
                                         attribute: .trailing,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .leading,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )
        
        addConstraint(NSLayoutConstraint(item: rightLineView,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .trailing,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )
        
        view.addConstraint(NSLayoutConstraint(item: view,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .height,
                                              multiplier: 1,
                                              constant: lineSize).priority(950)
        )
        
        return view
    }()
    
    lazy var verticalBottomLineView: UIView = {
        let view = UIView()
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: leftLineView,
                                         attribute: .trailing,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .leading,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )
        
        addConstraint(NSLayoutConstraint(item: rightLineView,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .trailing,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )
        
        view.addConstraint(NSLayoutConstraint(item: view,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .height,
                                              multiplier: 1,
                                              constant: lineSize).priority(950)
        )
        
        return view
    }()
    
    lazy var horizontalLeftView: UIView = {
        let view = UIView()
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: leftLineView,
                                         attribute: .trailing,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .leading,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )
        
        addConstraint(NSLayoutConstraint(item: bottomLineView,
                                         attribute: .top,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .bottom,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )
        
        addConstraint(NSLayoutConstraint(item: topLineView,
                                         attribute: .bottom,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .top,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )
        
        return view
    }()
    
    lazy var horizontalRightView: UIView = {
        let view = UIView()
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: horizontalRightLineView,
                                         attribute: .trailing,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .leading,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )
        
        addConstraint(NSLayoutConstraint(item: bottomLineView,
                                         attribute: .top,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .bottom,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )
        
        addConstraint(NSLayoutConstraint(item: topLineView,
                                         attribute: .bottom,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .top,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )
        
        addConstraint(NSLayoutConstraint(item: rightLineView,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .trailing,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )
        
        addConstraint(NSLayoutConstraint(item: horizontalLeftView,
                                         attribute: .width,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .width,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )
        
        return view
    }()
    
    lazy var verticalTopView: UIView = {
        let view = UIView()
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: topLineView,
                                         attribute: .bottom,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .top,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )
        
        addConstraint(NSLayoutConstraint(item: leftLineView,
                                         attribute: .trailing,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .leading,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )
        
        addConstraint(NSLayoutConstraint(item: rightLineView,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .trailing,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )
        
        return view
    }()
    
    lazy var verticalBottomView: UIView = {
        let view = UIView()
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: verticalBottomLineView,
                                         attribute: .bottom,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .top,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )
        
        addConstraint(NSLayoutConstraint(item: leftLineView,
                                         attribute: .trailing,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .leading,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )
        
        addConstraint(NSLayoutConstraint(item: rightLineView,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .trailing,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )
        
        addConstraint(NSLayoutConstraint(item: verticalTopView,
                                         attribute: .height,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .height,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )

        addConstraint(NSLayoutConstraint(item: bottomLineView,
                                         attribute: .top,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .bottom,
                                         multiplier: 1,
                                         constant: 0).priority(950)
        )
        
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initVars()
    }
    
    init() {
        super.init(frame: .zero)
        initVars()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initVars()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initVars() {
        isUserInteractionEnabled = false
        
        backgroundColor = .clear
        topLineView.alpha = 1
        leftLineView.alpha = 1
        rightLineView.alpha = 1
        bottomLineView.alpha = 1
        verticalTopView.alpha = 0
        horizontalLeftView.alpha = 0
        verticalBottomView.alpha = 0
        verticalTopLineView.alpha = 0
        horizontalRightView.alpha = 0
        verticalBottomLineView.alpha = 0
        horizontalLeftLineView.alpha = 0
        horizontalRightLineView.alpha = 0
    }
    
    func line(_ isHidden: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3) { [self] in
                
                if isHidden {
                    horizontalRightLineView.alpha = 0
                    horizontalLeftLineView.alpha = 0
                    verticalTopLineView.alpha = 0
                    verticalBottomLineView.alpha = 0
                } else {
                    horizontalRightLineView.alpha = 1
                    horizontalLeftLineView.alpha = 1
                    verticalTopLineView.alpha = 1
                    verticalBottomLineView.alpha = 1
                }
            }
            
        } else {
            
            if isHidden {
                horizontalRightLineView.alpha = 0
                horizontalLeftLineView.alpha = 0
                verticalTopLineView.alpha = 0
                verticalBottomLineView.alpha = 0
                
            } else {
                horizontalRightLineView.alpha = 1
                horizontalLeftLineView.alpha = 1
                verticalTopLineView.alpha = 1
                verticalBottomLineView.alpha = 1
            }
        }
    }
}

// CropDimView
class CropDimView: UIView {
    var path: CGPath?
    
    init() {
        super.init(frame: .zero)
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func mask(_ path: CGPath, duration: TimeInterval, animated: Bool) {
        
        self.path = path
        if let mask = layer.mask as? CAShapeLayer {
            mask.removeAllAnimations()
            
            if animated {
                let animation = CABasicAnimation(keyPath: "path")
                animation.delegate = self
                animation.fromValue = mask.path
                animation.toValue = path
                animation.byValue = path
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                animation.isRemovedOnCompletion = false
                animation.fillMode = .forwards
                animation.duration = duration
                mask.add(animation, forKey: "path")
                
            } else {
                mask.path = path
            }
            
        } else {
            let maskLayer = CAShapeLayer()
            maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
            maskLayer.backgroundColor = UIColor.clear.cgColor
            maskLayer.path = path
            layer.mask = maskLayer
        }
    }
}

// MARK: Private Method Touch Action

extension ImageCropView {
    
    // Center Button Double Tap
    @objc private func centerDoubleTap(_ sender: UITapGestureRecognizer) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.imageDoubleTap(sender)
        }
    }
    
    // ImageView Double Tap
    @objc private func imageDoubleTap(_ sender: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            imageRealSize(true)
            DispatchQueue.main.async {
                self.imageMaxAdjustment(animated: true)
            }
        } else {
            scrollView.setZoomScale(1, animated: true)
            DispatchQueue.main.async {
                self.imageMinAdjustment(animated: true)
            }
        }
    }
    
    
    
    @objc func cropButtonCenterDragEnded(_ sender: LineButton, forEvent event: UIEvent){
        cropLineColor = UIColor.red.withAlphaComponent(0.7)
        
    }
    
    @objc func cropButtonCenterDrag(_ sender: LineButton, forEvent event: UIEvent) {
        
        guard let cropLeadingConstraint = cropLeadingConstraint,
            let cropTrailingConstraint = cropTrailingConstraint,
            let cropTopConstraint = cropTopConstraint,
            let cropBottomConstraint = cropBottomConstraint else { return }
        guard let touchPoint = lineButtonTouchPoint,
                let currentPoint = event.touches(for: sender)?.first?.location(in: self) else { return }
        
        let lConstant = cropLeadingConstraint.constant - (currentPoint.x - touchPoint.x)
        let rConstant = cropTrailingConstraint.constant - (currentPoint.x - touchPoint.x)
        
        if (lConstant <= 0 || currentPoint.x - touchPoint.x > 0) &&
            (rConstant > 0 || currentPoint.x - touchPoint.x < 0) {
            self.cropLeadingConstraint?.constant = lConstant
            self.cropTrailingConstraint?.constant = rConstant
        }
        
        let tConstant = cropTopConstraint.constant - (currentPoint.y - touchPoint.y)
        let bConstant = cropBottomConstraint.constant - (currentPoint.y - touchPoint.y)
        
        if (tConstant <= 0 || currentPoint.y - touchPoint.y > 0) &&
            (bConstant > 0 || currentPoint.y - touchPoint.y < 0) {
            self.cropTopConstraint?.constant = tConstant
            self.cropBottomConstraint?.constant = bConstant
        }
        lineButtonTouchPoint = currentPoint
        dimLayerMask(animated: false)
    }

    
    func dragCenterButton(currentPoint : CGPoint,
                          touchPoint : CGPoint,
                          constraintX: (lead: NSLayoutConstraint,
                                        trail: NSLayoutConstraint),
                          constraintY: (top: NSLayoutConstraint,
                                        bottom: NSLayoutConstraint)) {
        
        var moveFrame : Bool = false

        let lConstant = constraintX.lead.constant - (currentPoint.x - touchPoint.x)
        let rConstant = constraintX.trail.constant - (currentPoint.x - touchPoint.x)
        let tConstant = constraintY.top.constant - (currentPoint.y - touchPoint.y)
        let bConstant = constraintY.bottom.constant - (currentPoint.y - touchPoint.y)
        
        if lConstant < self.cropLeadingInitialConstraint?.constant ?? 0 && rConstant > self.cropTrailingInitialConstraint?.constant ?? 0{
            if (lConstant <= 0 || currentPoint.x - touchPoint.x > 0) &&
                     (rConstant > 0 || currentPoint.x - touchPoint.x < 0) {
                moveFrame = true
                cropLeadingConstraint?.constant = lConstant
                cropTrailingConstraint?.constant = rConstant
            }
        }
        
        if tConstant < self.cropTopInitialConstraint?.constant ?? 0  && bConstant > self.cropBottomInitialConstraint?.constant ?? 0 {
            if (tConstant <= 0 || currentPoint.y - touchPoint.y > 0) &&
                     (bConstant > 0 || currentPoint.y - touchPoint.y < 0) {
                moveFrame = true
                cropTopConstraint?.constant = tConstant
                cropBottomConstraint?.constant = bConstant
            }
            
        }
        if moveFrame{
            moveFrame = false
            dimLayerMask(animated: false)
        }
        
    }

    // Touch Down Button
    @objc  func cropButtonTouchDown(_ sender: LineButton, forEvent event: UIEvent) {
        guard let touch = event.touches(for: sender)?.first else { return }
        lineButtonTouchPoint = touch.location(in: self.cropView)
        cropView.line(false, animated: true)
        dimLayerMask(animated: false)
        lineButtonGroup
            .filter { sender != $0 }
            .forEach { $0.isUserInteractionEnabled = false }
    }
    
    // Touch Up Inside Button
    @objc func cropButtonTouchUpInside(_ sender: LineButton, forEvent event: UIEvent) {
        lineButtonTouchPoint = nil
        cropView.line(true, animated: true)
        dimLayerMask(animated: false)
        lineButtonGroup
            .forEach { $0.isUserInteractionEnabled = true }
    }
    
    func cropButtonDrag(_ sender: LineButton, forEvent event: UIEvent) -> CGPoint? {
        guard let touch = event.touches(for: sender)?.first else { return nil }
        return touch.location(in: cropView)
    }
    
    @objc func cropButtonLeftTopDrag(_ sender: LineButton, forEvent event: UIEvent) {
        guard let cropLeadingConstraint = cropLeadingConstraint,
            let cropTrailingConstraint = cropTrailingConstraint,
            let cropTopConstraint =  cropTopConstraint,
            let cropBottomConstraint = cropBottomConstraint else { return }
        guard let touchPoint = lineButtonTouchPoint,
            let currentPoint = cropButtonDrag(sender, forEvent: event) else { return }
        
        self.dragLeftTopButton(currentPoint: currentPoint,
                               touchPoint: touchPoint,
                               constraintX: (lead: cropLeadingConstraint,
                                             trail: cropTrailingConstraint),
                               constraintY: (top: cropTopConstraint, bottom: cropBottomConstraint)
        )
        
    }
    
    func dragLeftTopButton(currentPoint : CGPoint,
                           touchPoint : CGPoint,
                           constraintX: (lead: NSLayoutConstraint,
                                         trail: NSLayoutConstraint),
                           constraintY: (top: NSLayoutConstraint,
                                         bottom: NSLayoutConstraint)){
        
        let hConstant = constraintX.lead.constant - (currentPoint.x - touchPoint.x)
        let vConstant = constraintY.top.constant - (currentPoint.y - touchPoint.y)
        if hConstant < self.cropLeadingInitialConstraint?.constant ?? 0 && vConstant < cropTopInitialConstraint?.constant ?? 0 {
            cropLeadingConstraint?.constant = hConstant
            cropTopConstraint?.constant = vConstant
            dimLayerMask(animated: false)
        }
    }
    
    @objc func cropButtonLeftBottomDrag(_ sender: LineButton, forEvent event: UIEvent) {
        guard let cropLeadingConstraint = cropLeadingConstraint,
            let cropTrailingConstraint = cropTrailingConstraint,
            let cropTopConstraint =  cropTopConstraint,
            let cropBottomConstraint =  cropBottomConstraint else { return }
        guard let touchPoint = lineButtonTouchPoint,
            let currentPoint = cropButtonDrag(sender, forEvent: event) else { return }
        
        self.dragLeftBottomButton(currentPoint: currentPoint,
                                  touchPoint: touchPoint,
                                  constraintX: (lead: cropLeadingConstraint,
                                                trail: cropTrailingConstraint),
                                  constraintY: (top: cropTopConstraint,
                                                bottom: cropBottomConstraint)
        )
        

    }
    
    func dragLeftBottomButton(currentPoint : CGPoint,
                              touchPoint : CGPoint,
                              constraintX: (lead: NSLayoutConstraint,
                                            trail: NSLayoutConstraint),
                              constraintY: (top: NSLayoutConstraint,
                                            bottom: NSLayoutConstraint)) {
        
        let hConstant = constraintX.lead.constant - (currentPoint.x - touchPoint.x)
        let vConstant = constraintY.bottom.constant - (currentPoint.y - touchPoint.y)
        if hConstant < self.cropLeadingInitialConstraint?.constant ?? 0 && vConstant > cropBottomInitialConstraint?.constant ?? 0 {
            
            lineButtonTouchPoint?.y = currentPoint.y
            cropLeadingConstraint?.constant = hConstant
            cropBottomConstraint?.constant = vConstant
            dimLayerMask(animated: false)
        }

    }
    
    @objc func cropButtonRightTopDrag(_ sender: LineButton, forEvent event: UIEvent) {
        guard let cropLeadingConstraint = cropLeadingConstraint,
            let cropTrailingConstraint = cropTrailingConstraint,
            let cropTopConstraint =  cropTopConstraint,
            let cropBottomConstraint =  cropBottomConstraint else { return }
        guard let touchPoint = lineButtonTouchPoint,
            let currentPoint = cropButtonDrag(sender, forEvent: event) else { return }
        
        self.dragRightTopButton(currentPoint: currentPoint,
                                touchPoint: touchPoint,
                                constraintX: (lead: cropLeadingConstraint,
                                              trail: cropTrailingConstraint),
                                constraintY: (top: cropTopConstraint,
                                              bottom: cropBottomConstraint)
        )
        
    }
    
    func dragRightTopButton(currentPoint : CGPoint,
                            touchPoint : CGPoint,
                            constraintX: (lead: NSLayoutConstraint,
                                          trail: NSLayoutConstraint),
                            constraintY: (top: NSLayoutConstraint,
                                          bottom: NSLayoutConstraint)) {
        
        let hConstant = constraintX.trail.constant - (currentPoint.x - touchPoint.x)
        let vConstant = constraintY.top.constant - (currentPoint.y - touchPoint.y)
        if hConstant > self.cropTrailingInitialConstraint?.constant ?? 0 && vConstant < cropTopInitialConstraint?.constant ?? 0 {
            lineButtonTouchPoint?.x = currentPoint.x
            cropTrailingConstraint?.constant = hConstant
            cropTopConstraint?.constant = vConstant
            dimLayerMask(animated: false)
        }
    }
    
    @objc func cropButtonRightBottomDrag(_ sender: LineButton, forEvent event: UIEvent) {
        guard let cropLeadingConstraint = cropLeadingConstraint,
        let cropTrailingConstraint = cropTrailingConstraint,
        let cropTopConstraint =  cropTopConstraint,
        let cropBottomConstraint =  cropBottomConstraint else { return }
        guard let touchPoint = lineButtonTouchPoint,
        let currentPoint = cropButtonDrag(sender, forEvent: event) else { return }
        
        self.dragRightBottomButton(currentPoint: currentPoint,
                                   touchPoint: touchPoint,
                                   constraintX: (lead: cropLeadingConstraint,
                                                 trail: cropTrailingConstraint),
                                   constraintY: (top: cropTopConstraint,
                                                 bottom: cropBottomConstraint)
        )
        
    }
    
    func dragRightBottomButton(currentPoint : CGPoint,
                               touchPoint : CGPoint,
                               constraintX: (lead: NSLayoutConstraint,
                                             trail: NSLayoutConstraint),
                               constraintY: (top: NSLayoutConstraint,
                                             bottom: NSLayoutConstraint)) {
        
        let hConstant = constraintX.trail.constant - (currentPoint.x - touchPoint.x)
        let vConstant = constraintY.bottom.constant - (currentPoint.y - touchPoint.y)
        if hConstant > self.cropTrailingInitialConstraint?.constant ?? 0 && vConstant > cropBottomInitialConstraint?.constant ?? 0 {
            lineButtonTouchPoint?.x = currentPoint.x
            lineButtonTouchPoint?.y = currentPoint.y
            cropTrailingConstraint?.constant = hConstant
            cropBottomConstraint?.constant = vConstant
            dimLayerMask(animated: false)
        }
    }
    
    @objc func cropButtonLeftDrag(_ sender: LineButton, forEvent event: UIEvent) {
        guard let cropLeadingConstraint = cropLeadingConstraint,
            let cropTrailingConstraint = cropTrailingConstraint else { return }
        guard let touchPoint = lineButtonTouchPoint,
            let currentPoint = cropButtonDrag(sender, forEvent: event) else { return }
        
        self.dragLeftButton(currentPoint: currentPoint,
                            touchPoint: touchPoint,
                            constraintX: (lead: cropLeadingConstraint,
                                          trail: cropTrailingConstraint)
        )
        
    }
    
    func dragLeftButton(currentPoint : CGPoint,
                        touchPoint : CGPoint,
                        constraintX: (lead: NSLayoutConstraint,
                                      trail: NSLayoutConstraint)) {
        
        let hConstant = constraintX.lead.constant - (currentPoint.x - touchPoint.x)
        if hConstant < self.cropLeadingInitialConstraint?.constant ?? 0 {
            cropLeadingConstraint?.constant = hConstant
            dimLayerMask(animated: false)
        }
    }
    
    @objc func cropButtonTopDrag(_ sender: LineButton, forEvent event: UIEvent) {
        guard let cropTopConstraint =  cropTopConstraint,
            let cropBottomConstraint =  cropBottomConstraint else { return }
        guard let touchPoint = lineButtonTouchPoint,
            let currentPoint = cropButtonDrag(sender, forEvent: event) else { return }
        
        self.dragTopButton(currentPoint: currentPoint,
                           touchPoint: touchPoint,
                           constraintY: (top: cropTopConstraint,
                                         bottom: cropBottomConstraint)
        )
        
        
    }
    
    func dragTopButton(currentPoint : CGPoint,
                       touchPoint : CGPoint,
                       constraintY: (top: NSLayoutConstraint,
                                     bottom: NSLayoutConstraint)) {
        
        let vConstant = constraintY.top.constant - (currentPoint.y - touchPoint.y)
        if vConstant < cropTopInitialConstraint?.constant ?? 0{
            cropTopConstraint?.constant = vConstant
            dimLayerMask(animated: false)
        }
    }
    
    @objc func cropButtonRightDrag(_ sender: LineButton, forEvent event: UIEvent) {
        guard let cropLeadingConstraint = cropLeadingConstraint,
            let cropTrailingConstraint = cropTrailingConstraint else { return }
        guard let touchPoint = lineButtonTouchPoint,
            let currentPoint = cropButtonDrag(sender, forEvent: event) else { return }
               
        self.dragRightButton(currentPoint: currentPoint,
                             touchPoint: touchPoint,
                             constraintX: (lead: cropLeadingConstraint,
                                           trail: cropTrailingConstraint)
        )
        

    }
    
    func dragRightButton(currentPoint : CGPoint,
                         touchPoint : CGPoint,
                         constraintX: (lead: NSLayoutConstraint,
                                       trail: NSLayoutConstraint)) {
        
        let hConstant = constraintX.trail.constant - (currentPoint.x - touchPoint.x)
        if hConstant > self.cropTrailingInitialConstraint?.constant ?? 0 {
            lineButtonTouchPoint?.x = currentPoint.x
            cropTrailingConstraint?.constant = hConstant
            dimLayerMask(animated: false)
        }
    }
    
    @objc func cropButtonBottomDrag(_ sender: LineButton, forEvent event: UIEvent) {
        guard let cropTopConstraint =  cropTopConstraint,
            let cropBottomConstraint = cropBottomConstraint else { return }
        guard let touchPoint = lineButtonTouchPoint,
            let currentPoint = cropButtonDrag(sender, forEvent: event) else { return }
        
        self.dragBottomButton(currentPoint: currentPoint,
                              touchPoint: touchPoint,
                              constraintY: (top: cropTopConstraint,
                                            bottom: cropBottomConstraint)
        )
        

    }
    
    func dragBottomButton(currentPoint : CGPoint,
                          touchPoint : CGPoint,
                          constraintY: (top: NSLayoutConstraint,
                                        bottom: NSLayoutConstraint)) {
        
        let vConstant = constraintY.bottom.constant - (currentPoint.y - touchPoint.y)
        if vConstant > cropBottomInitialConstraint?.constant ?? 0 {
            lineButtonTouchPoint?.y = currentPoint.y
            cropBottomConstraint?.constant = vConstant
            dimLayerMask(animated: false)
        }
    }
}

// MARK: CAAnimationDelegate
extension CropDimView: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let path = self.path else { return }
        if let mask = self.layer.mask as? CAShapeLayer {
            mask.removeAllAnimations()
            mask.path = path
        }
    }
}

// MARK: LineButtonDelegate
extension ImageCropView: LineButtonDelegate {
    // When highlighted on the line button disappears, Enable interaction for all buttons.
    func lineButtonUnHighlighted() {
        lineButtonTouchPoint = nil
        cropView.line(true, animated: true)
        dimLayerMask(animated: false)
        lineButtonGroup
            .forEach { $0.isUserInteractionEnabled = true }
    }
}

// Called when the button's highlighted is false.
protocol LineButtonDelegate: AnyObject {
    func lineButtonUnHighlighted()
}

// Side, Edge LineButton
class LineButton: UIButton {
    weak var delegate: LineButtonDelegate?
    private var type: ButtonLineType
    
    override var isHighlighted: Bool {
        didSet {
            if !self.isHighlighted {
                self.delegate?.lineButtonUnHighlighted()
            }
        }
    }
    
    // MARK: Init
    init(_ type: ButtonLineType, buttonSize : CGSize) {
        self.type = type
        super.init(frame: CGRect(x: 0,
                                 y: 0,
                                 width: buttonSize.width,
                                 height: buttonSize.height))
        
        self.setTitle(nil, for: .normal)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.alpha = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func edgeLine(_ color: UIColor?) {
        self.setImage(self.type.view(color)?.imageWithView?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
}

enum ButtonLineType {
    case center
    case leftTop, rightTop, leftBottom, rightBottom, top, left, right, bottom
    
    var rotate: CGFloat {
        switch self {
        case .leftTop:
            return 0
        case .rightTop:
            return CGFloat.pi/2
        case .rightBottom:
            return CGFloat.pi
        case .leftBottom:
            return CGFloat.pi/2*3
        case .top:
            return 0
        case .left:
            return CGFloat.pi/2*3
        case .right:
            return CGFloat.pi/2
        case .bottom:
            return CGFloat.pi
        case .center:
            return 0
        }
    }
    
    var yMargin: CGFloat {
        switch self {
        case .rightBottom, .bottom:
            return 1
        default:
            return 0
        }
    }
    
    var xMargin: CGFloat {
        switch self {
        case .leftBottom:
            return 1
        default:
            return 0
        }
    }
    
    func view(_ color: UIColor?) -> UIView? {
        var view: UIView?
        if self == .leftTop || self == .rightTop || self == .leftBottom || self == .rightBottom {
            view = ButtonLineType.EdgeView(self, color: color)
        } else {
            view = ButtonLineType.SideView(self, color: .clear)
        }
        view?.isOpaque = false
        view?.tintColor = color
        return view
    }
    
    class LineView: UIView {
        var type: ButtonLineType
        var color: UIColor?
        
        init(_ type: ButtonLineType, color: UIColor?) {
            self.type = type
            self.color = color
            super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func apply(_ path: UIBezierPath) {
            var pathTransform  = CGAffineTransform.identity
            pathTransform = pathTransform.translatedBy(x: 25, y: 25)
            pathTransform = pathTransform.rotated(by: self.type.rotate)
            pathTransform = pathTransform.translatedBy(x: -25 - self.type.xMargin, y: -25 - self.type.yMargin)
            path.apply(pathTransform)
            path.closed()
            path.strokeFill(self.color ?? .white)
        }
    }
    
    class EdgeView: LineView {
        override func draw(_ rect: CGRect) {
            let path = UIBezierPath()
                .move(5, 5)
                .line(5, 100)
                .line(8, 100)
                .line(8, 8)
                .line(100, 8)
                .line(100, 5)
                .line(5, 5)
             
            self.apply(path)
        }
    }
    
    class SideView: LineView {
        override func draw(_ rect: CGRect) {
            let path = UIBezierPath()
                .move(15, 6)
                .line(35, 6)
                .line(35, 8)
                .line(15, 8)
                .line(15, 6)
            self.apply(path)
        }
    }
}



