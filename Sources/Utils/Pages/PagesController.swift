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
    let usePageIndicator = controllers.count > 1
    if usePageIndicator {
      view.addSubview(pageIndicator)
    }
    view.addSubview(scrollView)
    scrollView.addSubview(scrollViewContentView)

    pageIndicator.g_pinDownward()
    pageIndicator.g_pin(height: 40)

    scrollView.g_pinUpward()
    if usePageIndicator {
      scrollView.g_pin(on: .bottom, view: pageIndicator, on: .top)
    } else {
      scrollView.g_pinDownward()
    }

    scrollViewContentView.g_pinEdges()

    for (i, controller) in controllers.enumerated() {
      addChildViewController(controller)
      scrollViewContentView.addSubview(controller.view)
      controller.didMove(toParentViewController: self)

      controller.view.g_pin(on: .top)
      controller.view.g_pin(on: .bottom)
      controller.view.g_pin(on: .width, view: scrollView)
      controller.view.g_pin(on: .height, view: scrollView)

      if i == 0 {
        controller.view.g_pin(on: .left)
      } else {
        controller.view.g_pin(on: .left, view: self.controllers[i-1].view, on: .right)
      }

      if i == self.controllers.count - 1 {
        controller.view.g_pin(on: .right)
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
