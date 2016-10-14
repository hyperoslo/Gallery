import UIKit

protocol PageAware: class {
  func pageDidShow()
}

class PagesController: UIViewController {

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
    scrollView.isPagingEnabled = true
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

    pageIndicator.g_pinDownward()
    pageIndicator.g_pin(height: 40)

    scrollView.g_pinUpward()
    scrollView.g_pin(on: .bottom, view: pageIndicator, on: .top)

    scrollViewContentView.g_pinEdges()
    scrollViewContentView.g_pin(on: .top, view: scrollView.superview!)
    scrollViewContentView.g_pin(on: .bottom, view: scrollView.superview!)

    for (i, controller) in controllers.enumerated() {
      addChildViewController(controller)
      scrollViewContentView.addSubview(controller.view)
      controller.didMove(toParentViewController: self)
      
      scrollViewContentView.addConstraint(NSLayoutConstraint(item: controller.view, attribute: .top, relatedBy: .equal, toItem: scrollViewContentView, attribute: .top, multiplier: 1, constant: 0))
      scrollViewContentView.addConstraint(NSLayoutConstraint(item: controller.view, attribute: .bottom, relatedBy: .equal, toItem: scrollViewContentView, attribute: .bottom, multiplier: 1, constant: 0))
      scrollView.addConstraint(NSLayoutConstraint(item: controller.view, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: 0))
      scrollView.addConstraint(NSLayoutConstraint(item: controller.view, attribute: .height, relatedBy: .equal, toItem: scrollView, attribute: .height, multiplier: 1, constant: 0))

      if i == 0 {
        scrollViewContentView.addConstraint(NSLayoutConstraint(item: controller.view, attribute: .left, relatedBy: .equal, toItem: scrollViewContentView, attribute: .left, multiplier: 1, constant: 0))
      } else {
        scrollViewContentView.addConstraint(NSLayoutConstraint(item: controller.view, attribute: .left, relatedBy: .equal, toItem: self.controllers[i-1].view, attribute: .right, multiplier: 1, constant: 0))
      }

      if i == self.controllers.count - 1 {
        scrollViewContentView.addConstraint(NSLayoutConstraint(item: controller.view, attribute: .right, relatedBy: .equal, toItem: scrollViewContentView, attribute: .right, multiplier: 1, constant: 0))
      }
    }
  }

  // MARK: - Index

  func goAndNotify() {
    let point = CGPoint(x: scrollView.frame.size.width * CGFloat(selectedIndex), y: scrollView.contentOffset.y)

    DispatchQueue.main.async {
      self.scrollView.setContentOffset(point, animated: false)
    }

    notify()
  }

  func updateAndNotify(_ index: Int) {
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

extension PagesController: PageIndicatorDelegate {

  func pageIndicator(_ pageIndicator: PageIndicator, didSelect index: Int) {
    let point = CGPoint(x: scrollView.frame.size.width * CGFloat(index), y: scrollView.contentOffset.y)
    scrollView.setContentOffset(point, animated: false)
    updateAndNotify(index)
  }

}

extension PagesController: UIScrollViewDelegate {

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let index = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
    pageIndicator.select(index: index)
    updateAndNotify(index)
  }
}
