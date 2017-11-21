import UIKit

extension UIView {

  @discardableResult func g_pin(on type1: NSLayoutAttribute,
             view: UIView? = nil, on type2: NSLayoutAttribute? = nil,
             constant: CGFloat = 0,
             priority: Float? = nil) -> NSLayoutConstraint? {
    guard let view = view ?? superview else {
      return nil
    }

    translatesAutoresizingMaskIntoConstraints = false
    let type2 = type2 ?? type1
    let constraint = NSLayoutConstraint(item: self, attribute: type1,
                                        relatedBy: .equal,
                                        toItem: view, attribute: type2,
                                        multiplier: 1, constant: constant)
    if let priority = priority {
      constraint.priority = UILayoutPriority(priority)
    }

    constraint.isActive = true

    return constraint
  }

  func g_pinEdges(view: UIView? = nil) {
    g_pin(on: .top, view: view)
    g_pin(on: .bottom, view: view)
    g_pin(on: .left, view: view)
    g_pin(on: .right, view: view)
  }

  func g_pin(size: CGSize) {
    g_pin(width: size.width)
    g_pin(height: size.height)
  }

  func g_pin(width: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width))
  }

  func g_pin(height: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
  }
  
  func g_pin(greaterThanHeight height: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
  }

  func g_pinHorizontally(view: UIView? = nil, padding: CGFloat) {
    g_pin(on: .left, view: view, constant: padding)
    g_pin(on: .right, view: view, constant: -padding)
  }

  func g_pinUpward(view: UIView? = nil) {
    g_pin(on: .top, view: view)
    g_pin(on: .left, view: view)
    g_pin(on: .right, view: view)
  }

  func g_pinDownward(view: UIView? = nil) {
    g_pin(on: .bottom, view: view)
    g_pin(on: .left, view: view)
    g_pin(on: .right, view: view)
  }

  func g_pinCenter(view: UIView? = nil) {
    g_pin(on: .centerX, view: view)
    g_pin(on: .centerY, view: view)
  }
}

// https://github.com/hyperoslo/Sugar/blob/master/Sources/iOS/Constraint.swift
struct Constraint {
  static func on(constraints: [NSLayoutConstraint]) {
    constraints.forEach {
      ($0.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
      $0.isActive = true
    }
  }

  static func on(_ constraints: NSLayoutConstraint ...) {
    on(constraints: constraints)
  }
}
