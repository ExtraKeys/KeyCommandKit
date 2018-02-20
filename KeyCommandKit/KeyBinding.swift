//
//  KeyBinding.swift
//  KeyCommandKit
//
//  Created by Bruno Philipe on 30/6/17.
//

import Foundation

let UnassignedKeyBindingInput = "Unassigned"

public class KeyBinding
{
	/// An internal identifier. Must be unique, and is used to query key bindings. It is never shown to the user.
	public let key: String

	/// A user-friendly description. It is shown in the system discoverability UI if the `isDiscoverable` property is true.
	public let name: String

	/// Whether this binding should be shown in the system discoverability UI.
	public let isDiscoverable: Bool

	/// The default input for this binding. Can be customized by the user, but the default will always be stored.
	public let input: String

	/// The default modifiers for this binding. Can be customized by the user, but the default will always be stored.
	public let modifiers: UIKeyModifierFlags

	/// Flag that indicates wether this binding was customized by the user.
	public var isCustomized: Bool
	{
		return false
	}

	/// Whether this is a customization where the user unassigned the key binding, effectively deactivating it.
	var isUnassigned: Bool
	{
		return input == UnassignedKeyBindingInput
	}

	/// Makes a UIKeyCommand instance by attaching an action to the receiver binding. If the receiver binding was
	/// customized to "Unassigned" by the user, this method returns `nil`.
	public func make(withAction action: Selector) -> UIKeyCommand?
	{
		if isUnassigned
		{
			return nil
		}

		if isDiscoverable, #available(iOS 9.0, *)
		{
			return UIKeyCommand(input: input, modifierFlags: modifiers, action: action, discoverabilityTitle: name)
		}
		else
		{
			return UIKeyCommand(input: input, modifierFlags: modifiers, action: action)
		}
	}

	public init(key: String, name: String, input: String, modifiers: UIKeyModifierFlags, isDiscoverable: Bool)
	{
		self.key = key
		self.name = name
		self.input = input
		self.modifiers = modifiers
		self.isDiscoverable = isDiscoverable
	}
}

internal class CustomizedKeyBinding: KeyBinding
{
	/// Flag that indicates wether this binding was customized by the user.
	override public var isCustomized: Bool
	{
		return true
	}

	var originalInput: String
	var originalModifiers: UIKeyModifierFlags

	init(key: String, name: String, input: String, modifiers: UIKeyModifierFlags, isDiscoverable: Bool, originalInput: String, originalModifiers: UIKeyModifierFlags)
	{
		self.originalInput = originalInput
		self.originalModifiers = originalModifiers

		super.init(key: key, name: name, input: input, modifiers: modifiers, isDiscoverable: isDiscoverable)
	}
}

internal extension KeyBinding
{
	func isEquivalent(toKeyBinding keyBinding: KeyBinding) -> Bool
	{
		return keyBinding.input == self.input && keyBinding.modifiers == self.modifiers
	}

	var stringRepresentation: String
	{
		var string = ""

		if modifiers.contains(.control)
		{
			string += "⌃"
		}

		if modifiers.contains(.alternate)
		{
			string += "⌥"
		}

		if modifiers.contains(.shift)
		{
			string += "⇧"
		}

		if modifiers.contains(.command)
		{
			string += "⌘"
		}

		switch input
		{
		case UIKeyInputLeftArrow:
			string += "←"

		case UIKeyInputRightArrow:
			string += "→"

		case UIKeyInputUpArrow:
			string += "↑"

		case UIKeyInputDownArrow:
			string += "↓"

		case UIKeyInputEscape:
			string += "⎋"

		case UIKeyInputBackspace:
			string += "⌫"

		case UIKeyInputTab:
			string += "⇥"

		case UIKeyInputReturn:
			string += "↩︎"

		default:
			string += input.uppercased()
		}

		return string
	}

	func customized(input: String, modifiers: UIKeyModifierFlags) -> KeyBinding
	{
		return CustomizedKeyBinding(key: key, name: name, input: input, modifiers: modifiers,
									isDiscoverable: isDiscoverable, originalInput: self.input,
									originalModifiers: self.modifiers)
	}
}

public extension Dictionary where Key == String, Value == KeyBinding
{
	/// Makes UIKeyCommand objects by attaching key bindings to actions by matching their respective `key`s.
	/// If a key binding was customized to "Unassigned" by the user, then this routine skips it.
	public func make(withActionsForKeys tuples: [(key: String, action: Selector)]) -> [UIKeyCommand]
	{
		var keyCommands = [UIKeyCommand]()

		for (key, action) in tuples
		{
			if let binding = self[key], let keyCommand = binding.make(withAction: action)
			{
				keyCommands.append(keyCommand)
			}
		}

		return keyCommands
	}
}
