//
//  MKButton.swift
//  MaterialKit
//
//  Created by LeVan Nghia on 11/14/14.
//  Copyright (c) 2014 Le Van Nghia. All rights reserved.
//

import UIKit

@IBDesignable
public class MKButton : UIButton
{
    @IBInspectable public var maskEnabled: Bool = true {
        didSet {
            mkLayer.maskEnabled = maskEnabled
        }
    }
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
            mkLayer.superLayerDidResize()
        }
    }
    @IBInspectable public var elevation: CGFloat = 0 {
        didSet {
            mkLayer.elevation = elevation
        }
    }
    @IBInspectable public var shadowOffset: CGSize = CGSize.zero {
        didSet {
            mkLayer.shadowOffset = shadowOffset
        }
    }
    @IBInspectable public var roundingCorners: UIRectCorner = UIRectCorner.allCorners {
        didSet {
            mkLayer.roundingCorners = roundingCorners
        }
    }
    @IBInspectable public var rippleEnabled: Bool = true {
        didSet {
            mkLayer.rippleEnabled = rippleEnabled
        }
    }
    @IBInspectable public var rippleDuration: CFTimeInterval = 0.35 {
        didSet {
            mkLayer.rippleDuration = rippleDuration
        }
    }
    @IBInspectable public var rippleScaleRatio: CGFloat = 1.0 {
        didSet {
            mkLayer.rippleScaleRatio = rippleScaleRatio
        }
    }
    @IBInspectable public var rippleLayerColor: UIColor = UIColor(hex: 0xEEEEEE) {
        didSet {
            mkLayer.setRippleColor(color: rippleLayerColor)
        }
    }
    @IBInspectable public var backgroundAnimationEnabled: Bool = true {
        didSet {
            mkLayer.backgroundAnimationEnabled = backgroundAnimationEnabled
        }
    }

    override public var bounds: CGRect {
        didSet {
            mkLayer.superLayerDidResize()
        }
    }

    private lazy var mkLayer: MKLayer = MKLayer(withView: self)

    // MARK: Init
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayer()
    }

    // MARK: Setup
    private func setupLayer() {
        mkLayer = MKLayer(withView: self)
        mkLayer.elevation = self.elevation
        self.layer.cornerRadius = self.cornerRadius
        mkLayer.elevationOffset = self.shadowOffset
        mkLayer.roundingCorners = self.roundingCorners
        mkLayer.maskEnabled = self.maskEnabled
        mkLayer.rippleScaleRatio = self.rippleScaleRatio
        mkLayer.rippleDuration = self.rippleDuration
        mkLayer.rippleEnabled = self.rippleEnabled
        mkLayer.backgroundAnimationEnabled = self.backgroundAnimationEnabled
        mkLayer.setRippleColor(color: self.rippleLayerColor)
    }

    // MARK: Touch
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        mkLayer.touchesBegan(touches: touches, withEvent: event)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        mkLayer.touchesEnded(touches: touches, withEvent: event)
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        mkLayer.touchesCancelled(touches: touches, withEvent: event)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        mkLayer.touchesMoved(touches: touches, withEvent: event)
    }
}
