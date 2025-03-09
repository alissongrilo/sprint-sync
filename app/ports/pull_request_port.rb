# frozen_string_literal: true

module Ports
  module PullRequestPort
    def get_pull_requests(filters)
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end
  end
end
