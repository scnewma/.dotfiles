import "list"

global: {
	check_for_updates_on_startup:  true
	show_in_menu_bar:              true
	show_profile_name_in_menu_bar: false
}
profiles: [
	for p in _profiles {
		p
	},
]

#two_part_trigger_combo: {
	trigger_key:   string
	variable:      string
	from_key_code: string
	to_key_code:   string
	to_modifiers: [...string]

	let if_keydown = {
		type:  "variable_if"
		name:  variable
		value: 1
	}

	let set_keydown = {
		set_variable: {
			name:  variable
			value: 1
		}
	}

	let set_keyup = {
		set_variable: {
			name:  variable
			value: 0
		}
	}

	manipulators: [
		{
			type: "basic"
			from: {
				key_code: from_key_code
				modifiers: optional: ["any"]
			}
			to: [{
				key_code:  to_key_code
				modifiers: to_modifiers
			}]
			conditions: [if_keydown]
		},
		{
			type: "basic"
			from: {
				simultaneous: [
					{key_code: trigger_key},
					{key_code: from_key_code},
				]
				simultaneous_options: {
					key_down_order:                  "strict"
					key_up_order:                    "strict_inverse"
					detect_key_down_uninterruptedly: true
					to_after_key_up: [set_keyup]
				}
				modifiers: optional: ["any"]
			}
			to: [
				set_keydown,
				{
					set_variable: {
						name:  "DEBUG simultaneous"
						value: 1
					}
				},
				{
					key_code:  to_key_code
					modifiers: to_modifiers
				},
			]
			parameters: "basic.simultaneous_threshold_milliseconds": 500
		},
	]
}

#single_key: {
	type: "basic"
	from: {
		key_code: string
		modifiers: optional: ["any"]
	}
	to: {
		key_code: string
		...
	}
}

_profiles: [Name=string]: {
	name: Name

	selected: *false | true

	complex_modifications: {
		parameters: {
			"basic.simultaneous_threshold_milliseconds":    50
			"basic.to_delayed_action_delay_milliseconds":   300
			"basic.to_if_alone_timeout_milliseconds":       300
			"basic.to_if_held_down_threshold_milliseconds": 300
			"mouse_motion_to_scroll.speed":                 100
		}
		rules: [...{}]
	}

	// common
	devices: [{
		disable_built_in_keyboard_if_exists: false
		fn_function_keys: []
		identifiers: {
			is_keyboard:        true
			is_pointing_device: false
			product_id:         50475
			vendor_id:          1133
		}
		ignore:                   false
		manipulate_caps_lock_led: false
		simple_modifications: []
	}]
	fn_function_keys: [{
		from: key_code: "f1"
		to: [{
			consumer_key_code: "display_brightness_decrement"
		}]
	}, {
		from: key_code: "f2"
		to: [{
			consumer_key_code: "display_brightness_increment"
		}]
	}, {
		from: key_code: "f3"
		to: [{
			key_code: "mission_control"
		}]
	}, {
		from: key_code: "f4"
		to: [{
			key_code: "launchpad"
		}]
	}, {
		from: key_code: "f5"
		to: [{
			key_code: "illumination_decrement"
		}]
	}, {
		from: key_code: "f6"
		to: [{
			key_code: "illumination_increment"
		}]
	}, {
		from: key_code: "f7"
		to: [{
			consumer_key_code: "rewind"
		}]
	}, {
		from: key_code: "f8"
		to: [{
			consumer_key_code: "play_or_pause"
		}]
	}, {
		from: key_code: "f9"
		to: [{
			consumer_key_code: "fast_forward"
		}]
	}, {
		from: key_code: "f10"
		to: [{
			consumer_key_code: "mute"
		}]
	}, {
		from: key_code: "f11"
		to: [{
			consumer_key_code: "volume_decrement"
		}]
	}, {
		from: key_code: "f12"
		to: [{
			consumer_key_code: "volume_increment"
		}]
	}]
	parameters: delay_milliseconds_before_open_device: 1000
	simple_modifications: [...{}]
	virtual_hid_keyboard: {
		country_code:                        0
		indicate_sticky_modifier_keys_state: true
		mouse_key_xy_scale:                  100
	}
}

_profiles: "default": {
	complex_modifications: {
		rules: [
			{
				description: "change caps_lock to control; escape when alone"
				manipulators: [{
					from: key_code: "caps_lock"
					to: [{
						key_code: "left_control"
						lazy:     true
					}]
					to_if_alone: [{
						key_code: "escape"
					}]
					type: "basic"
				}]
			},
			{
				description: "shift + caps lock is caps lock"
				manipulators: [{
					from: {
						key_code: "caps_lock"
						modifiers: mandatory: ["left_shift"]
					}
					to: [{
						key_code: "caps_lock"
					}]
					type: "basic"
				}]
			},
			{
				#tptc: #two_part_trigger_combo & {
					trigger_key: "spacebar"
					variable:    "ergo_keys_\(trigger_key)"
				}

				description:  "Ergo Keys"
				manipulators: list.FlattenN([

					// left_command => left_shift
					#single_key & {
						from: key_code: "left_command"
						to: key_code:   "left_shift"
					},

					// right_command => right_shift
					#single_key & {
						from: key_code: "right_command"
						to: key_code:   "right_shift"
					},

					// left_option => left_command
					#single_key & {
						from: key_code: "left_option"
						to: key_code:   "left_command"
					},

					// right_option => right_command
					#single_key & {
						from: key_code: "right_option"
						to: key_code:   "right_command"
					},

					// left_shift => left_option
					#single_key & {
						from: key_code: "left_shift"
						to: key_code:   "left_option"
					},

					// right_shift => nop
					#single_key & {
						from: key_code: "right_shift"
						to: key_code:   "vk_none"
					},

					// left_control => hyper,
					#single_key & {
						from: key_code: "left_control"
						to: {
							key_code: "left_shift"
							modifiers: ["left_command", "left_control", "left_option"]
						}
					},

					// o => [
					(#tptc & {
						from_key_code: "s"
						to_key_code:   "hyphen"
					}).manipulators,

					// e => {
					(#tptc & {
						from_key_code: "d"
						to_key_code:   "hyphen"
						to_modifiers: ["left_shift"]
					}).manipulators,

					// u => (
					(#tptc & {
						from_key_code: "f"
						to_key_code:   "9"
						to_modifiers: ["left_shift"]
					}).manipulators,

					// n => ]
					(#tptc & {
						from_key_code: "l"
						to_key_code:   "equal_sign"
					}).manipulators,

					// t => }
					(#tptc & {
						from_key_code: "k"
						to_key_code:   "equal_sign"
						to_modifiers: ["left_shift"]
					}).manipulators,

					// h => )
					(#tptc & {
						from_key_code: "j"
						to_key_code:   "0"
						to_modifiers: ["left_shift"]
					}).manipulators,
				], -1)
			}]
	}
	selected: true
}

_profiles: "none": {
}

_profiles: "escape only": {
	simple_modifications: [{
		from: key_code: "caps_lock"
		to: [{
			key_code: "escape"
		}]
	}]
}
