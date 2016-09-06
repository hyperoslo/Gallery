import Foundation

extension Array {

  mutating func g_moveToFirst(index: Int) {
    guard index != 0 && index < count else { return }

    let item = self[index]
    removeAtIndex(index)
    insert(item, atIndex: 0)
  }
}
