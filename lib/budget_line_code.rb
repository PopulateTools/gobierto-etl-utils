# frozen_string_literal: true

# Normalizes the budget line codes of the official budget files (XML of the Ministry of Finance
# and XBRL dictionaries) to the codes used in Gobierto.
#
# Subconcepts come as "22000", "220-00" (XBRL dictionaries) or "220_00" (XML node names). All of
# them become "220-00", level 4 and parent "220". Codes with more than 5 digits are not supported.
#
#   BudgetLineCode.parse("1")      # => code "1", level 1, parent_code ""
#   BudgetLineCode.parse("1521")   # => code "1521", level 4, parent_code "152" (functional program)
#   BudgetLineCode.parse("220_00") # => code "220-00", level 4, parent_code "220"
#   BudgetLineCode.parse("227000") # => nil
class BudgetLineCode
  SEPARATORS = /[-_]/
  SUBCONCEPT_DIGITS = 5

  attr_reader :code, :level, :parent_code

  private_class_method :new

  def self.parse(raw_code)
    digits = raw_code.to_s.strip.gsub(SEPARATORS, "")
    return if digits.empty? || digits.length > SUBCONCEPT_DIGITS

    new(digits)
  end

  def initialize(digits)
    if digits.length == SUBCONCEPT_DIGITS
      @parent_code = digits[0...3]
      @code = "#{@parent_code}-#{digits[3..]}"
      @level = 4
    else
      @code = digits
      @level = digits.length
      @parent_code = digits[0..-2]
    end
  end
end
