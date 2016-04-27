//
//  MaterialBorderedTextView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Material

public class BorderedMaterialTextView: UITextView {
    
    var contentSizeDidChange:(CGSize -> Void)? {
        didSet {
            let textSize = self.sizeThatFits(CGSize(width: self.width, height: CGFloat.max))
            if textSize != self.bounds.size {
                contentSizeDidChange?(textSize)
            }
        }
    }
    
    var editing = false
    var didLayoutSubviews = false
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        textContainer.lineFragmentPadding = 0
    }
    
    /**
     This property is the same as clipsToBounds. It crops any of the view's
     contents from bleeding past the view's frame. If an image is set using
     the image property, then this value does not need to be set, since the
     visualLayer's maskToBounds is set to true by default.
     */
    public var masksToBounds: Bool {
        get {
            return layer.masksToBounds
        }
        set(value) {
            layer.masksToBounds = value
        }
    }
    
    /// A property that accesses the backing layer's backgroundColor.
    public override var backgroundColor: UIColor? {
        didSet {
            layer.backgroundColor = backgroundColor?.CGColor
        }
    }
    
    /// A property that accesses the layer.frame.origin.x property.
    public var x: CGFloat {
        get {
            return layer.frame.origin.x
        }
        set(value) {
            layer.frame.origin.x = value
        }
    }
    
    /// A property that accesses the layer.frame.origin.y property.
    public var y: CGFloat {
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
    public var width: CGFloat {
        get {
            return layer.frame.size.width
        }
        set(value) {
            layer.frame.size.width = value
            if .None != shape {
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
    public var height: CGFloat {
        get {
            return layer.frame.size.height
        }
        set(value) {
            layer.frame.size.height = value
            if .None != shape {
                layer.frame.size.width = value
            }
        }
    }
    
    /// A property that accesses the backing layer's shadowColor.
    public var shadowColor: UIColor? {
        didSet {
            layer.shadowColor = shadowColor?.CGColor
        }
    }
    
    /// A property that accesses the backing layer's shadowOffset.
    public var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set(value) {
            layer.shadowOffset = value
        }
    }
    
    /// A property that accesses the backing layer's shadowOpacity.
    public var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set(value) {
            layer.shadowOpacity = value
        }
    }
    
    /// A property that accesses the backing layer's shadowRadius.
    public var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set(value) {
            layer.shadowRadius = value
        }
    }
    
    /**
     A property that sets the distance between the textField and
     bottomBorderLayer.
     */
    public var bottomBorderLayerDistance: CGFloat = 22
    
    /// The bottom border layer.
    public private(set) lazy var bottomBorderLayer: CAShapeLayer = CAShapeLayer()
    
    /**
     A property that sets the shadowOffset, shadowOpacity, and shadowRadius
     for the backing layer. This is the preferred method of setting depth
     in order to maintain consitency across UI objects.
     */
    public var depth: MaterialDepth {
        didSet {
            let value: MaterialDepthType = MaterialDepthToValue(depth)
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
    public var cornerRadius: MaterialRadius {
        didSet {
            if let v: MaterialRadius = cornerRadius {
                layer.cornerRadius = MaterialRadiusToValue(v)
                if .Circle == shape {
                    shape = .None
                }
            }
        }
    }
    
    /**
     A property that manages the overall shape for the object. If either the
     width or height property is set, the other will be automatically adjusted
     to maintain the shape of the object.
     */
    public var shape: MaterialShape {
        didSet {
            if .None != shape {
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
    public var borderWidth: MaterialBorder {
        didSet {
            layer.borderWidth = MaterialBorderToValue(borderWidth)
        }
    }
    
    /// A property that accesses the layer.borderColor property.
    public var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.CGColor
        }
    }
    
    /// A property that accesses the layer.position property.
    public var position: CGPoint {
        get {
            return layer.position
        }
        set(value) {
            layer.position = value
        }
    }
    
    /// A property that accesses the layer.zPosition property.
    public var zPosition: CGFloat {
        get {
            return layer.zPosition
        }
        set(value) {
            layer.zPosition = value
        }
    }
    
    /**
     The title UILabel that is displayed when there is text. The
     titleLabel text value is updated with the placeholderLabel
     text value before being displayed.
     */
    public var titleLabel: UILabel? {
        didSet {
            prepareTitleLabel()
        }
    }
    
    /// The color of the titleLabel text when the textView is not active.
    public var titleLabelColor: UIColor? {
        didSet {
            titleLabel?.textColor = titleLabelColor
            MaterialAnimation.animationDisabled { [unowned self] in
                self.bottomBorderLayer.borderColor = self.titleLabelColor?.CGColor
            }
        }
    }
    
    /// The color of the titleLabel text when the textView is active.
    public var titleLabelActiveColor: UIColor?
    
    /**
     A property that sets the distance between the textView and
     titleLabel.
     */
    public var titleLabelAnimationDistance: CGFloat = 4
    
    /**
     The detail UILabel that is displayed when the detailLabelHidden property
     is set to false.
     */
    public var detailLabel: UILabel? {
        didSet {
            prepareDetailLabel()
        }
    }
    
    /**
     The color of the detailLabel text when the detailLabelHidden property
     is set to false.
     */
    public var detailLabelActiveColor: UIColor? {
        didSet {
            if !detailLabelHidden {
                detailLabel?.textColor = detailLabelActiveColor
                MaterialAnimation.animationDisabled { [unowned self] in
                    self.bottomBorderLayer.borderColor = self.detailLabelActiveColor?.CGColor
                }
            }
        }
    }
    
    /**
     A property that sets the distance between the textField and
     detailLabel.
     */
    public var detailLabelAnimationDistance: CGFloat = 6
    
    /**
     :name:	detailLabelHidden
     */
    public var detailLabelHidden: Bool = true {
        didSet {
            if detailLabelHidden {
                detailLabel?.textColor = titleLabelColor
                MaterialAnimation.animationDisabled { [unowned self] in
                    self.bottomBorderLayer.borderColor = self.editing ? self.titleLabelActiveColor?.CGColor : self.titleLabelColor?.CGColor
                }
                hideDetailLabel()
            } else {
                detailLabel?.textColor = detailLabelActiveColor
                MaterialAnimation.animationDisabled { [unowned self] in
                    self.bottomBorderLayer.borderColor = self.detailLabelActiveColor?.CGColor
                }
                showDetailLabel()
            }
        }
    }
    
    /// Placeholder UILabel view.
    public var placeholderLabel: UILabel? {
        didSet {
            preparePlaceholderLabel()
        }
    }
    
    /// An override to the text property.
    public override var text: String! {
        didSet {
            handleTextViewTextDidChange()
        }
    }
    
    /// An override to the attributedText property.
    public override var attributedText: NSAttributedString! {
        didSet {
            handleTextViewTextDidChange()
        }
    }
    
    /**
     Text container UIEdgeInset preset property. This updates the
     textContainerInset property with a preset value.
     */
    public var textContainerInsetPreset: MaterialEdgeInset = .None {
        didSet {
            textContainerInset = MaterialEdgeInsetToValue(textContainerInsetPreset)
        }
    }
    
    /// Text container UIEdgeInset property.
    public override var textContainerInset: UIEdgeInsets {
        didSet {
            reloadView()
        }
    }
    
    /**
     An initializer that initializes the object with a NSCoder object.
     - Parameter aDecoder: A NSCoder instance.
     */
    public required init?(coder aDecoder: NSCoder) {
        depth = .None
        shape = .None
        cornerRadius = .None
        borderWidth = .None
        super.init(coder: aDecoder)
        prepareView()
    }
    
    /**
     An initializer that initializes the object with a CGRect object.
     If AutoLayout is used, it is better to initilize the instance
     using the init() initializer.
     - Parameter frame: A CGRect instance.
     - Parameter textContainer: A NSTextContainer instance.
     */
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        depth = .None
        shape = .None
        cornerRadius = .None
        borderWidth = .None
        super.init(frame: frame, textContainer: textContainer)
        prepareView()
    }
    
    /**
     A convenience initializer that is mostly used with AutoLayout.
     - Parameter textContainer: A NSTextContainer instance.
     */
    public convenience init(textContainer: NSTextContainer?) {
        self.init(frame: CGRectNull, textContainer: textContainer)
    }
    
    /** Denitializer. This should never be called unless you know
     what you are doing.
     */
    deinit {
        removeNotificationHandlers()
    }
    
    /// Overriding the layout callback for subviews.
    public override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel?.preferredMaxLayoutWidth = textContainer.size.width - textContainer.lineFragmentPadding * 2
        titleLabel?.frame.size.width = bounds.width
        updateDetailLabelFrameSilently()
        updatePlaceholderLabelFrame()
    }
    
    /// Overriding the layout callback for sublayers.
    public override func layoutSublayersOfLayer(layer: CALayer) {
        super.layoutSublayersOfLayer(layer)
        if self.layer == layer {
            bottomBorderLayer.frame = CGRectMake(-9, -20, bounds.width + 18, bounds.height + bottomBorderLayerDistance + 20)
            bottomBorderLayer.backgroundColor = UIColor.clearColor().CGColor
            bottomBorderLayer.borderWidth = 1.0
            bottomBorderLayer.cornerRadius = 5.0
            layoutShape()
        }
        if self.layer == layer {
            layoutShape()
        }
    }
    
    /**
     A method that accepts CAAnimation objects and executes them on the
     view's backing layer.
     - Parameter animation: A CAAnimation instance.
     */
    public func animate(animation: CAAnimation) {
        animation.delegate = self
        if let a: CABasicAnimation = animation as? CABasicAnimation {
            a.fromValue = (nil == layer.presentationLayer() ? layer : layer.presentationLayer() as! CALayer).valueForKeyPath(a.keyPath!)
        }
        if let a: CAPropertyAnimation = animation as? CAPropertyAnimation {
            layer.addAnimation(a, forKey: a.keyPath!)
        } else if let a: CAAnimationGroup = animation as? CAAnimationGroup {
            layer.addAnimation(a, forKey: nil)
        } else if let a: CATransition = animation as? CATransition {
            layer.addAnimation(a, forKey: kCATransition)
        }
    }
    
    /**
     A delegation method that is executed when the backing layer starts
     running an animation.
     - Parameter anim: The currently running CAAnimation instance.
     */
    public override func animationDidStart(anim: CAAnimation) {
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
    public override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if let a: CAPropertyAnimation = anim as? CAPropertyAnimation {
            if let b: CABasicAnimation = a as? CABasicAnimation {
                layer.setValue(nil == b.toValue ? b.byValue : b.toValue, forKey: b.keyPath!)
            }
            (delegate as? MaterialAnimationDelegate)?.materialAnimationDidStop?(anim, finished: flag)
            layer.removeAnimationForKey(a.keyPath!)
        } else if let a: CAAnimationGroup = anim as? CAAnimationGroup {
            for x in a.animations! {
                animationDidStop(x, finished: true)
            }
        }
    }
    
    /// Reloads necessary components when the view has changed.
    internal func reloadView() {
        
    }
    
    /// Notification handler for when text editing began.
    internal func handleTextViewTextDidBegin() {
        editing = true
        titleLabel?.textColor = titleLabelActiveColor
        MaterialAnimation.animationDisabled { [unowned self] in
            self.bottomBorderLayer.borderColor = self.titleLabelActiveColor?.CGColor
        }
    }
    
    /// Notification handler for when text changed.
    internal func handleTextViewTextDidChange() {
        if let p = placeholderLabel {
            p.hidden = !(true == text?.isEmpty)
        }
        
        if 0 < text?.utf16.count {
            showTitleLabel()
            if !detailLabelHidden {
//                MaterialAnimation.animationDisabled { [unowned self] in
//                    self.bottomBorderLayer.borderColor = self.titleLabelActiveColor?.CGColor
//                }
            }
        } else if 0 == text?.utf16.count {
            hideTitleLabel()
        }
        
        let textSize = self.sizeThatFits(CGSize(width: self.width, height: CGFloat.max))
        if textSize.height != self.bounds.size.height {
            contentSizeDidChange?(textSize)
            updateDetailLabelFrame()
        }
    }
    
    /// Notification handler for when text editing ended.
    internal func handleTextViewTextDidEnd() {
        editing = false
        if 0 < text?.utf16.count {
            showTitleLabel()
        } else if 0 == text?.utf16.count {
            hideTitleLabel()
        }
        titleLabel?.textColor = titleLabelColor
        MaterialAnimation.animationDisabled { [unowned self] in
            self.bottomBorderLayer.borderColor = self.detailLabelHidden ? self.titleLabelColor?.CGColor : self.detailLabelActiveColor?.CGColor
        }
    }
    
    /// Manages the layout for the shape of the view instance.
    internal func layoutShape() {
        if .Circle == shape {
            layer.cornerRadius = width / 2
        }
    }
    
    /**
     Prepares the view instance when intialized. When subclassing,
     it is recommended to override the prepareView method
     to initialize property values and other setup operations.
     The super.prepareView method should always be called immediately
     when subclassing.
     */
    private func prepareView() {
        textContainerInset = MaterialEdgeInsetToValue(.None)
        backgroundColor = MaterialColor.white
        masksToBounds = false
        removeNotificationHandlers()
        prepareNotificationHandlers()
        reloadView()
        prepareBottomBorderLayer()
        prepareDetailLabel()
    }
    
    /// Prepares the bottomBorderLayer property.
    private func prepareBottomBorderLayer() {
        layer.addSublayer(bottomBorderLayer)
    }
    
    /// prepares the placeholderLabel property.
    private func preparePlaceholderLabel() {
        if let v: UILabel = placeholderLabel {
            v.font = font
            v.textAlignment = textAlignment
            v.numberOfLines = 0
            v.backgroundColor = MaterialColor.clear
            addSubview(v)
            reloadView()
            handleTextViewTextDidChange()
        }
    }
    
    /// Prepares the titleLabel property.
    private func prepareTitleLabel() {
        if let v: UILabel = titleLabel {
            v.hidden = true
            addSubview(v)
            if 0 < text?.utf16.count {
                showTitleLabel()
            } else {
                v.alpha = 0
            }
        }
    }
    
    /// Prepares the detailLabel property.
    private func prepareDetailLabel() {
        if let v: UILabel = detailLabel {
            v.hidden = true
            addSubview(v)
            if detailLabelHidden {
                v.alpha = 0
            } else {
                showDetailLabel()
            }
        }
    }
    
    /// Shows and animates the titleLabel property.
    private func showTitleLabel() {
        if let v: UILabel = titleLabel {
            if v.hidden {
                if let s: String = placeholderLabel?.text {
                    if 0 == v.text?.utf16.count || nil == v.text {
                        v.text = s
                    }
                }
                let h: CGFloat = v.font.pointSize
                v.frame = CGRectMake(0, -h, bounds.width, h)
                v.hidden = false
                UIView.animateWithDuration(0.25, animations: { [unowned self] in
                    v.alpha = 1
                    v.frame.origin.y = -v.frame.height - self.titleLabelAnimationDistance
                    })
            }
        }
    }
    
    /// Hides and animates the titleLabel property.
    private func hideTitleLabel() {
        if let v: UILabel = titleLabel {
            if !v.hidden {
                UIView.animateWithDuration(0.25, animations: {
                    v.alpha = 0
                    v.frame.origin.y = -v.frame.height
                }) { _ in
                    v.hidden = true
                }
            }
        }
    }
    
    /// Shows and animates the detailLabel property.
    private func showDetailLabel() {
        if let v: UILabel = detailLabel {
            if v.hidden {
                let h: CGFloat = v.font.pointSize
                let size = v.sizeThatFits(CGSize(width: CGFloat.max, height: h))
                v.frame = CGRectMake(bounds.width - size.width - 10, bounds.height + detailLabelAnimationDistance, size.width + 10, h)
                v.hidden = false
                v.frame.origin.y = self.frame.height + self.detailLabelAnimationDistance
                v.alpha = 1
            }
        }
    }
    
    private func updateDetailLabelFrame() {
        if let v: UILabel = detailLabel {
            let h: CGFloat = v.font.pointSize
            let size = v.sizeThatFits(CGSize(width: CGFloat.max, height: h))
            v.frame = CGRectMake(bounds.width - size.width - 10, bounds.height + detailLabelAnimationDistance, size.width + 10, h)
            UIView.animateWithDuration(0.25, animations: { [unowned self] in
                v.frame.origin.y = self.frame.height + self.detailLabelAnimationDistance
                v.alpha = 1
                })
        }
    }
    
    private func updateDetailLabelFrameSilently() {
        
        if let v: UILabel = detailLabel {
            let h: CGFloat = v.font.pointSize
            let size = v.sizeThatFits(CGSize(width: CGFloat.max, height: h))
            let frame = CGRectMake(bounds.width - size.width - 10, bounds.height + detailLabelAnimationDistance, size.width + 10, h)
            if frame != v.frame {
                v.frame = frame
            }
        }
    }
    
    private func updatePlaceholderLabelFrame() {
        if let p = placeholderLabel {
            let width = bounds.width - textContainerInset.left - textContainerInset.right
            let height = p.font.lineHeight
            p.frame = CGRect(x: textContainerInset.left, y: textContainerInset.top, width: width, height: height)
        }
    }
    
    /// Hides and animates the detailLabel property.
    private func hideDetailLabel() {
        if let v: UILabel = detailLabel {
            UIView.animateWithDuration(0.25, animations: {
                v.alpha = 0
                v.frame.origin.y = v.frame.height + 20
            }) { _ in
                v.hidden = true
            }
        }
    }
    
    /// Prepares the Notification handlers.
    private func prepareNotificationHandlers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BorderedMaterialTextView.handleTextViewTextDidBegin), name: UITextViewTextDidBeginEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BorderedMaterialTextView.handleTextViewTextDidChange), name: UITextViewTextDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BorderedMaterialTextView.handleTextViewTextDidEnd), name: UITextViewTextDidEndEditingNotification, object: nil)
    }
    
    /// Removes the Notification handlers.
    private func removeNotificationHandlers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextViewTextDidBeginEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextViewTextDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextViewTextDidEndEditingNotification, object: nil)
    }
}
