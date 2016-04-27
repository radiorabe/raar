class Parallelizer

  attr_accessor :thread_count

  def initialize(payloads)
    @queue = init_queue(payloads)
    @thread_count = default_thread_count
  end

  # rubocop:disable Lint/AssignmentInCondition
  def run(&block)
    workers = (0..thread_count).map do
      Thread.new do
        process_payloads(&block)
      end
    end
    workers.each(&:join)
  end

  private

  def init_queue(payloads)
    Queue.new.tap do |q|
      payloads.each { |p| q.push(p) }
    end
  end

  def process_payloads
    ActiveRecord::Base.connection_pool.with_connection do
      while payload = next_payload
        yield payload
      end
    end
  end

  def next_payload
    @queue.pop(true)
  rescue ThreadError # raised if called on an empty queue
    nil
  end

  def default_thread_count
    Rails.application.secrets.parallel_transcodings.to_i || 1
  end

end
