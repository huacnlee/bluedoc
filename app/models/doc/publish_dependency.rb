# frozen_string_literal: true

class Doc
  attr_accessor :_publishing

  def publishing!
    self._publishing = true
  end

  def publishing?
    self._publishing == true
  end
end
