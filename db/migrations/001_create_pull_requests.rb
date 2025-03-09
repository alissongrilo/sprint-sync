# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:pull_requests) do
      primary_key :id
      String :title, null: false
      String :repository_id, null: false
      String :created_by_id, null: false

      DateTime :created_at, null: false
      DateTime :first_iteration_at
      DateTime :first_approved_at
      DateTime :closed_at
    end
  end
end
