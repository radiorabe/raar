module Downgrade
  class Runner

    def run
      Downgrader.run
      Ereaser.run
    end

  end
end
