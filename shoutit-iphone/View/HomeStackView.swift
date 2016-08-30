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
    
    @IBOutlet var commonStaticComponents : [UIView]!
    
    func applyComponents(components: [ComponentStackViewRepresentable]) {
        for stackPart in mainStackView.arrangedSubviews {
            
            if commonStaticComponents.contains(stackPart) { continue }
            
            mainStackView.removeArrangedSubview(stackPart)
        }
        
        for component in components {
            let componentViews = component.stackViewRepresentation()
            
            for view in componentViews {
                mainStackView.addArrangedSubview(view)
            }
        }
    }
}
