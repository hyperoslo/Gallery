import UIKit

class TripleButton: UIButton {

  struct State {
    let title: String
    let image: UIImage
  }

  let states: [State]
  var selectedIndex: Int = 0

  // MARK: - Initialization

  init(states: [State]) {
    self.states = states
    super.init(frame: .zero)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup

  func setup() {
    titleLabel?.font = Config.Font.Text.semibold.withSize(12)
    imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
    setTitleColor(UIColor.gray, for: .highlighted)

    select(index: selectedIndex)
  }

  // MARK: - Logic

  @discardableResult func toggle() -> Int {
    selectedIndex = (selectedIndex + 1) % states.count
    select(index: selectedIndex)

    return selectedIndex
  }

  func select(index: Int) {
    guard index < states.count else { return }

    let state = states[index]

    setTitle(state.title, for: UIControlState())
    setImage(state.image, for: UIControlState())
  }
}
