//
//  HomeStackView.swift
//  shoutit
//
//  Created by Piotr Bernad on 29/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class HomeStackView: UIScrollView {

    @IBOutlet var mainStackView : UIStackView!
    
    @IBOutlet var firstTabConstraints : [NSLayoutConstraint]!
    @IBOutlet var secondTabConstraints : [NSLayoutConstraint]!
    @IBOutlet var thirdTabConstraints : [NSLayoutConstraint]!
    
    func applyComponents(components: [ComponentStackViewRepresentable]) {

            for stackPart in self.mainStackView.arrangedSubviews {
                stackPart.hidden = true
            }
        
            for stackPart in self.mainStackView.arrangedSubviews {
                self.mainStackView.removeArrangedSubview(stackPart)
            }
            
        
            for component in components {
                let componentViews = component.stackViewRepresentation()
                    
                for view in componentViews {
                    self.mainStackView.addArrangedSubview(view)
                }
            }
        
            for stackPart in self.mainStackView.arrangedSubviews {
                    
                stackPart.hidden = false
            }
    }
    
    func switchToTab(tab: Int) {
        switch tab {
        case 0:
            NSLayoutConstraint.deactivateConstraints(self.secondTabConstraints + self.thirdTabConstraints)
            NSLayoutConstraint.activateConstraints(self.firstTabConstraints)
        case 1:
            NSLayoutConstraint.deactivateConstraints(self.firstTabConstraints + self.thirdTabConstraints)
            NSLayoutConstraint.activateConstraints(self.secondTabConstraints)
        case 2:
            NSLayoutConstraint.deactivateConstraints(self.firstTabConstraints + self.secondTabConstraints)
            NSLayoutConstraint.activateConstraints(self.thirdTabConstraints)
        default: break
        }
        
        self.setNeedsUpdateConstraints()
        UIView.animateWithDuration(0.3) { 
            self.layoutIfNeeded()
        }
    }
}
