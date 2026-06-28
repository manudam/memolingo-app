import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController

    let screenFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
    let windowWidth: CGFloat = 420
    let windowHeight: CGFloat = 820
    let originX = screenFrame.midX - windowWidth / 2
    let originY = screenFrame.midY - windowHeight / 2
    let newFrame = NSRect(x: originX, y: originY, width: windowWidth, height: windowHeight)
    self.setFrame(newFrame, display: true)
    self.minSize = NSSize(width: 360, height: 640)
    self.title = "MemoLingo"

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
