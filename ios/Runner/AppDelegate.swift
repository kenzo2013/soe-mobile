import Flutter
import QuickLook
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "SoePdfPreview") {
      PdfPreview.register(messenger: registrar.messenger())
    }
  }
}

/// Shows a PDF (receipt, contract) in QuickLook inside a navigation bar that always shows a
/// close button: the bare preview of the system viewer has none on recent iOS versions.
/// Channel `soe/pdf_preview`, method `open` {path, title, close} → true once shown.
final class PdfPreview: NSObject, QLPreviewControllerDataSource {
  private static var channel: FlutterMethodChannel?
  private static var current: PdfPreview?

  private let item: PdfItem

  private init(item: PdfItem) {
    self.item = item
  }

  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "soe/pdf_preview", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard call.method == "open",
        let args = call.arguments as? [String: Any],
        let path = args["path"] as? String
      else {
        result(FlutterMethodNotImplemented)
        return
      }
      result(
        open(
          path: path, title: args["title"] as? String,
          close: args["close"] as? String ?? "Close"))
    }
    self.channel = channel
  }

  private static func open(path: String, title: String?, close: String) -> Bool {
    guard FileManager.default.fileExists(atPath: path), let top = topViewController() else {
      return false
    }
    let preview = PdfItem(url: URL(fileURLWithPath: path), title: title)
    let source = PdfPreview(item: preview)
    current = source
    let controller = ClosablePreviewController(closeTitle: close)
    controller.dataSource = source
    let navigation = AlwaysVisibleBarNavigationController(rootViewController: controller)
    navigation.modalPresentationStyle = .fullScreen
    top.present(navigation, animated: true)
    return true
  }

  private static func topViewController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let windows = scenes.flatMap { $0.windows }
    var top = (windows.first { $0.isKeyWindow } ?? windows.first)?.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }

  func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }

  func previewController(_ controller: QLPreviewController, previewItemAt index: Int)
    -> QLPreviewItem
  {
    item
  }
}

private final class PdfItem: NSObject, QLPreviewItem {
  let previewItemURL: URL?
  let previewItemTitle: String?

  init(url: URL, title: String?) {
    previewItemURL = url
    previewItemTitle = title
  }
}

/// The preview with « Fermer » on the left of its bar (QuickLook keeps sharing on the right).
private final class ClosablePreviewController: QLPreviewController {
  private let closeTitle: String

  init(closeTitle: String) {
    self.closeTitle = closeTitle
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) is not used")
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    installClose()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    installClose()
  }

  private func installClose() {
    let button = UIBarButtonItem(
      title: closeTitle, style: .done, target: self, action: #selector(closeTapped))
    button.accessibilityLabel = closeTitle
    navigationItem.leftBarButtonItem = button
  }

  @objc private func closeTapped() {
    dismiss(animated: true)
  }
}

/// QuickLook hides its bar on a tap (full screen); the close button must stay in reach.
private final class AlwaysVisibleBarNavigationController: UINavigationController {
  override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
    super.setNavigationBarHidden(false, animated: animated)
  }

  override var isNavigationBarHidden: Bool {
    get { super.isNavigationBarHidden }
    set { super.isNavigationBarHidden = false }
  }
}
