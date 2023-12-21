// Created by Bryan Keller on 9/12/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit

// MARK: - DayOfWeekView

/// A view that represents a day-of-the-week header in a calendar month. For example, Sun, Mon, Tue, etc.
public final class DayOfWeekView: UIView {

  // MARK: Lifecycle

  fileprivate init(invariantViewProperties: InvariantViewProperties) {
    self.invariantViewProperties = invariantViewProperties

    backgroundLayer = CAShapeLayer()
    let backgroundShapeDrawingConfig = invariantViewProperties.backgroundShapeDrawingConfig
    // backgroundLayer.backgroundColor = UIColor.clear.cgColor
    backgroundLayer.strokeColor = backgroundShapeDrawingConfig.borderColor.cgColor
    backgroundLayer.lineWidth = backgroundShapeDrawingConfig.borderWidth
    backgroundLayer.backgroundColor = UIColor.globalBackgroundColor.cgColor
    backgroundLayer.fillColor = UIColor.globalBackgroundColor.cgColor
   // self.backgroundColor = UIColor.globalFirstLayerViewColor

    // if monthsLayout ?? .horizontal == .horizontal { 
    //   backgroundLayer.backgroundColor = UIColor.globalFirstLayerViewColor.cgColor
    //   backgroundLayer.fillColor = UIColor.globalFirstLayerViewColor.cgColor
    //   self.backgroundColor = UIColor.globalFirstLayerViewColor
    // }
    // else { 
    //   backgroundLayer.backgroundColor = UIColor.globalBackgroundColor.cgColor
    //   backgroundLayer.fillColor = UIColor.globalBackgroundColor.cgColor
    //   self.backgroundColor = UIColor.globalBackgroundColor
    // }

    label = UILabel()
    label.font = invariantViewProperties.font
    label.textAlignment = invariantViewProperties.textAlignment
    label.textColor = invariantViewProperties.textColor
    label.isAccessibilityElement = false

    super.init(frame: .zero)

    isUserInteractionEnabled = false
if monthsLayout ?? .horizontal == .horizontal { 
      backgroundLayer.backgroundColor = UIColor.globalFirstLayerViewColor.cgColor
      backgroundLayer.fillColor = UIColor.globalFirstLayerViewColor.cgColor
      self.backgroundColor = UIColor.globalFirstLayerViewColor
    }
    else { 
      backgroundLayer.backgroundColor = UIColor.globalBackgroundColor.cgColor
      backgroundLayer.fillColor = UIColor.globalBackgroundColor.cgColor
      self.backgroundColor = UIColor.globalBackgroundColor
    }
    

    layer.addSublayer(backgroundLayer)
    // layer.backgroundColor = UIColor.clear

    addSubview(label)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public override func layoutSubviews() {
    super.layoutSubviews()

    let edgeInsets = invariantViewProperties.edgeInsets
    let insetBounds = bounds.inset(
      by: UIEdgeInsets(
        top: 0,
        left: edgeInsets.leading,
        bottom: edgeInsets.bottom,
        right: edgeInsets.trailing))

    let path: CGPath
    switch invariantViewProperties.shape {
    case .circle:
      path = UIBezierPath(
        ovalIn: CGRect(
          origin: CGPoint(x: edgeInsets.leading, y: edgeInsets.top),
          size: insetBounds.size)).cgPath

    case .rectangle(let cornerRadius):
      path = UIBezierPath(roundedRect: insetBounds, cornerRadius: cornerRadius).cgPath
    }

    backgroundLayer.path = path

    label.frame = CGRect(
      x: edgeInsets.leading,
      y: edgeInsets.top,
      width: insetBounds.width,
      height: insetBounds.height)
  }

  // MARK: Fileprivate

  fileprivate func setContent(_ content: Content) {
    label.text = content.dayOfWeekText
    monthsLayout = content.monthsLayout
    accessibilityLabel = content.accessibilityLabel
  }

  // MARK: Private

  private let invariantViewProperties: InvariantViewProperties
  private let backgroundLayer: CAShapeLayer
  private let label: UILabel
  private var monthsLayout: MonthsLayout?
}

// MARK: Accessibility

extension DayOfWeekView {

  public override var isAccessibilityElement: Bool {
    get { invariantViewProperties.isAccessibilityElement }
    set { }
  }

  public override var accessibilityTraits: UIAccessibilityTraits {
    get { invariantViewProperties.accessibilityTraits }
    set { }
  }

}

// MARK: DayOfWeekView.Content

extension DayOfWeekView {

  /// Encapsulates the data used to populate a `DayOfWeekView`'s text label. Use the `Calendar` with which you initialized
  /// your `CalendarView` to access localized weekday symbols. For example, you can use
  /// `calendar.shortWeekdaySymbols` or `calendar.veryShortWeekdaySymbols`. For the `accessibilityLabel`,
  /// consider using the full-length symbol names in `calendar.weekdaySymbols`.
  public struct Content: Equatable {

    // MARK: Lifecycle

    public init(dayOfWeekText: String, accessibilityLabel: String?, monthsLayout: MonthsLayout) {
      self.dayOfWeekText = dayOfWeekText
      self.accessibilityLabel = accessibilityLabel
      self.monthsLayout = monthsLayout
    }

    // MARK: Public

    public let dayOfWeekText: String
    public let accessibilityLabel: String?
    public let monthsLayout: MonthsLayout
  }

}

// MARK: DayOfWeekView.InvariantViewProperties

extension DayOfWeekView {

  /// Encapsulates configurable properties that change the appearance and behavior of `DayOfWeekView`. These cannot be
  /// changed after a `DayOfWeekView` is initialized.
  public struct InvariantViewProperties: Hashable {

    // MARK: Lifecycle

    private init() { }

    // MARK: Public

    public static let base = InvariantViewProperties()

    /// The background color of the entire view, unaffected by `edgeInsets` and behind the background layer.
    public var backgroundColor = UIColor.globalBackgroundColor

    /// Edge insets that apply to the background layer and text label.
    public var edgeInsets = NSDirectionalEdgeInsets.zero

    /// The shape of the the background layer.
    public var shape = Shape.circle

    /// The drawing config for the always-visible background layer.
    public var backgroundShapeDrawingConfig = DrawingConfig()

    /// The font of the day-of-the-week label.
    public var font = UIFont.systemFont(ofSize: 16)

    /// The text alignment of the day-of-the-week label.
    public var textAlignment = NSTextAlignment.center

    /// The text color of the day-of-the-week label.
    public var textColor: UIColor = {
      if #available(iOS 13.0, *) {
        return .secondaryLabel
      } else {
        return .black
      }
    }()

    /// Whether or not the `DayOfWeekView` is an accessibility element or not.
    ///
    /// By default, this property is set to `false`. It may not be necessary for individual day-of-the-week headers to be focused by
    /// VoiceOver, especially when your day views have accessibility labels that include the day of the week. For example, your day
    /// view might have an accessibility label of "Sunday, September 12th, 2021."
    public var isAccessibilityElement = false

    /// The accessibility traits of the `DayOfWeekView`.
    public var accessibilityTraits = UIAccessibilityTraits.none

    public func hash(into hasher: inout Hasher) {
      hasher.combine(backgroundColor)
      hasher.combine(edgeInsets.leading)
      hasher.combine(edgeInsets.trailing)
      hasher.combine(edgeInsets.top)
      hasher.combine(edgeInsets.bottom)
      hasher.combine(shape)
      hasher.combine(backgroundShapeDrawingConfig)
      hasher.combine(font)
      hasher.combine(textAlignment)
      hasher.combine(textColor)
      hasher.combine(isAccessibilityElement)
      hasher.combine(accessibilityTraits)
    }
    public static func == (lhs: DayOfWeekView.InvariantViewProperties, rhs: DayOfWeekView.InvariantViewProperties) -> Bool {
            lhs.isAccessibilityElement == rhs.isAccessibilityElement
    }
  }
}

// MARK: CalendarItemViewRepresentable

extension DayOfWeekView: CalendarItemViewRepresentable {

  public static func makeView(
    withInvariantViewProperties invariantViewProperties: InvariantViewProperties)
    -> DayOfWeekView
  {
    DayOfWeekView(invariantViewProperties: invariantViewProperties)
  }

  public static func setContent(_ content: Content, on view: DayOfWeekView) {
    view.setContent(content)
  }

}

extension UIColor {
    static let blackD1 = UIColor(red: 15 / 255.0, green: 15 / 255.0, blue: 15 / 255.0, alpha: 1.0)
    static let grayD1 = UIColor(red: 30 / 255.0, green: 30 / 255.0, blue: 31 / 255.0, alpha: 1.0)
    static let whiteD1 = UIColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0, alpha: 1.0)
    static let whiteD2 = UIColor(red: 246 / 255.0, green: 246 / 255.0, blue: 246 / 255.0, alpha: 1.0)
    static let globalBackgroundColor = color(light: whiteD2, dark: blackD1)
    static let globalFirstLayerViewColor = color(light: .whiteD1, dark: .grayD1)

    static func color(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.init { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ? dark : light
            }
        } else {
            return UIColor.clear
        }
    }
}
