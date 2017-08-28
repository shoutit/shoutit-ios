/*
 * Copyright (C) 2015 - 2016, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.io>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of Material nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit
import Material
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


open class BorderedMaterialTextField : UITextField {
    /**
     This property is the same as clipsToBounds. It crops any of the view's
     contents from bleeding past the view's frame. If an image is set using
     the image property, then this value does not need to be set, since the
     visualLayer's maskToBounds is set to true by default.
     */
    open override var masksToBounds: Bool {
        get {
            return layer.masksToBounds
        }
        set(value) {
            layer.masksToBounds = value
        }
    }
    
    /// A property that accesses the backing layer's backgroundColor.
    open override var backgroundColor: UIColor? {
        didSet {
        layer.backgroundColor = backgroundColor?.cgColor
        }
    }
    
    /// A property that accesses the layer.frame.origin.x property.
    open override var x: CGFloat {
        get {
            return layer.frame.origin.x
        }
        set(value) {
            layer.frame.origin.x = value
        }
    }
    
    /// A property that accesses the layer.frame.origin.y property.
    open override var y: CGFloat {
        get {
            return layer.frame.origin.y
        }
        set(value) {
            layer.frame.origin.y = value
        }
    }
    
    /**
     A property that accesses the layer.frame.origin.width property.
     When setting this property in conjunction with the shape property having a
     value that is not .None, the height will be adjusted to maintain the correct
     shape.
     */
    open override var width: CGFloat {
        get {
            return layer.frame.size.width
        }
        set(value) {
            layer.frame.size.width = value
            if .none != shape {
                layer.frame.size.height = value
            }
        }
    }
    
    /**
     A property that accesses the layer.frame.origin.height property.
     When setting this property in conjunction with the shape property having a
     value that is not .None, the width will be adjusted to maintain the correct
     shape.
     */
    open override var height: CGFloat {
        get {
            return layer.frame.size.height
        }
        set(value) {
            layer.frame.size.height = value
            if .none != shape {
                layer.frame.size.width = value
            }
        }
    }
    
    /// A property that accesses the backing layer's shadowColor.
    open  override var shadowColor: UIColor? {
        didSet {
        layer.shadowColor = shadowColor?.cgColor
        }
    }
    
    /// A property that accesses the backing layer's shadowOffset.
    open override var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set(value) {
            layer.shadowOffset = value
        }
    }
    
    /// A property that accesses the backing layer's shadowOpacity.
    open override var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set(value) {
            layer.shadowOpacity = value
        }
    }
    
    /// A property that accesses the backing layer's shadowRadius.
    open override var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set(value) {
            layer.shadowRadius = value
        }
    }
    
    /**
     A property that sets the shadowOffset, shadowOpacity, and shadowRadius
     for the backing layer. This is the preferred method of setting depth
     in order to maintain consitency across UI objects.
     */
    open var sh_depth: Material.DepthPreset {
        didSet {
        let value = DepthPresetToValue(sh_depth)
            
        shadowOffset = value.offset
        shadowOpacity = value.opacity
        shadowRadius = value.radius
        }
    }
    
    /**
     A property that sets the cornerRadius of the backing layer. If the shape
     property has a value of .Circle when the cornerRadius is set, it will
     become .None, as it no longer maintains its circle shape.
     */
    open var sh_cornerRadius: Material.CornerRadiusPreset {
        didSet {
        if let v: Material.CornerRadiusPreset = sh_cornerRadius {
            layer.cornerRadius = MaterialRadiusToValue(v)
            if .circle == shape {
                shape = .none
            }
        }
        }
    }
    
    /**
     A property that manages the overall shape for the object. If either the
     width or height property is set, the other will be automatically adjusted
     to maintain the shape of the object.
     */
    open var shape: Material.ShapePreset {
        didSet {
        if .none != shape {
            if width < height {
                frame.size.width = height
            } else {
                frame.size.height = width
            }
        }
        }
    }
    
    /**
     A property that accesses the layer.borderWith using a MaterialBorder
     enum preset.
     */
    open var sh_borderWidth: Material.BorderWidthPreset {
        didSet {
        layer.borderWidth = borderWidth.cgFloatValue
        }
    }
    
    /// A property that accesses the layer.borderColor property.
    open override var borderColor: UIColor? {
        didSet {
        layer.borderColor = borderColor?.cgColor
        }
    }
    
    /// A property that accesses the layer.position property.
    open override var position: CGPoint {
        get {
            return layer.position
        }
        set(value) {
            layer.position = value
        }
    }
    
    /// A property that accesses the layer.zPosition property.
    open override var zPosition: CGFloat {
        get {
            return layer.zPosition
        }
        set(value) {
            layer.zPosition = value
        }
    }
    
    /// The bottom border layer.
    open fileprivate(set) lazy var bottomBorderLayer: CAShapeLayer = CAShapeLayer()
    
    /**
     A property that sets the distance between the textField and
     bottomBorderLayer.
     */
    open var bottomBorderLayerDistance: CGFloat = 2
    
    /**
     The title UILabel that is displayed when there is text. The
     titleLabel text value is updated with the placeholder text
     value before being displayed.
     */
    open var titleLabel: UILabel? {
        didSet {
        prepareTitleLabel()
        }
    }
    
    /// The color of the titleLabel text when the textField is not active.
    open var titleLabelColor: UIColor? {
        didSet {
        titleLabel?.textColor = titleLabelColor
        MaterialAnimation.animationDisabled { [unowned self] in
            self.bottomBorderLayer.borderColor = self.titleLabelColor?.cgColor
        }
        }
    }
    
    /// The color of the titleLabel text when the textField is active.
    open var titleLabelActiveColor: UIColor?
    
    /**
     A property that sets the distance between the textField and
     titleLabel.
     */
    open var titleLabelAnimationDistance: CGFloat = 4
    
    /// An override to the text property.
    open override var text: String? {
        didSet {
        textFieldDidChange(self)
        }
    }
    
    /**
     The detail UILabel that is displayed when the detailLabelHidden property
     is set to false.
     */
    open var detailLabel: UILabel? {
        didSet {
        prepareDetailLabel()
        }
    }
    
    /**
     The color of the detailLabel text when the detailLabelHidden property
     is set to false.
     */
    open var detailLabelActiveColor: UIColor? {
        didSet {
        if !detailLabelHidden {
            detailLabel?.textColor = detailLabelActiveColor
            MaterialAnimation.animationDisabled { [unowned self] in
                self.bottomBorderLayer.borderColor = self.detailLabelActiveColor?.cgColor
            }
        }
        }
    }
    
    /**
     A property that sets the distance between the textField and
     detailLabel.
     */
    open var detailLabelAnimationDistance: CGFloat = 8
    
    /**
     :name:	detailLabelHidden
     */
    open var detailLabelHidden: Bool = true {
        didSet {
        if detailLabelHidden {
            detailLabel?.textColor = titleLabelColor
            MaterialAnimation.animationDisabled { [unowned self] in
                self.bottomBorderLayer.borderColor = self.isEditing ? self.titleLabelActiveColor?.cgColor : self.titleLabelColor?.cgColor
            }
            hideDetailLabel()
        } else {
            detailLabel?.textColor = detailLabelActiveColor
            MaterialAnimation.animationDisabled { [unowned self] in
                self.bottomBorderLayer.borderColor = self.detailLabelActiveColor?.cgColor
            }
            showDetailLabel()
        }
        }
    }
    
    /**
     An initializer that initializes the object with a NSCoder object.
     - Parameter aDecoder: A NSCoder instance.
     */
    public required init?(coder aDecoder: NSCoder) {
        depth = .none
        shape = .none
        cornerRadius = .none
        borderWidth = .none
        super.init(coder: aDecoder)
        prepareView()
    }
    
    /**
     An initializer that initializes the object with a CGRect object.
     If AutoLayout is used, it is better to initilize the instance
     using the init() initializer.
     - Parameter frame: A CGRect instance.
     */
    public override init(frame: CGRect) {
        depth = .none
        shape = .none
        cornerRadius = .none
        borderWidth = .none
        super.init(frame: frame)
        prepareView()
    }
    
    /// A convenience initializer that is mostly used with AutoLayout.
    public convenience init() {
        self.init(frame: CGRect.null)
    }
    
    /// Overriding the layout callback for sublayers.
    open func layoutSublayersOfLayer(_ layer: CALayer) {
        super.layoutSublayersOfLayer(layer)
        if self.layer == layer {
            bottomBorderLayer.frame = CGRect(x: -9, y: -20, width: bounds.width + 18, height: bounds.height + bottomBorderLayerDistance + 20)
            bottomBorderLayer.backgroundColor = UIColor.clear.cgColor
            bottomBorderLayer.borderWidth = 1.0
            bottomBorderLayer.cornerRadius = 5.0
            layoutShape()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if 0 < text?.utf16.count {
            showTitleLabel()
        } else if 0 == text?.utf16.count {
            hideTitleLabel()
        }
    }
    
    open override func caretRect(for position: UITextPosition) -> CGRect {
        let defaultRect = super.caretRect(for: position)
        if text == nil || self.text == "" {
            return CGRect(x: defaultRect.minX, y: defaultRect.minY - 10, width: defaultRect.width, height: defaultRect.height)
        }
        return defaultRect
    }
    
    open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.placeholderRect(forBounds: bounds)
        return CGRect(x: rect.minX, y: rect.minY - 8, width: rect.width, height: rect.height)
    }
    
    /**
     A method that accepts CAAnimation objects and executes them on the
     view's backing layer.
     - Parameter animation: A CAAnimation instance.
     */
    open func animate(_ animation: CAAnimation) {
        animation.delegate = self as! CAAnimationDelegate
        if let a: CABasicAnimation = animation as? CABasicAnimation {
            a.fromValue = (nil == layer.presentation() ? layer : layer.presentation() as! CALayer).value(forKeyPath: a.keyPath!)
        }
        if let a: CAPropertyAnimation = animation as? CAPropertyAnimation {
            layer.add(a, forKey: a.keyPath!)
        } else if let a: CAAnimationGroup = animation as? CAAnimationGroup {
            layer.add(a, forKey: nil)
        } else if let a: CATransition = animation as? CATransition {
            layer.add(a, forKey: kCATransition)
        }
    }
    
    /**
     A delegation method that is executed when the backing layer starts
     running an animation.
     - Parameter anim: The currently running CAAnimation instance.
     */
    open func animationDidStart(_ anim: CAAnimation) {
        (delegate as? MaterialAnimationDelegate)?.materialAnimationDidStart?(anim)
    }
    
    /**
     A delegation method that is executed when the backing layer stops
     running an animation.
     - Parameter anim: The CAAnimation instance that stopped running.
     - Parameter flag: A boolean that indicates if the animation stopped
     because it was completed or interrupted. True if completed, false
     if interrupted.
     */
    open func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let a: CAPropertyAnimation = anim as? CAPropertyAnimation {
            if let b: CABasicAnimation = a as? CABasicAnimation {
                layer.setValue(nil == b.toValue ? b.byValue : b.toValue, forKey: b.keyPath!)
            }
            (delegate as? MaterialAnimationDelegate)?.materialAnimationDidStop?(anim, finished: flag)
            layer.removeAnimation(forKey: a.keyPath!)
        } else if let a: CAAnimationGroup = anim as? CAAnimationGroup {
            for x in a.animations! {
                animationDidStop(x, finished: true)
            }
        }
    }
    
    /**
     Prepares the view instance when intialized. When subclassing,
     it is recommended to override the prepareView method
     to initialize property values and other setup operations.
     The super.prepareView method should always be called immediately
     when subclassing.
     */
    open func prepareView() {
        //backgroundColor = Material.Color.white
        shadowColor = Material.Color.black
        borderColor = Material.Color.black
        masksToBounds = false
        prepareBottomBorderLayer()
    }
    
    /// Handler for text editing began.
    internal func textFieldDidBegin(_ textField: BorderedMaterialTextField) {
        titleLabel?.textColor = titleLabelActiveColor
        MaterialAnimation.animationDisabled { [unowned self] in
            self.bottomBorderLayer.borderColor = self.detailLabelHidden ? self.titleLabelActiveColor?.cgColor : self.detailLabelActiveColor?.cgColor
        }
    }
    
    /// Handler for text changed.
    internal func textFieldDidChange(_ textField: BorderedMaterialTextField) {
        if 0 < text?.utf16.count {
            showTitleLabel()
            if !detailLabelHidden {
                MaterialAnimation.animationDisabled { [unowned self] in
                    self.bottomBorderLayer.borderColor = self.detailLabelActiveColor?.cgColor
                }
            }
        } else if 0 == text?.utf16.count {
            hideTitleLabel()
        }
    }
    
    /// Handler for text editing ended.
    internal func textFieldDidEnd(_ textField: BorderedMaterialTextField) {
        if 0 < text?.utf16.count {
            showTitleLabel()
        } else if 0 == text?.utf16.count {
            hideTitleLabel()
        }
        titleLabel?.textColor = titleLabelColor
        MaterialAnimation.animationDisabled { [unowned self] in
            self.bottomBorderLayer.borderColor = self.detailLabelHidden ? self.titleLabelColor?.cgColor : self.detailLabelActiveColor?.cgColor
        }
    }
    
    /// Manages the layout for the shape of the view instance.
    open override func layoutShape() {
        if .circle == shape {
            layer.cornerRadius = width / 2
        }
    }
    
    /// Prepares the titleLabel property.
    fileprivate func prepareTitleLabel() {
        if let v: UILabel = titleLabel {
            v.isHidden = true
            addSubview(v)
            if 0 < text?.utf16.count {
                showTitleLabel()
            } else {
                v.alpha = 0
            }
            addTarget(self, action: #selector(BorderedMaterialTextField.textFieldDidBegin(_:)), for: .editingDidBegin)
            addTarget(self, action: #selector(BorderedMaterialTextField.textFieldDidChange(_:)), for: .editingChanged)
            addTarget(self, action: #selector(BorderedMaterialTextField.textFieldDidEnd(_:)), for: .editingDidEnd)
        }
    }
    
    /// Prepares the detailLabel property.
    fileprivate func prepareDetailLabel() {
        if let v: UILabel = detailLabel {
            v.isHidden = true
            addSubview(v)
            if detailLabelHidden {
                v.alpha = 0
            } else {
                showDetailLabel()
            }
            addTarget(self, action: #selector(BorderedMaterialTextField.textFieldDidBegin(_:)), for: .editingDidBegin)
            addTarget(self, action: #selector(BorderedMaterialTextField.textFieldDidChange(_:)), for: .editingChanged)
            addTarget(self, action: #selector(BorderedMaterialTextField.textFieldDidEnd(_:)), for: .editingDidEnd)
        }
    }
    
    /// Prepares the bottomBorderLayer property.
    fileprivate func prepareBottomBorderLayer() {
        layer.addSublayer(bottomBorderLayer)
    }
    
    /// Shows and animates the titleLabel property.
    fileprivate func showTitleLabel() {
        if let v: UILabel = titleLabel {
            if v.isHidden || bounds.width != v.bounds.width {
                if let s: String = placeholder {
                    if 0 == v.text?.utf16.count || nil == v.text {
                        v.text = s
                    }
                }
                let h: CGFloat = v.font.pointSize
                v.frame = CGRect(x: 0, y: -h, width: bounds.width, height: h)
                v.isHidden = false
                UIView.animate(withDuration: 0.25, animations: { [unowned self] in
                    v.alpha = 1
                    v.frame.origin.y = -v.frame.height - self.titleLabelAnimationDistance
                    })
            }
        }
    }
    
    /// Hides and animates the titleLabel property.
    fileprivate func hideTitleLabel() {
        if let v: UILabel = titleLabel {
            v.isHidden = true
        }
    }
    
    /// Shows and animates the detailLabel property.
    fileprivate func showDetailLabel() {
        if let v: UILabel = detailLabel {
            if v.isHidden {
                let h: CGFloat = v.font.pointSize
                v.frame = CGRect(x: 0, y: bounds.height + bottomBorderLayerDistance, width: bounds.width, height: h)
                v.isHidden = false
                UIView.animate(withDuration: 0.25, animations: { [unowned self] in
                    v.frame.origin.y = self.frame.height + self.bottomBorderLayerDistance + self.detailLabelAnimationDistance
                    v.alpha = 1
                    })
            }
        }
    }
    
    /// Hides and animates the detailLabel property.
    fileprivate func hideDetailLabel() {
        if let v: UILabel = detailLabel {
            UIView.animate(withDuration: 0.25, animations: {
                v.alpha = 0
                v.frame.origin.y = v.frame.height + 20
            }, completion: { _ in
                v.isHidden = true
            }) 
        }
    }
}
