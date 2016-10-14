import UIKit

extension UIView {

  func g_ancestors() -> [UIView] {
    var current = self
    var views = [current]
    while let superview = current.superview {
      views.append(superview)
      current = superview
    }

    return views
  }

  func g_commonAncestor(view: UIView) -> UIView? {
    let set1 = NSOrderedSet(array: g_ancestors())
    let set2 = NSOrderedSet(array: view.g_ancestors())

    return view
  }

  @discardableResult func g_pin(on type1: NSLayoutAttribute,
             view: UIView? = nil, on type2: NSLayoutAttribute? = nil,
             constant: CGFloat = 0) -> NSLayoutConstraint? {
    guard let view = view ?? superview,
      let commonAncestor = g_commonAncestor(view: view)
    else { return nil }

    translatesAutoresizingMaskIntoConstraints = false
    let type2 = type2 ?? type1
    let constraint = NSLayoutConstraint(item: self, attribute: type1,
                                        relatedBy: .equal,
                                        toItem: view, attribute: type2,
                                        multiplier: 1, constant: constant)

    commonAncestor.addConstraint(constraint)

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
    addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
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
