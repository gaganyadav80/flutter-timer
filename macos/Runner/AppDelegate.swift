import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  var statusBar: StatusBarController?
  var popover = NSPopover.init()
  override init() {
    popover.behavior = NSPopover.Behavior.transient // To make the popover hide when the user clicks outside of it
  }
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }
  override func applicationDidFinishLaunching(_ aNotification: Notification) {
    let controller: FlutterViewController =
      mainFlutterWindow?.contentViewController as! FlutterViewController
    popover.contentSize = NSSize(width: 280, height: 140) // Change this to your desired size
    popover.contentViewController = controller // Set the content view controller for the popover to flutter view controller
    statusBar = StatusBarController.init(popover)
    mainFlutterWindow.close() // Close the default flutter window
    super.applicationDidFinishLaunching(aNotification)
  }
}