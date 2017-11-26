//
//  KeyBindingLabel.swift
//  KeyCommandKit
//
//  Created by Bruno Philipe on 26/11/17.
//

import UIKit

@IBDesignable
public class KeyBindingLabel: UIView
{
	@IBInspectable public var color: UIColor = .darkText
	@IBInspectable public var targetHeight: CGFloat = 28

	public var keyBinding: KeyBinding? = nil
	{
		didSet
		{
			buildKeyCommandRepresentation()
		}
	}

	@IBOutlet public var modifiersStackView: UIStackView!
	@IBOutlet public var inputStackView: UIStackView!

	public func buildKeyCommandRepresentation()
	{
		buildKeyModifiersRepresentation()
		buildKeyInputRepresentation()
	}

	private func buildKeyModifiersRepresentation()
	{
		let views = modifiersStackView.arrangedSubviews

		for view in views
		{
			modifiersStackView.removeArrangedSubview(view)
			view.removeFromSuperview()
		}

		guard let modifiers = keyBinding?.modifiers else
		{
			return
		}

		if modifiers.contains(.control)
		{
			modifiersStackView.addArrangedSubview(makeImage("control"))
		}

		if modifiers.contains(.alternate)
		{
			modifiersStackView.addArrangedSubview(makeImage("option"))
		}

		if modifiers.contains(.shift)
		{
			modifiersStackView.addArrangedSubview(makeImage("shift"))
		}

		if modifiers.contains(.command)
		{
			modifiersStackView.addArrangedSubview(makeImage("command"))
		}
	}

	private func buildKeyInputRepresentation()
	{
		let views = inputStackView.arrangedSubviews

		for view in views
		{
			inputStackView.removeArrangedSubview(view)
			view.removeFromSuperview()
		}

		guard let input = keyBinding?.input else
		{
			return
		}

		switch input
		{
		case UIKeyInputLeftArrow:
			inputStackView.addArrangedSubview(makeImage("left"))

		case UIKeyInputRightArrow:
			inputStackView.addArrangedSubview(makeImage("right"))

		case UIKeyInputUpArrow:
			inputStackView.addArrangedSubview(makeImage("up"))

		case UIKeyInputDownArrow:
			inputStackView.addArrangedSubview(makeImage("down"))

		case UIKeyInputEscape:
			inputStackView.addArrangedSubview(makeImage("esc"))

		case UIKeyInputBackspace:
			inputStackView.addArrangedSubview(makeImage("backspace"))

		case UIKeyInputDelete:
			inputStackView.addArrangedSubview(makeImage("delete"))

		case UIKeyInputTab:
			inputStackView.addArrangedSubview(makeImage("tab"))

		case UIKeyInputReturn:
			inputStackView.addArrangedSubview(makeImage("return"))

		default:
			inputStackView.addArrangedSubview(makeLabel(input.uppercased()))
		}
	}

	lazy var attributes: [NSAttributedStringKey: Any] = [
		.paragraphStyle: paragraphStyle,
		.foregroundColor: UIColor.white,
		.font: UIFont.systemFont(ofSize: targetHeight * 1.35)
	]

	lazy var paragraphStyle: NSParagraphStyle =
	{
		var paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 0
		paragraphStyle.paragraphSpacing = 0
		paragraphStyle.headIndent = 0
		paragraphStyle.tailIndent = 0
		paragraphStyle.firstLineHeadIndent = 0
		paragraphStyle.minimumLineHeight = targetHeight
		paragraphStyle.maximumLineHeight = 0
		paragraphStyle.tabStops = nil
		paragraphStyle.defaultTabInterval = 0
		return paragraphStyle
	}()

	private func makeLabel(_ text: String) -> UILabel
	{
		let label = UILabel()
		label.attributedText = NSAttributedString(string: text, attributes: attributes)
		label.clipsToBounds = false
		label.textColor = color
		return label
	}

	private func makeImage(_ name: String) -> UIView
	{
		let image = UIImage(named: name, in: Bundle(for: KeyBindingLabel.self), compatibleWith: nil)
		let maskView = UIImageView(image: image)
		maskView.contentMode = .scaleAspectFit

		if let image = image
		{
			let colorView = FillView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
			colorView.fillColor = color
			colorView.widthAnchor.constraint(greaterThanOrEqualToConstant: image.size.width).isActive = true

			let containerHeight = bounds.height
			let targetHeight = self.targetHeight
			maskView.frame = CGRect(x: 0, y: containerHeight / 2 - targetHeight / 2, width: targetHeight * 1.3, height: targetHeight)

			colorView.mask = maskView

			return colorView
		}
		else
		{
			return maskView
		}
	}
}

class FillView: UIView
{
	var fillColor: UIColor = .white

	override func draw(_ rect: CGRect)
	{
		fillColor.setFill()
		UIRectFill(rect)
	}
}
