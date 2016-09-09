import UIKit
import Cartography

protocol PageAware: class {
  func pageDidShow()
}

class PagesController: UIViewController, PageIndicatorDelegate, UIScrollViewDelegate {

  let controllers: [UIViewController]

  lazy var scrollView: UIScrollView = self.makeScrollView()
  lazy var scrollViewContentView: UIView = UIView()
  lazy var pageIndicator: PageIndicator = self.makePageIndicator()

  var selectedIndex: Int = 0
  let once = Once()

  // MARK: - Initialization

  required init(controllers: [UIViewController]) {
    self.controllers = controllers

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setup()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    if scrollView.frame.size.width > 0 {
      once.run {
        goAndNotify()
      }
    }
  }

  // MARK: - Controls

  func makeScrollView() -> UIScrollView {
    let scrollView = UIScrollView()
    scrollView.pagingEnabled = true
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.alwaysBounceHorizontal = false
    scrollView.bounces = false
    scrollView.delegate = self

    return scrollView
  }

  func makePageIndicator() -> PageIndicator {
    let items = controllers.flatMap { $0.title }
    let indicator = PageIndicator(items: items)
    indicator.delegate = self

    return indicator
  }

  // MARK: - Setup

  func setup() {
    view.addSubview(pageIndicator)
    view.addSubview(scrollView)
    scrollView.addSubview(scrollViewContentView)

    pageIndicator.translatesAutoresizingMaskIntoConstraints = false
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollViewContentView.translatesAutoresizingMaskIntoConstraints = false

    constrain(scrollView, scrollViewContentView, pageIndicator) {
      scrollView, scrollViewContentView, pageIndicator in

      pageIndicator.left == pageIndicator.superview!.left
      pageIndicator.right == pageIndicator.superview!.right
      pageIndicator.bottom == pageIndicator.superview!.bottom
      pageIndicator.height == 40

      scrollView.top == scrollView.superview!.top
      scrollView.left == scrollView.superview!.left
      scrollView.right == scrollView.superview!.right
      scrollView.bottom == pageIndicator.top

      scrollViewContentView.edges == scrollViewContentView.superview!.edges

      scrollViewContentView.top == scrollView.superview!.top
      scrollViewContentView.bottom == scrollViewContentView.superview!.bottom
    }

    for (i, controller) in controllers.enumerate() {
      addChildViewController(controller)
      scrollViewContentView.addSubview(controller.view)
      controller.didMoveToParentViewController(self)

      controller.view.translatesAutoresizingMaskIntoConstraints = false

      scrollViewContentView.addConstraint(NSLayoutConstraint(item: controller.view, attribute: .Top, relatedBy: .Equal, toItem: scrollViewContentView, attribute: .Top, multiplier: 1, constant: 0))
      scrollViewContentView.addConstraint(NSLayoutConstraint(item: controller.view, attribute: .Bottom, relatedBy: .Equal, toItem: scrollViewContentView, attribute: .Bottom, multiplier: 1, constant: 0))
      scrollView.addConstraint(NSLayoutConstraint(item: controller.view, attribute: .Width, relatedBy: .Equal, toItem: scrollView, attribute: .Width, multiplier: 1, constant: 0))
      scrollView.addConstraint(NSLayoutConstraint(item: controller.view, attribute: .Height, relatedBy: .Equal, toItem: scrollView, attribute: .Height, multiplier: 1, constant: 0))

      if i == 0 {
        scrollViewContentView.addConstraint(NSLayoutConstraint(item: controller.view, attribute: .Left, relatedBy: .Equal, toItem: scrollViewContentView, attribute: .Left, multiplier: 1, constant: 0))
      } else {
        scrollViewContentView.addConstraint(NSLayoutConstraint(item: controller.view, attribute: .Left, relatedBy: .Equal, toItem: self.controllers[i-1].view, attribute: .Right, multiplier: 1, constant: 0))
      }

      if i == self.controllers.count - 1 {
        scrollViewContentView.addConstraint(NSLayoutConstraint(item: controller.view, attribute: .Right, relatedBy: .Equal, toItem: scrollViewContentView, attribute: .Right, multiplier: 1, constant: 0))
      }
    }
  }

  // MARK: - PageIndicatorDelegate

  func pageIndicator(pageIndicator: PageIndicator, didSelect index: Int) {
    let point = CGPoint(x: scrollView.frame.size.width * CGFloat(index), y: scrollView.contentOffset.y)
    scrollView.setContentOffset(point, animated: false)
    updateAndNotify(index)
  }

  // MARK: - UIScrollViewDelegate

  func scrollViewDidScroll(scrollView: UIScrollView) {
    let index = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
    pageIndicator.select(index: index)
    updateAndNotify(index)
  }

  // MARK: - Index

  func goAndNotify() {
    let point = CGPoint(x: scrollView.frame.size.width * CGFloat(selectedIndex), y: scrollView.contentOffset.y)

    Dispatch.main {
      self.scrollView.setContentOffset(point, animated: false)
    }

    notify()
  }

  func updateAndNotify(index: Int) {
    guard selectedIndex != index else { return }

    selectedIndex = index
    notify()
  }

  func notify() {
    if let controller = controllers[selectedIndex] as? PageAware {
      controller.pageDidShow()
    }
  }
}
