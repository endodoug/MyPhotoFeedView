//
//  PhotoMotionView.swift
//  FlickrFeed
//
//  Created by Christopher Griffith on 8/25/16.
//  Copyright © 2016 AltU. All rights reserved.
//

import UIKit
import CoreMotion

@IBDesignable
class PhotoMotionView: UIView {

	var motionManager: CMMotionManager?
	var scrollView = UIScrollView()
	var contentView = UIImageView()
	var motionRate: Double = 0.0
	var minimumXOffset: Float = 0.0
	var maximumXOffset: Float = 0.0
	
	var isMotionEnabled: Bool = true
	
	let motionViewRotationMinimumTreshold: Double = 0.1
	let motionGyroUpdateInterval: Double = 1 / 100
	let motionViewRotationFactor: Double = 6.0
	
	@IBInspectable
	var image: UIImage? {
		didSet {
			contentView.image = image
			setNeedsLayout()
			startMonitoring()
		}
	}
	
	override var backgroundColor: UIColor? {
		get {
			return scrollView.backgroundColor
		}
		set {
			scrollView.backgroundColor = newValue
		}
	}
	
	override var contentMode: UIViewContentMode {
		get {
			return contentView.contentMode
		}
		set {
			contentView.contentMode = newValue
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder:NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		scrollView.isScrollEnabled = false
		scrollView.bounces = false
		scrollView.contentSize = CGSize.zero
		scrollView.isExclusiveTouch = true
		self.addSubview(scrollView)
		
		scrollView.addSubview(contentView)
		
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		
		topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
		bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
		leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
		rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
		
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		if let image = image {
			
			contentView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
			
			let scaleFactor = contentView.imageScaleFactor()
			let scaledImageWidth = image.size.width * scaleFactor
			var overhang:CGFloat = 0.0
			
			if scaledImageWidth > contentView.frame.size.width {
				overhang = scaledImageWidth - contentView.frame.size.width
			}
			
			scrollView.contentSize = CGSize(width: (contentView.frame.size.width + overhang ), height: (scrollView.frame.size.height))
			motionRate = Double(contentView.frame.size.width / self.frame.size.width) * self.motionViewRotationFactor
			minimumXOffset = (Float(overhang / 2) > 0) ? Float(overhang / 2) * -1 : 0.0
			maximumXOffset = Float(overhang / 2)
			scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y), animated: false)
		}
	}
	
	// MARK: Core Motion
	
	private func startMonitoring() {
		
		if motionManager == nil {
			motionManager = CMMotionManager()
			motionManager?.gyroUpdateInterval = motionGyroUpdateInterval
		}
		
		if isMotionEnabled {
			
			if !(motionManager?.isGyroActive)! && (motionManager?.isGyroAvailable)! {
				
				motionManager?.startGyroUpdates(to: OperationQueue.current!, withHandler: { (gyroData, error) in
					
					let rotationRate = (gyroData?.rotationRate.y)!
					
					if fabs(rotationRate) >= self.motionViewRotationMinimumTreshold {
						
						var offsetX = self.scrollView.contentOffset.x - CGFloat((rotationRate * self.motionRate))
						if offsetX > CGFloat(self.maximumXOffset) {
							offsetX = CGFloat(self.maximumXOffset)
						} else if offsetX < CGFloat(self.minimumXOffset) {
							offsetX = CGFloat(self.minimumXOffset)
						}
						
						UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState, .curveEaseOut], animations: {
							let offsetPoint = CGPoint(x: offsetX, y: self.scrollView.contentOffset.y)
							self.scrollView.setContentOffset(offsetPoint, animated: false)
							}, completion: nil)
					}
				})
				
			}
			
		}
	}
}

extension UIImageView {
	
	func imageScaleFactor() -> CGFloat {
		guard let image = self.image else {
			return 0.0
		}
		
		let widthScale = self.bounds.size.width / image.size.width
		let heightScale = self.bounds.size.height / image.size.height
		
		if self.contentMode == .scaleToFill {
			return (widthScale == heightScale) ? widthScale : 1.0
		}
		if self.contentMode == .scaleAspectFit {
			return min(widthScale, heightScale)
		}
		if self.contentMode == .scaleAspectFill {
			return max(widthScale, heightScale)
		}
		
		return CGFloat(1.0)
	}
	
}
