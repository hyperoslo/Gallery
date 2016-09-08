import UIKit

public struct Config {

  public struct PageIndicator {
    public static var backgroundColor: UIColor = UIColor(red: 0, green: 3/255, blue: 10/255, alpha: 1)
    public static var textColor: UIColor = UIColor.whiteColor()
  }

  public struct Camera {

    public static var recordLocation: Bool = false

    public struct ShutterButton {
      public static var numberColor: UIColor = UIColor(red: 54/255, green: 56/255, blue: 62/255, alpha: 1)
    }

    public struct BottomContainer {
      public static var backgroundColor: UIColor = UIColor(red: 3/255, green: 15/255, blue: 29/255, alpha: 0.7)
    }

    public struct StackView {
      public static let imageCount: Int = 4
    }
  }

  public struct Grid {

    public struct CloseButton {
      public static var tintColor: UIColor = UIColor(red: 109/255, green: 107/255, blue: 132/255, alpha: 1)
    }

    public struct ArrowButton {
      public static var tintColor: UIColor = UIColor(red: 110/255, green: 117/255, blue: 131/255, alpha: 1)
    }

    public struct FrameView {
      public static var borderColor: UIColor = UIColor(red: 0, green: 239/255, blue: 155/255, alpha: 1)
    }

    struct Dimension {
      static let columnCount: CGFloat = 4
      static let cellSpacing: CGFloat = 2
    }
  }

  public struct Font {

    public struct Main {
      public static var light: UIFont = UIFont.systemFontOfSize(1)
      public static var regular: UIFont = UIFont.systemFontOfSize(1)
      public static var bold: UIFont = UIFont.boldSystemFontOfSize(1)
    }

    public struct Text {
      public static var regular: UIFont = UIFont.systemFontOfSize(1)
      public static var bold: UIFont = UIFont.boldSystemFontOfSize(1)
      public static var semibold: UIFont = UIFont.boldSystemFontOfSize(1)
    }
  }

  public struct VideoEditor {

    public static var savesEditedVideoToLibrary: Bool = false
    public static var maximumDuration: NSTimeInterval = 15
    public static var portraitSize: CGSize = CGSize(width: 360, height: 640)
    public static var landscapeSize: CGSize = CGSize(width: 640, height: 360)
  }
}
