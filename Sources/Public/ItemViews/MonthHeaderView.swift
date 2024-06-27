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

// MARK: - MonthHeaderView

/// A view that represents a day-of-the-week header in a calendar month. For example, Sun, Mon, Tue, etc.
public final class MonthHeaderView: UIView {

  // MARK: Lifecycle

  fileprivate init(invariantViewProperties: InvariantViewProperties) {
    self.invariantViewProperties = invariantViewProperties

    label = UILabel()
    label.font = invariantViewProperties.font
    label.textAlignment = invariantViewProperties.textAlignment
    label.textColor = invariantViewProperties.textColor

    // if monthsLayout == .horizontal { 
    //   label.isHidden = true
    // }
    // else if monthsLayout == .vertical { 
    //   label.isHidden = false
    // }

    super.init(frame: .zero)

    if monthsLayout == .vertical { 
      label.isHidden = false
    }
    else if monthsLayout == .horizontal { 
      label.isHidden = true
    }

    isUserInteractionEnabled = false

    backgroundColor = invariantViewProperties.backgroundColor

    label.translatesAutoresizingMaskIntoConstraints = false
    addSubview(label)

    let edgeInsets = invariantViewProperties.edgeInsets
    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: topAnchor, constant: edgeInsets.top),
      label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: edgeInsets.bottom),
      label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: edgeInsets.leading),
      label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: edgeInsets.trailing),
    ])
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Fileprivate

  fileprivate func setContent(_ content: Content) {
    label.text = content.monthText
    accessibilityLabel = content.accessibilityLabel
    self.monthsLayout = content.monthsLayout
  }

  // MARK: Private

  private let invariantViewProperties: InvariantViewProperties
  private let label: UILabel
  private var monthsLayout: MonthsLayout?
}

// MARK: Accessibility

extension MonthHeaderView {

  public override var isAccessibilityElement: Bool {
    get { true }
    set { }
  }

  public override var accessibilityTraits: UIAccessibilityTraits {
    get { invariantViewProperties.accessibilityTraits }
    set { }
  }

}

// MARK: MonthHeaderView.Content

extension MonthHeaderView {

  /// Encapsulates the data used to populate a `MonthHeaderView`'s text label. Use a `DateFormatter` to create the
  /// `monthText` and `accessibilityLabel` strings.
  ///
  /// - Note: To avoid performance issues, reuse the same `DateFormatter` for each month, rather than creating
  /// a new `DateFormatter` for each month.
  public struct Content: Equatable {

    // MARK: Lifecycle

    public init(monthText: String, accessibilityLabel: String?, monthsLayout: MonthsLayout) {
      self.monthText = monthText
      self.accessibilityLabel = accessibilityLabel
      self.monthsLayout = monthsLayout
    }

    // MARK: Public

    public let monthText: String
    public let accessibilityLabel: String?
    public let monthsLayout: MonthsLayout
  }

}

// MARK: MonthHeaderView.InvariantViewProperties

extension MonthHeaderView {

  /// Encapsulates configurable properties that change the appearance and behavior of `MonthHeaderView`. These cannot be
  /// changed after a `MonthHeaderView` is initialized.
  public struct InvariantViewProperties: Hashable {

    // MARK: Lifecycle

    private init() { }

    // MARK: Public

    public static let base = InvariantViewProperties()

    /// The background color of the entire view, unaffected by `edgeInsets`.
    public var backgroundColor = UIColor.clear

    /// Edge insets that change the position of the month's label.
    public var edgeInsets = NSDirectionalEdgeInsets.zero

    /// The font of the month's label.
    public var font = UIFont.systemFont(ofSize: 22)

    /// The text alignment of the month's label.
    public var textAlignment = NSTextAlignment.natural

    /// The text color of the month's label.
    public var textColor: UIColor = {
      if #available(iOS 13.0, *) {
        return .label
      } else {
        return .black
      }
    }()

    /// The accessibility traits of the `MonthHeaderView`.
    public var accessibilityTraits = UIAccessibilityTraits.header

    public func hash(into hasher: inout Hasher) {
      hasher.combine(backgroundColor)
      hasher.combine(edgeInsets.leading)
      hasher.combine(edgeInsets.trailing)
      hasher.combine(edgeInsets.top)
      hasher.combine(edgeInsets.bottom)
      hasher.combine(font)
      hasher.combine(textAlignment)
      hasher.combine(textColor)
      hasher.combine(accessibilityTraits)
    }

  }

}

// MARK: CalendarItemViewRepresentable

extension MonthHeaderView: CalendarItemViewRepresentable {

  public static func makeView(
    withInvariantViewProperties invariantViewProperties: InvariantViewProperties)
    -> MonthHeaderView
  {
    MonthHeaderView(invariantViewProperties: invariantViewProperties)
  }

  public static func setContent(_ content: Content, on view: MonthHeaderView) {
    view.setContent(content)
  }

}
