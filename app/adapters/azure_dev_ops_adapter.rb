# frozen_string_literal: true

module Adapters
  class AzureDevOpsAdapter
    include Ports::PullRequestPort

    def get_pull_requests(filters)
      @filters = build_search_filters(filters)
      pull_requests = fetch_pull_requests
      process_pull_requests(pull_requests)
    end

    private

    def build_search_filters(filters)
      {
        "searchCriteria.status": filters[:status],
        "searchCriteria.minTime": filters[:minTime],
        "searchCriteria.maxTime": filters[:maxTime],
        "searchCriteria.queryTimeRangeType": filters[:rangeType]
      }
    end

    def azure_connection
      Faraday.new(
        url: "https://dev.azure.com/#{ENV['AZURE_ORG']}/#{ENV['AZURE_PROJECT']}/_apis/git",
        params: { "api-version": '7.1' },
        headers: {
          'Authorization' => "Bearer #{ENV['AZURE_PAT']}",
          'Content-Type' => 'application/json'
        }
      )
    end

    def fetch_pull_requests
      response = azure_connection.get('pullrequests', @filters)
      JSON.parse(response.body)['value']
    end

    def process_pull_requests(pull_requests)
      pull_requests.map do |pr|
        process_single_pull_request(pr)
      end
    end

    # TODO: Use serializers to format the response
    # rubocop:disable Metrics/MethodLength
    def process_single_pull_request(pr)
      threads_data = fetch_threads_data(pr)

      {
        firstApprovedDate: find_first_approved_date(threads_data),
        firstTextCommentDate: find_first_text_comment_date(threads_data),
        createdDate: pr['creationDate'],
        closedDate: pr['closedDate'],
        id: pr['pullRequestId'],
        title: pr['title'],
        repository: {
          id: pr.dig('repository', 'id'),
          name: pr.dig('repository', 'name')
        },
        createdBy: {
          id: pr.dig('createdBy', 'id'),
          uniqueName: pr.dig('createdBy', 'uniqueName')
        }
      }
    end
    # rubocop:enable Metrics/MethodLength

    def fetch_threads_data(pull_request)
      repository_id = pull_request.dig('repository', 'id')
      response = azure_connection.get(
        "repositories/#{repository_id}/pullRequests/#{pull_request['pullRequestId']}/threads"
      )

      JSON.parse(response.body)['value']
    end

    def find_first_approved_date(threads_data)
      approved_thread = threads_data.find do |thread|
        thread['isDeleted'] == false &&
          thread.dig('properties', 'CodeReviewVoteResult', '$value') == '10'
      end

      approved_thread&.[]('publishedDate')
    end

    def find_first_text_comment_date(threads_data)
      valid_thread = threads_data.find { |t| valid_thread?(t) }
      return unless valid_thread

      first_text_comment = valid_thread['comments']&.find { |c| text_comment?(c) }
      first_text_comment&.dig('publishedDate')
    end

    def valid_thread?(thread)
      thread['isDeleted'] == false && text_comments?(thread)
    end

    def text_comments?(thread)
      thread['comments']&.any? { |c| text_comment?(c) }
    end

    def text_comment?(comment)
      comment['commentType'] == 'text'
    end
  end
end
