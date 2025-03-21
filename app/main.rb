# frozen_string_literal: true

require 'sinatra/base'

class Main < Sinatra::Base
  get '/' do
    'Hello World'
  end

  get '/pull_requests' do
    # TODO: Remove collect the platform from environment when user_service microservice is ready
    platform = ENV['USER_PLATFORM']

    pull_request_service = Services::PullRequestService.new(platform)
    prs = pull_request_service.get_pull_requests(params)

    content_type :json
    { pullRequests: prs }.to_json
  rescue StandardError => e
    status 502
    { error: "Azure DevOps connection error: #{e.message}" }.to_json
  end

  get '/pull_requests/metrics' do
    platform = ENV['USER_PLATFORM']

    pull_request_service = Services::PullRequestService.new(platform)

    metrics = pull_request_service.get_metrics(params)

    content_type :json
    { metrics: metrics }.to_json
  end
end
