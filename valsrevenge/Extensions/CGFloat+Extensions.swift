//
//  CGFloat+Extensions.swift
//  valsrevenge
//
//  Created by Aaron on 2022/3/30.
//

import CoreGraphics

// You’ll use this new extension and its methods in the Controller class to help clamp the range between two values so that the controller’s movement is restricted to the specified range of values.
extension CGFloat {
  func clamped(v1: CGFloat, v2: CGFloat) -> CGFloat {
    let min = v1 < v2 ? v1 : v2
    let max = v1 > v2 ? v1 : v2
    
    return self < min ? min : (self > max ? max : self)
  }
  
  func clamped(to r: ClosedRange<CGFloat>) -> CGFloat {
    let min = r.lowerBound, max = r.upperBound
    return self < min ? min : (self > max ? max : self)
  }
}
