//
//  ZoomTransitionController.swift
//  MyPhotoFeedView
//
//  Created by doug harper on 10/3/16.
//  Copyright © 2016 Doug Harper. All rights reserved.
//

import UIKit

class ZoomTransitionController: NSObject {
  var operation: UINavigationControllerOperation!
  var sourceView: UIView!
}

extension ZoomTransitionController: UINavigationControllerDelegate {
  func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    self.operation = operation
    if (toVC as? PhotoDetailViewController == nil && fromVC as? PhotoDetailViewController == nil) {
      return nil
    }
    return self
  }
}

extension ZoomTransitionController: UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.5
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let containerView = transitionContext.containerView
    guard let fromView = transitionContext.view(forKey: .from),
      let toView = transitionContext.view(forKey: .to),
      let fromViewController = transitionContext.viewController(forKey: .from),
      let toViewController = transitionContext.viewController(forKey: .to) else { return }
    
    let finalFrame = transitionContext.finalFrame(for: toViewController)
    let cellFrame = containerView.convert(sourceView.bounds, from: sourceView)
    
    let fromViewSnapshot = fromView.snapshotView(afterScreenUpdates: false)!
    fromViewSnapshot.layer.anchorPoint = CGPoint(x: cellFrame.midX / containerView.frame.width, y: cellFrame.midY / containerView.frame.height)
    fromViewSnapshot.frame = transitionContext.initialFrame(for: fromViewController)
    containerView.addSubview(fromViewSnapshot)
    fromView.removeFromSuperview()
    
    let toViewSnapshot = toView.snapshotView(afterScreenUpdates: true)!
    var scale = finalFrame.width / cellFrame.width
    var offset = CGPoint(x: finalFrame.midX - cellFrame.midX, y: finalFrame.midY - cellFrame.midY)
    let createTransforms = { () -> (CGAffineTransform, CGAffineTransform) in
      let scaleTransform = CGAffineTransform(scaleX: 1/scale, y: 1/scale)
      let translationTransform = CGAffineTransform(translationX: -offset.x, y: -offset.y)
      return (scaleTransform, translationTransform)
    }
    if operation == .pop {
      scale = 1 / scale
      offset = CGPoint(x: -offset.x, y: -offset.y)
      let (scaleTransform, translationTransform) = createTransforms()
      toViewSnapshot.transform = translationTransform.concatenating(scaleTransform)
      containerView.insertSubview(toViewSnapshot, belowSubview: fromViewSnapshot)
    } else {
      toViewSnapshot.alpha = 0
      containerView.addSubview(toViewSnapshot)
      let (scaleTransform, translationTransform) = createTransforms()
      toViewSnapshot.transform = scaleTransform.concatenating(translationTransform)
    }
    
    UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext), delay: 0, options: [], animations:
      {
        if self.operation == .pop {
          UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.15, animations: {
            fromViewSnapshot.alpha = 0
          })
          fromViewSnapshot.transform = CGAffineTransform(translationX: offset.x, y: offset.y).concatenating(CGAffineTransform(scaleX: scale, y: scale))
        } else {
          UIView.addKeyframe(withRelativeStartTime: 0.85, relativeDuration: 0.15, animations: {
            toViewSnapshot.alpha = 1
          })
          fromViewSnapshot.transform = CGAffineTransform(translationX: offset.x, y: offset.y).scaledBy(x: scale, y: scale)
        }
        toViewSnapshot.transform = CGAffineTransform.identity
    }) { (finished) in
      containerView.insertSubview(toView, belowSubview: toViewSnapshot)
      toViewSnapshot.removeFromSuperview()
      fromViewSnapshot.removeFromSuperview()
      
      transitionContext.completeTransition(finished)
    }
  }
}
