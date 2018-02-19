//
//  KeyBindingEditorViewController.swift
//  KeyCommandKit
//
//  Created by Bruno Philipe on 3/7/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import UIKit

public class KeyBindingEditorViewController: UIViewController
{
	@IBOutlet var _instructionsLabel: UILabel!

	var binding: KeyBinding

	var updatedBinding: KeyBinding?

	var completion: ((KeyBinding?) -> Void)? = nil

	var editorView: KeyBindingEditorView?
	{
		return view as? KeyBindingEditorView
	}

	init(binding: KeyBinding)
	{
		self.binding = binding
		self.updatedBinding = binding
		super.init(nibName: "KeyBindingEditorView", bundle: Bundle(for: KeyBindingEditorViewController.self))

		self.preferredContentSize = CGSize(width: 275.0, height: 200.0)
	}

	required public init?(coder aDecoder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}

	override public func viewDidLoad()
	{
		super.viewDidLoad()

		editorView?.viewController = self
		editorView?.keyBindingDisplayLabel.keyBinding = binding

		navigationItem.title = ""

		if binding is CustomizedKeyBinding
		{
			navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Revert",
			                                                    style: .plain,
			                                                    target: self,
			                                                    action: #selector(KeyBindingEditorViewController.revert))
		}
	}

	override public func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)

		let keyBindingControl = KeyBindingInputControl(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
		keyBindingControl.newBindingAction =
			{
				keyCommand in

				let binding = KeyBinding(key: "", name: "",
				                         input: keyCommand.input!, modifiers: keyCommand.modifierFlags,
				                         isDiscoverable: false)

				self.editorView?.keyBindingDisplayLabel.keyBinding = binding
//				self.editorView?.keyBindingDisplayLabel.font = UIFont.systemFont(ofSize: 36.0)

				self.updatedBinding = self.binding.customized(input: binding.input, modifiers: binding.modifiers)
			}

		view.addSubview(keyBindingControl)

		keyBindingControl.becomeFirstResponder()
	}

	override public func viewDidDisappear(_ animated: Bool)
	{
		super.viewDidDisappear(animated)

		DispatchQueue.main.async
			{
				self.completion?(self.updatedBinding)
			}
	}

	public func setInstructions(_ text: String)
	{
		_instructionsLabel.text = text
	}

	public var instructionsLabel: UILabel
	{
		return _instructionsLabel
	}

	@objc func revert()
	{
		self.updatedBinding = nil

		dismiss(animated: true, completion: nil)
	}

	@objc func cancel()
	{
		self.updatedBinding = self.binding

		dismiss(animated: true, completion: nil)
	}
}

extension KeyBindingEditorViewController: UITextFieldDelegate
{
	public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
	{
		return false
	}
}

class KeyBindingInputControl: UIControl
{
	private var _keyCommands: [UIKeyCommand]!

	var newBindingAction: ((UIKeyCommand) -> Void)? = nil

	override init(frame: CGRect)
	{
		super.init(frame: frame)

		makeKeyCommands()
	}

	required init?(coder aDecoder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}

	private func makeKeyCommands()
	{
		let special = UIKeyInputBackspace + UIKeyInputTab + UIKeyInputReturn + UIKeyInputDelete
		let characters = "\(special)abcdefghijklmnopqrstuvwxyz!\"#$%&'()*+,-./0123456789:;<=>º?@[\\]^_`´{|}~"

		var keyCommands = [UIKeyCommand]()

		var inputs = characters.map({ String($0) })

		inputs.append(contentsOf: [UIKeyInputLeftArrow, UIKeyInputRightArrow, UIKeyInputUpArrow, UIKeyInputDownArrow, UIKeyInputEscape])

		let action = #selector(KeyBindingInputControl.commandAction(_:))

		for input in inputs
		{
			keyCommands.append(UIKeyCommand(input: input, modifierFlags: [.command], action: action))
			keyCommands.append(UIKeyCommand(input: input, modifierFlags: [.shift], action: action))
			keyCommands.append(UIKeyCommand(input: input, modifierFlags: [.control], action: action))
			keyCommands.append(UIKeyCommand(input: input, modifierFlags: [.alternate], action: action))

			keyCommands.append(UIKeyCommand(input: input, modifierFlags: [.command, .control], action: action))
			keyCommands.append(UIKeyCommand(input: input, modifierFlags: [.command, .shift], action: action))
			keyCommands.append(UIKeyCommand(input: input, modifierFlags: [.command, .alternate], action: action))

			keyCommands.append(UIKeyCommand(input: input, modifierFlags: [.shift, .control], action: action))
			keyCommands.append(UIKeyCommand(input: input, modifierFlags: [.shift, .alternate], action: action))

			keyCommands.append(UIKeyCommand(input: input, modifierFlags: [.control, .alternate], action: action))
		}

		self._keyCommands = keyCommands
	}

	override var canBecomeFirstResponder: Bool
	{
		return true
	}

	override var keyCommands: [UIKeyCommand]?
	{
		return _keyCommands
	}

	@objc func commandAction(_ sender: Any?)
	{
		if let keyCommand = sender as? UIKeyCommand
		{
			if KeyBindingsRegistry.default.forbiddenKeyCommands.contains(keyCommand)
			{
				NSLog("NOPE")
				return
			}

			newBindingAction?(keyCommand)
		}
	}
}

class KeyBindingEditorView: UIView
{
	var viewController: KeyBindingEditorViewController? = nil

	@IBOutlet var keyBindingDisplayLabel: KeyBindingLabel!

	@IBAction func save(sender: Any?)
	{
		 viewController?.dismiss(animated: true, completion: nil)
	}
}
