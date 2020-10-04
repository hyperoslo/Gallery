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

    view.backgroundColor = Config.PageIndicator.backgroundColor
    setup()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    guard scrollView.frame.size.width > 0 else {
      return
    }

    once.run {
      DispatchQueue.main.async {
        self.scrollToAndSelect(index: self.selectedIndex, animated: false)
      }

      notify()
    }
  }

  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    let index = selectedIndex

    coordinator.animate(alongsideTransition: { context in
      self.scrollToAndSelect(index: index, animated: context.isAnimated)
    }) { _ in }

    super.viewWillTransition(to: size, with: coordinator)
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
    let items = controllers.compactMap { $0.title }
    let indicator = PageIndicator(items: items)
    indicator.delegate = self

    return indicator
  }

  // MARK: - Setup

  func setup() {
    let usePageIndicator = controllers.count > 1
    if usePageIndicator {
      view.addSubview(pageIndicator)
      Constraint.on(
        pageIndicator.leftAnchor.constraint(equalTo: pageIndicator.superview!.leftAnchor),
        pageIndicator.rightAnchor.constraint(equalTo: pageIndicator.superview!.rightAnchor),
        pageIndicator.heightAnchor.constraint(equalToConstant: 40)
      )
      
      if #available(iOS 11, *) {
        Constraint.on(
          pageIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        )
      } else {
        Constraint.on(
          pageIndicator.bottomAnchor.constraint(equalTo: pageIndicator.superview!.bottomAnchor)
        )
      }
    }
    
    view.addSubview(scrollView)
    scrollView.addSubview(scrollViewContentView)

    if #available(iOS 11.0, *) {
      scrollView.contentInsetAdjustmentBehavior = .never
    }
    
    scrollView.g_pinUpward()
    if usePageIndicator {
      scrollView.g_pin(on: .bottom, view: pageIndicator, on: .top)
    } else {
      scrollView.g_pinDownward()
    }

    scrollViewContentView.g_pinEdges()

    for (i, controller) in controllers.enumerated() {
        addChild(controller)
      scrollViewContentView.addSubview(controller.view)
        controller.didMove(toParent: self)

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

  fileprivate func scrollTo(index: Int, animated: Bool) {
    guard !scrollView.isTracking && !scrollView.isDragging && !scrollView.isZooming else {
      return
    }

    let point = CGPoint(x: scrollView.frame.size.width * CGFloat(index), y: scrollView.contentOffset.y)
    scrollView.setContentOffset(point, animated: animated)
  }

  fileprivate func scrollToAndSelect(index: Int, animated: Bool) {
    scrollTo(index: index, animated: animated)
    pageIndicator.select(index: index, animated: animated)
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
    scrollTo(index: index, animated: false)
    updateAndNotify(index)
  }
}

extension PagesController: UIScrollViewDelegate {

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let index = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
    if index >= controllers.count || index < 0 {
        return
    }
    pageIndicator.select(index: index)
    updateAndNotify(index)
  }
}
