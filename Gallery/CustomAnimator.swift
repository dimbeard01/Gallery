//
//  CustomAnimator.swift
//  Gallery
//
//  Created by Dima Surkov on 06.01.2020.
//  Copyright © 2020 Dima Surkov. All rights reserved.
//

import UIKit

class CustomAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    var duration : TimeInterval
    var isPresenting : Bool
    var originFrame : CGRect
    var image : UIImage
    var previewImage: CGRect
    
        init(duration : TimeInterval, isPresenting : Bool, originFrame : CGRect, image : UIImage, previewImage: CGRect) {
        self.duration = duration
        self.isPresenting = isPresenting
        self.originFrame = originFrame
        self.image = image
        self.previewImage = previewImage
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        
        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else { return }
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else { return }
        
        self.isPresenting ? container.addSubview(toView) : container.insertSubview(toView, belowSubview: fromView)
        
        let detailView = isPresenting ? toView : fromView
        
        let previewImage = UIImageView()
        previewImage.frame = self.previewImage
        previewImage.image = image
        previewImage.alpha = 0
        
        let originFrameWithNavBar = CGRect(x: originFrame.origin.x, y: originFrame.origin.y + 70, width: originFrame.width, height: originFrame.height)
        let transitionImageView = UIImageView(frame: isPresenting ? originFrameWithNavBar : previewImage.frame)
        transitionImageView.image = image
        
        container.addSubview(transitionImageView)
        
        toView.frame = isPresenting ?  CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height) : toView.frame
        toView.alpha = isPresenting ? 0 : 1
        toView.layoutIfNeeded()
        
        UIView.animate(withDuration: duration, animations: {
         
            transitionImageView.frame = self.isPresenting ?  previewImage.frame : originFrameWithNavBar
            detailView.frame = self.isPresenting ? fromView.frame : CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)
            detailView.alpha = self.isPresenting ? 1 : 0
        }, completion: { (finished) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            transitionImageView.removeFromSuperview()
            previewImage.alpha = 1
        })
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
}







