# Partially taken from: https://github.com/pqrs-org/KE-complex_modifications/blob/master/src/lib/karabiner.rb

module Karabiner
  def self.set_variable(name, value)
    {
      'set_variable' => {
        'name' => name,
        'value' => value,
      },
    }
  end

  def self.variable_if(name, value)
    {
      'type' => 'variable_if',
      'name' => name,
      'value' => value,
    }
  end
end
