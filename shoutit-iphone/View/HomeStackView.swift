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
}
