module Measurable
  extend ActiveSupport::Concern

  included do
    # create a hash with the different metrics categories
    # total is sum of all categories if no total value is provided
    # make sure all values are integers or nil
    def get_metrics(options = {})
      options = Hash[options.map { |key, value| [key.to_sym, value.to_i] }]
      options[:total] ||= options.values.sum

      { :pdf => options.fetch(:pdf, nil),
        :html => options.fetch(:html, nil),
        :readers => options.fetch(:readers, nil),
        :comments => options.fetch(:comments, nil),
        :likes => options.fetch(:likes, nil),
        :total => options.fetch(:total, 0) }
    end

    def get_sum(items, key, nested_key = nil)
      items.empty? ? 0 : items.reduce(0) do |sum, hsh|
        value = hsh[key]
        value = value[nested_key] if nested_key
        sum + value.to_i
      end
    end

    def relation_types_for_recommendations
      cached_relation_type_names.reduce([]) do |sum, rt|
        if %w(is_cited_by is_bookmarked_by is_referenced_by).include?(rt.last)
          sum << rt.first
        else
          sum
        end
      end
    end

    def get_iso8601_from_time(time)
      return nil if time.blank?

      Time.zone.parse(time.to_s).utc.iso8601
    end

    def get_iso8601_from_epoch(epoch)
      return nil if epoch.blank?

      # handle milliseconds
      epoch = epoch.to_i
      epoch = epoch / 1000 if epoch > 9999999999
      Time.at(epoch).utc.iso8601
    end
  end
end
