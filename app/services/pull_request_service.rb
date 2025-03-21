# frozen_string_literal: true

module Services
  class PullRequestService
    ADAPTER_MAPPING = {
      'AzureDevOps' => Adapters::AzureDevOpsAdapter
    }.freeze

    def initialize(platform)
      adapter = ADAPTER_MAPPING.fetch(platform)

      raise ArgumentError, "Unsupported platform: #{platform}." if adapter.nil?

      @strategy = adapter.new
    end

    def get_pull_requests(filters)
      @strategy.get_pull_requests(filters)
    end

    def get_metrics(filters)
      @strategy.get_metrics(filters)
    end
  end
end
