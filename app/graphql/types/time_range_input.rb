module Types
  class TimeRangeInput < Types::Base::InputObject
    argument :start, GraphQL::Types::ISO8601DateTime, required: false,
              description: 'Timestamp (in milliseconds) for earliest search result',
              prepare: -> (timestamp, ctx) { timestamp&.to_datetime }
    argument :end, GraphQL::Types::ISO8601DateTime, required: false,
              description: 'Timestamp (in milliseconds) for latest search result',
              prepare: -> (timestamp, ctx) { timestamp&.to_datetime }

    def range
      to_h[:start]..to_h[:end]
    end

    def date_range
      to_h[:start].beginning_of_day..to_h[:end].end_of_day
    end
  end
end