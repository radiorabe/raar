# frozen_string_literal: true

class Parallelizer

  attr_accessor :thread_count

  def initialize(payloads)
    @queue = init_queue(payloads)
    @thread_count = default_thread_count
  end

  def run(&block)
    if thread_count <= 1
      process_payloads(&block)
    else
      run_parallel(&block)
    end
  end

  private

  def run_parallel(&block)
    workers = Array.new(thread_count) do
      Thread.new { process_payloads(&block) }
    end
    workers.each(&:join)
  end

  def init_queue(payloads)
    Queue.new.tap do |q|
      payloads.each { |p| q.push(p) }
    end
  end

  def process_payloads
    ActiveRecord::Base.connection_pool.with_connection do
      while payload = next_payload # rubocop:disable Lint/AssignmentInCondition
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
    Rails.application.settings.parallel_transcodings.to_i
  end

end
