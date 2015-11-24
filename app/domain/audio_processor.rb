# Interface for audio processors.
module AudioProcessor
  mattr_accessor :klass

  def self.new(file)
    klass.new(file)
  end
end
