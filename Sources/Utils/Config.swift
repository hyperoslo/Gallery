import UIKit

public struct Config {

  public struct PageIndicator {
    public static var backgroundColor: UIColor = UIColor(red: 0, green: 3/255, blue: 10/255, alpha: 1)
    public static var textColor: UIColor = UIColor.whiteColor()
  }

  public struct Camera {

    public static var recordLocation: Bool = true

    public struct ShutterButton {
      public static var numberColor: UIColor = UIColor(red: 54/255, green: 56/255, blue: 62/255, alpha: 1)
    }

    public struct BottomContainer {
      public static var backgroundColor: UIColor = UIColor(red: 3/255, green: 15/255, blue: 29/255, alpha: 0.7)
    }
  }

  public struct Grid {

    public struct CloseButton {
      public static var tintColor: UIColor = UIColor(red: 109/255, green: 107/255, blue: 132/255, alpha: 1)
    }

    public struct ArrowButton {
      public static var tintColor: UIColor = UIColor(red: 110/255, green: 117/255, blue: 131/255, alpha: 1)
    }

    public struct BottomContainer {
      public static var backgroundColor: UIColor = UIColor(red: 3/255, green: 15/255, blue: 29/255, alpha: 0.7)
    }

    public struct FrameView {
      public static var borderColor: UIColor = UIColor(red: 0, green: 239/255, blue: 155/255, alpha: 1)
    }
  }
}
