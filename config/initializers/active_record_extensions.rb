# This assumes you are in Rails 4 and you can pluck multiple columns
# from https://gist.github.com/siannopollo/03d646eb7525f7fce678#file-pluck_in_batches-rb

class ActiveRecord::Relation
  # pluck_in_batches:  yields an array of *columns that is at least size
  #                    batch_size to a block.
  #
  #                    Special case: if there is only one column selected than each batch
  #                                  will yield an array of columns like [:column, :column, ...]
  #                                  rather than [[:column], [:column], ...]
  # Arguments
  #   columns      ->  an arbitrary selection of columns found on the table.
  #   batch_size   ->  How many items to pluck at a time
  #   &block       ->  A block that processes an array of returned columns.
  #                    Array is, at most, size batch_size
  #
  # Returns
  #   nothing is returned from the function
  def pluck_in_batches(*columns, batch_size: 1000)
    if columns.empty?
      raise "There must be at least one column to pluck"
    end

    # the :id to start the query at
    batch_start = 1

    # It's cool. We're only taking in symbols
    # no deep clone needed
    select_columns = columns.dup

    # Find index of :id in the array
    remove_id_from_results = false
    id_index = columns.index(primary_key.to_sym)

    # :id is still needed to calculate offsets
    # add it to the front of the array and remove it when yielding
    if id_index.nil?
      id_index = 0
      select_columns.unshift(primary_key)

      remove_id_from_results = true
    end

    loop do
      items = self.where(table[primary_key].gteq(batch_start))
                  .limit(batch_size)
                  .order(table[primary_key].asc)
                  .pluck(*select_columns)

      break if items.empty?

      # Use the last id to calculate where to offset queries
      last_item = items.last
      last_id = last_item.is_a?(Array) ? last_item[id_index] : last_item

      # Remove :id column if not in *columns
      items.map! { |row| row[1..-1] } if remove_id_from_results

      yield items

      break if items.size < batch_size

      batch_start = last_id + 1
    end
  end
end
