module ExperimentalFlag
  def mark_as_experimental
    @experimental = true
  end

  def experimental?
    !!@experimental
  end
end
