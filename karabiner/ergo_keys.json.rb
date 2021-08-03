#!/usr/bin/env ruby

require 'json'
require_relative './karabiner.rb'

PARAMETERS = {
  :simultaneous_threshold_milliseconds => 300,
}.freeze

# lookup a dvorak keycode in it's qwerty representation
KEYMAP = {
  :o => "s",
  :e => "d",
  :u => "f",

  :h => "j",
  :t => "k",
  :n => "l",
  :s => "semicolon",

  :open_bracket => "hyphen",
  :close_bracket => "equal_sign",
}

def main
  puts JSON.pretty_generate(
    "title" => "Ergo Keys",
    "rules" => [
      "description" => "Ergo Keys",
      "manipulators" => rules("spacebar"),
    ]
  )
end

def rules(trigger_key)
  variable = "ergo_keys_#{trigger_key}"
  [
    two_part_trigger_combo(trigger_key, variable, :o, :open_bracket, []),
    two_part_trigger_combo(trigger_key, variable, :e, :open_bracket, ["left_shift"]),
    two_part_trigger_combo(trigger_key, variable, :u, "9", ["left_shift"]),

    two_part_trigger_combo(trigger_key, variable, :n, :close_bracket, []),
    two_part_trigger_combo(trigger_key, variable, :t, :close_bracket, ["left_shift"]),
    two_part_trigger_combo(trigger_key, variable, :h, "0", ["left_shift"]),
  ].flatten
end

def two_part_trigger_combo(trigger_key, variable, from_key_code, to_key_code, to_modifiers)
  if KEYMAP.member?(from_key_code)
    from_key_code = KEYMAP[from_key_code]
  end
  if KEYMAP.member?(to_key_code)
    to_key_code = KEYMAP[to_key_code]
  end
  [
    {
      "type" => "basic",
      "from" => {
        "key_code" => from_key_code,
        "modifiers" => { "optional" => ["any"] },
      },
      "to" => [
        {
          "key_code" => to_key_code,
          "modifiers" => to_modifiers
        },
      ],
      "conditions" => [
        Karabiner.variable_if(variable, 1),
      ]
    },

    {
      "type" => "basic",
      "from" => {
        "simultaneous" => [
          { "key_code" => trigger_key },
          { "key_code" => from_key_code },
        ],
        "simultaneous_options" => {
          "key_down_order" => "strict",
          "key_up_order" => "strict_inverse",
          "detect_key_down_uninterruptedly" => true,
          "to_after_key_up" => [
            Karabiner.set_variable(variable, 0),
          ],
        },
        "modifiers" => { "optional" => ["any"] },
      },
      "to" => [
        Karabiner.set_variable(variable, 1),
        Karabiner.set_variable("DEBUG simultaneous", 1),
        {
          "key_code" => to_key_code,
          "modifiers" => to_modifiers
        }
      ],
      "parameters" => {
        "basic.simultaneous_threshold_milliseconds" => PARAMETERS[:simultaneous_threshold_milliseconds],
      }
    }
  ]
end

main
