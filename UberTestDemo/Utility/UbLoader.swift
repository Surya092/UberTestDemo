//
//  UbLoader.swift
//  UberTestDemo
//
//  Created by Suryanarayan Sahu on 12/12/18.
//  Copyright © 2018 Suryanarayan Sahu. All rights reserved.
//

import UIKit

class UbLoader: UIView {
    
    var progressView = UIView()
    var progressViewWidth: CGFloat = 0.0
    let progressViewHeight: CGFloat = 3.0
    let progressViewLowerLimit = 0.5
    let progressMultiplicationFactor: Double = 5
    let progressStepFactor: Double = 0.2
    let movementDuration = 0.8
    let constantPeakValueCount = 10
    let midTimeValue: Double = 0.6
    var bothEndTimeValues: Double = 0
    var progressViewWidthArray = [Double]()
    var progressViewTimeArray = [Double]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //Configure the View
    func configureView(onView superView: UIView) {
        self.frame =  CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: progressViewHeight)
        superView.addSubview(self)
        self.isHidden = true
        setupProgressViewFrame()
        backgroundColor = UIColor.clear
        bothEndTimeValues = 1 - midTimeValue
        progressViewWidthArray.removeAll()
        progressViewTimeArray.removeAll()
        setTimeWidthValues()
    }
    
    //Set up Progress View
    private func setupProgressViewFrame() {
        progressView.backgroundColor = UIColor.black
        progressViewWidth = self.frame.size.width * 0.05
        progressView.frame = CGRect.init(x: self.frame.origin.x, y: 0, width: progressViewWidth, height: progressViewHeight)
        self.addSubview(progressView)
    }
    
    //Start Animation
    func startAnimating() {
        self.isHidden = false
        startViewMovement()
    }
    
    //Start Animation
    private func startViewMovement() {
        
        //Animation for movement
        let leftStart                        = CABasicAnimation(keyPath: "position.x")
        leftStart.fromValue                  = self.frame.origin.x
        leftStart.toValue                    = self.frame.size.width
        leftStart.duration                   = movementDuration
        leftStart.isRemovedOnCompletion      = false
        leftStart.timingFunction             = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        
        //Animation For Scaling
        let scaleAnimation                   = CAKeyframeAnimation(keyPath: "transform.scale.x")
        scaleAnimation.values                = progressViewWidthArray
        scaleAnimation.keyTimes              = progressViewTimeArray as [NSNumber]
        scaleAnimation.duration              = leftStart.beginTime + leftStart.duration
        scaleAnimation.fillMode              = CAMediaTimingFillMode.forwards
        scaleAnimation.timingFunctions       = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)]
        
        //Grouping into CATransaction
        let pathAnim                         = CAAnimationGroup()
        pathAnim.animations                  = [leftStart,scaleAnimation]
        pathAnim.duration                    = leftStart.duration
        pathAnim.fillMode                    = CAMediaTimingFillMode.forwards
        pathAnim.isRemovedOnCompletion       = false
        pathAnim.repeatCount                 = Float.infinity
        pathAnim.autoreverses                = true
        pathAnim.timingFunction              = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        CATransaction.begin()
        self.progressView.layer.add(pathAnim, forKey: "basic")
        CATransaction.commit()
        
    }
    
    //Get Key Timing Values
    private func setTimeWidthValues() {
        
        //Initialize Values
        let upperLimit = progressMultiplicationFactor * progressViewLowerLimit
        
        //Set up Initial Values
        for value in stride(from: progressViewLowerLimit, to: upperLimit, by: progressStepFactor) {
            progressViewWidthArray.append(value)
        }
        
        //Store Initial Element Count
        let startElementCount = progressViewWidthArray.count
        
        //Merge and Add Values
        let existingArray = progressViewWidthArray
        let constantArray = [Double](repeating: upperLimit, count: constantPeakValueCount)
        let newArray  = existingArray + constantArray
        progressViewWidthArray = newArray.compactMap({$0})
        
        let currentElementCount = progressViewWidthArray.count
        
        //Set up Final Values
        for value in stride(from: upperLimit, to: progressViewLowerLimit, by: -progressStepFactor) {
            progressViewWidthArray.append(value)
        }
        
        //Store Final Element Count
        let finalElementCount = progressViewWidthArray.count - currentElementCount
        
        //Store Mid Element Count
        let midElementCount = progressViewWidthArray.count - finalElementCount - startElementCount
        
        //Logic to set up Time contours
        
        //Initial Time Values
        let initialStepFactor = bothEndTimeValues * 0.5 / Double(startElementCount)
        for value in stride(from: 0, to: bothEndTimeValues * 0.5, by: initialStepFactor) {
            progressViewTimeArray.append(value)
        }
        
        //Mid Time Values
        let midStepFactor = (1 - bothEndTimeValues) / Double(midElementCount)
        for value in stride(from: bothEndTimeValues * 0.5, to: 1 - (bothEndTimeValues * 0.5), by: midStepFactor) {
            progressViewTimeArray.append(value)
        }
        
        //Last Time Values
        let finalStepFactor = bothEndTimeValues * 0.5 / Double(finalElementCount)
        for value in stride(from: 1 - (bothEndTimeValues * 0.5), to: 1, by: finalStepFactor) {
            progressViewTimeArray.append(value)
        }
        
    }
    
    func stopAnimating() {
        self.isHidden = true
        self.progressView.layer.removeAllAnimations()
        layer.removeAllAnimations()
    }
    
}
 
