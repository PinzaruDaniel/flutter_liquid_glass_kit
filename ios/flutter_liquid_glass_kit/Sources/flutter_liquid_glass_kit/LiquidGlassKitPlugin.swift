import Flutter
import UIKit
import SwiftUI

// MARK: - Plugin Entry Point

public class LiquidGlassKitPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()
    let surfaceFactory = LiquidGlassSurfaceFactory(messenger: messenger)
    let navBarFactory = LiquidGlassNavBarFactory(messenger: messenger)
    registrar.register(surfaceFactory, withId: "flutter_liquid_glass_kit/glass_surface")
    registrar.register(navBarFactory, withId: "flutter_liquid_glass_kit/native_nav_bar")
  }
}

// MARK: - PlatformView Factory

class LiquidGlassSurfaceFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    return LiquidGlassSurfaceView(
      frame: frame,
      viewIdentifier: viewId,
      arguments: args as? [String: Any]
    )
  }

  public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }
}

// MARK: - Native iOS Navigation Bar Factory

class LiquidGlassNavBarFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    return LiquidGlassNavBarView(
      frame: frame,
      viewIdentifier: viewId,
      messenger: messenger,
      arguments: args as? [String: Any]
    )
  }

  public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }
}

// MARK: - PlatformView

class LiquidGlassSurfaceView: NSObject, FlutterPlatformView {
  private var _view: UIView
  private var hostingController: UIViewController?

  init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: [String: Any]?) {
    _view = UIView(frame: frame)
    super.init()
    setupGlassView(frame: frame, args: args)
  }

  func view() -> UIView { _view }

  private func setupGlassView(frame: CGRect, args: [String: Any]?) {
    let cornerRadius = args?["cornerRadius"] as? CGFloat ?? 24
    let tintOpacity  = args?["tintOpacity"]  as? Double   ?? 0.15
    let tintHex      = args?["tintColorHex"] as? String

    if #available(iOS 26.0, *) {
      // ── Native iOS 26 Liquid Glass ─────────────────────────────────────────
      let controller = UIHostingController(
        rootView: LiquidGlassSurface(
          cornerRadius: cornerRadius,
          tintOpacity: tintOpacity,
          tintColorHex: tintHex
        )
      )
      controller.view.frame = frame
      controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      controller.view.backgroundColor = .clear
      controller.view.isOpaque = false
      hostingController = controller
      _view = controller.view
    } else {
      // ── Legacy glassmorphism fallback (< iOS 26) ───────────────────────────
      _view = makeFallbackGlass(
        frame: frame,
        cornerRadius: cornerRadius,
        tintOpacity: tintOpacity,
        tintHex: tintHex
      )
    }
  }

  // MARK: Fallback blur view for iOS < 26

  private func makeFallbackGlass(
    frame: CGRect,
    cornerRadius: CGFloat,
    tintOpacity: Double,
    tintHex: String?
  ) -> UIView {
    let container = UIView(frame: frame)
    container.backgroundColor = .clear
    container.layer.cornerRadius = cornerRadius
    container.clipsToBounds = true

    // Background blur
    let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    blur.frame = container.bounds
    blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    container.addSubview(blur)

    // Optional tint
    let tintView = UIView(frame: container.bounds)
    tintView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    tintView.backgroundColor = liquidGlassColor(from: tintHex ?? "#FFFFFFFF")
      .withAlphaComponent(CGFloat(tintOpacity))
    container.addSubview(tintView)

    // Border highlight
    container.layer.borderWidth  = 1
    container.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
    container.layer.cornerRadius = cornerRadius

    return container
  }

}

// MARK: - Native iOS Tab Bar

class LiquidGlassNavBarView: NSObject, FlutterPlatformView, UITabBarDelegate {
  private let container: UIView
  private let tabBar: UITabBar
  private let channel: FlutterMethodChannel
  private var items: [UITabBarItem] = []
  private var disposed = false
  private var scrollCollapseScale: CGFloat = 0.82
  private var scrollAnimationDuration: TimeInterval = 0.28

  init(
    frame: CGRect,
    viewIdentifier viewId: Int64,
    messenger: FlutterBinaryMessenger,
    arguments args: [String: Any]?
  ) {
    container = UIView(frame: frame)
    tabBar = UITabBar(frame: container.bounds)
    channel = FlutterMethodChannel(
      name: "flutter_liquid_glass_kit/native_nav_bar_\(viewId)",
      binaryMessenger: messenger
    )
    super.init()
    setup(frame: frame, args: args)
  }

  deinit {
    disposed = true
    tabBar.delegate = nil
    channel.setMethodCallHandler(nil)
  }

  func view() -> UIView { container }

  private func setup(frame: CGRect, args: [String: Any]?) {
    container.backgroundColor = .clear
    container.isOpaque = false
    container.clipsToBounds = false

    tabBar.delegate = self
    tabBar.frame = container.bounds
    tabBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    tabBar.isTranslucent = true
    tabBar.clipsToBounds = false
    tabBar.backgroundImage = UIImage()
    tabBar.shadowImage = UIImage()
    tabBar.layer.borderWidth = 0
    tabBar.layer.shadowOpacity = 0

    if let scale = args?["scrollCollapseScale"] as? Double {
      scrollCollapseScale = min(max(CGFloat(scale), 0.01), 1)
    }
    if let duration = args?["scrollAnimationDurationMillis"] as? Int {
      scrollAnimationDuration = max(Double(duration) / 1000, 0)
    }

    applyAppearance(args: args)
    applyItems(args: args)

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(nil)
        return
      }

      switch call.method {
      case "setCurrentIndex":
        if let index = call.arguments as? Int {
          self.setCurrentIndex(index, animated: true)
        }
        result(nil)
      case "setCollapsed":
        if let configuration = call.arguments as? [String: Any] {
          let collapsed = configuration["collapsed"] as? Bool ?? false
          if let scale = configuration["scale"] as? Double {
            self.scrollCollapseScale = min(max(CGFloat(scale), 0.01), 1)
          }
          if let duration = configuration["durationMillis"] as? Int {
            self.scrollAnimationDuration = max(Double(duration) / 1000, 0)
          }
          self.setCollapsed(collapsed, animated: true)
        } else if let collapsed = call.arguments as? Bool {
          self.setCollapsed(collapsed, animated: true)
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    container.addSubview(tabBar)
  }

  private func applyAppearance(args: [String: Any]?) {
    let tintColor = liquidGlassColor(from: args?["tintColorHex"] as? String ?? "#FF000000")
    let tintOpacity = CGFloat(args?["tintOpacity"] as? Double ?? 0.26)
    let activeColor = liquidGlassColor(from: args?["activeColorHex"] as? String ?? "#FFFFFFFF")
    let inactiveColor = liquidGlassColor(from: args?["inactiveColorHex"] as? String ?? "#99FFFFFF")

    let appearance = UITabBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
    appearance.backgroundColor = tintColor.withAlphaComponent(tintOpacity)
    appearance.shadowColor = .clear

    let itemAppearance = UITabBarItemAppearance()
    itemAppearance.normal.iconColor = inactiveColor
    itemAppearance.normal.titleTextAttributes = [
      .foregroundColor: inactiveColor,
      .font: UIFont.systemFont(ofSize: 11, weight: .medium)
    ]
    itemAppearance.selected.iconColor = activeColor
    itemAppearance.selected.titleTextAttributes = [
      .foregroundColor: activeColor,
      .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
    ]

    appearance.stackedLayoutAppearance = itemAppearance
    appearance.inlineLayoutAppearance = itemAppearance
    appearance.compactInlineLayoutAppearance = itemAppearance

    tabBar.standardAppearance = appearance
    if #available(iOS 15.0, *) {
      tabBar.scrollEdgeAppearance = appearance
    }
    tabBar.tintColor = activeColor
    tabBar.unselectedItemTintColor = inactiveColor
    tabBar.backgroundColor = .clear
  }

  private func applyItems(args: [String: Any]?) {
    let showLabels = args?["showLabels"] as? Bool ?? true
    let rawItems = args?["items"] as? [[String: Any]] ?? []
    let selectedIndex = args?["currentIndex"] as? Int ?? 0

    items = rawItems.enumerated().map { index, raw in
      let label = showLabels ? (raw["label"] as? String ?? "") : nil
      let imageName = raw["iosSystemImage"] as? String
        ?? systemImageName(for: raw["iconCodePoint"] as? Int)
        ?? "circle"
      let selectedImageName = raw["iosSelectedSystemImage"] as? String
        ?? systemImageName(for: raw["activeIconCodePoint"] as? Int)
        ?? imageName
      let item = UITabBarItem(
        title: label,
        image: UIImage(systemName: imageName),
        selectedImage: UIImage(systemName: selectedImageName)
      )
      item.tag = index
      if let badge = raw["badge"] as? Int, badge > 0 {
        item.badgeValue = "\(badge)"
        item.badgeColor = .systemRed
      }
      return item
    }

    tabBar.items = items
    setCurrentIndex(selectedIndex, animated: false)
  }

  private func setCurrentIndex(_ index: Int, animated: Bool) {
    guard items.indices.contains(index) else { return }
    tabBar.selectedItem = items[index]
    if animated {
      animateSelectedItem(index: index)
    }
  }

  private func setCollapsed(_ collapsed: Bool, animated: Bool) {
    let scale = collapsed ? scrollCollapseScale : 1
    let transform = CGAffineTransform(scaleX: scale, y: scale)
    guard animated && scrollAnimationDuration > 0 else {
      tabBar.transform = transform
      return
    }

    UIView.animate(
      withDuration: scrollAnimationDuration,
      delay: 0,
      usingSpringWithDamping: 0.86,
      initialSpringVelocity: 0.2,
      options: [.allowUserInteraction, .beginFromCurrentState],
      animations: {
        self.tabBar.transform = transform
      }
    )
  }

  func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    let selectedIndex = item.tag
    DispatchQueue.main.async { [weak self] in
      guard let self = self, !self.disposed else { return }
      self.animateSelectedItem(index: selectedIndex)
      self.channel.invokeMethod("tap", arguments: selectedIndex)
    }
  }

  private func animateSelectedItem(index: Int) {
    guard
      let selectedView = tabBar.subviews
        .compactMap({ $0 as? UIControl })
        .sorted(by: { $0.frame.minX < $1.frame.minX })
        .enumerated()
        .first(where: { $0.offset == index })?
        .element
    else { return }

    selectedView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
    UIView.animate(
      withDuration: 0.42,
      delay: 0,
      usingSpringWithDamping: 0.62,
      initialSpringVelocity: 0.8,
      options: [.allowUserInteraction, .beginFromCurrentState],
      animations: {
        selectedView.transform = .identity
      }
    )
  }

  private func systemImageName(for codePoint: Int?) -> String? {
    switch codePoint {
    case 0xe318, 0xe88a: return "house.fill"
    case 0xe8b6: return "magnifyingglass"
    case 0xe87d, 0xe87e: return "heart.fill"
    case 0xe7fd, 0xe491: return "person.fill"
    case 0xe5c8: return "chevron.right"
    default: return nil
    }
  }
}

/// Converts Flutter's `#AARRGGBB` colour representation to UIKit colour.
private func liquidGlassColor(from hex: String) -> UIColor {
  var value = hex.trimmingCharacters(in: .whitespacesAndNewlines)
  if value.hasPrefix("#") { value.removeFirst() }
  guard value.count == 6 || value.count == 8, let raw = UInt64(value, radix: 16) else {
    return .white
  }

  let alpha: CGFloat
  let red: CGFloat
  let green: CGFloat
  let blue: CGFloat
  if value.count == 8 {
    alpha = CGFloat((raw >> 24) & 0xFF) / 255
    red = CGFloat((raw >> 16) & 0xFF) / 255
    green = CGFloat((raw >> 8) & 0xFF) / 255
    blue = CGFloat(raw & 0xFF) / 255
  } else {
    alpha = 1
    red = CGFloat((raw >> 16) & 0xFF) / 255
    green = CGFloat((raw >> 8) & 0xFF) / 255
    blue = CGFloat(raw & 0xFF) / 255
  }
  return UIColor(red: red, green: green, blue: blue, alpha: alpha)
}

// MARK: - SwiftUI Surface (iOS 26+)

@available(iOS 26.0, *)
struct LiquidGlassSurface: View {
  let cornerRadius: CGFloat
  let tintOpacity: Double
  let tintColorHex: String?

  private var tintColor: Color {
    Color(uiColor: liquidGlassColor(from: tintColorHex ?? "#FFFFFFFF"))
  }

  var body: some View {
    // The glass modifier paints the material. Adding the tint as the base view
    // would also paint an opaque rectangular layer outside the rounded shape.
    Color.clear
      .glassEffect(
        // `clear` is still native Liquid Glass, but lets the app's background
        // participate in the material instead of turning a large card milky.
        Glass.clear
          .tint(tintColor.opacity(tintOpacity))
          .interactive(true),
        in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
      )
  }
}
