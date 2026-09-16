import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController

    if let widthValue = ProcessInfo.processInfo.environment["MARKETING_WINDOW_WIDTH"],
       let heightValue = ProcessInfo.processInfo.environment["MARKETING_WINDOW_HEIGHT"],
       let width = Double(widthValue),
       let height = Double(heightValue) {
      // setContentSize sizes the content view itself (excluding the title
      // bar), so the captured canvas matches these dimensions exactly.
      // setFrame below sizes the whole window instead, which would leave the
      // content view short by the title bar height.
      self.setContentSize(NSSize(width: width, height: height))
      self.center()
    } else {
      let screenFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
      let windowWidth: CGFloat = 420
      let windowHeight: CGFloat = 820
      let originX = screenFrame.midX - windowWidth / 2
      let originY = screenFrame.midY - windowHeight / 2
      let newFrame = NSRect(x: originX, y: originY, width: windowWidth, height: windowHeight)
      self.setFrame(newFrame, display: true)
    }
    self.minSize = NSSize(width: 360, height: 640)
    self.title = "MemoLingo"

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
