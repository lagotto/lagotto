module ReferenceKeyMapBehavior
  def test_uses_the_proper_references
    assert_equal reference_class, map_class.reference_class
  end
  
  def test_keeps_entries_with_strong_references
    Ref::Mock.use do
      hash = map_class.new
      key_1 = Object.new
      key_2 = Object.new
      hash[key_1] = "value 1"
      hash[key_2] = "value 2"
      assert_equal "value 1", hash[key_1]
      assert_equal "value 2", hash[key_2]
    end
  end

  def test_removes_entries_that_have_been_garbage_collected
    Ref::Mock.use do
      hash = map_class.new
      key_1 = Object.new
      key_2 = Object.new
      hash[key_1] = "value 1"
      hash[key_2] = "value 2"
      assert_equal "value 1", hash[key_1]
      assert_equal "value 2", hash[key_2]
      Ref::Mock.gc(key_2)
      assert_equal "value 1", hash[key_1]
      assert_nil hash[key_2]
    end
  end

  def test_can_clear_the_map
    Ref::Mock.use do
      hash = map_class.new
      value_1 = "value 1"
      value_2 = "value 2"
      key_1 = Object.new
      key_2 = Object.new
      hash[key_1] = value_1
      hash[key_2] = value_2
      hash.clear
      assert_nil hash[key_1]
      assert_nil hash[key_2]
    end
  end

  def test_can_delete_entries
    Ref::Mock.use do
      hash = map_class.new
      value_1 = "value 1"
      value_2 = "value 2"
      key_1 = Object.new
      key_2 = Object.new
      hash[key_1] = value_1
      hash[key_2] = value_2
      Ref::Mock.gc(key_2)
      assert_nil hash.delete(key_2)
      assert_equal value_1, hash.delete(key_1)
      assert_nil hash[key_1]
    end
  end

  def test_can_merge_in_another_hash
    Ref::Mock.use do
      hash = map_class.new
      value_1 = "value 1"
      value_2 = "value 2"
      value_3 = "value 3"
      key_1 = Object.new
      key_2 = Object.new
      key_3 = Object.new
      hash[key_1] = value_1
      hash[key_2] = value_2
      hash.merge!(key_3 => value_3)
      assert_equal "value 2", hash[key_2]
      assert_equal value_1, hash[key_1]
      Ref::Mock.gc(key_2)
      assert_nil hash[key_2]
      assert_equal value_1, hash[key_1]
      assert_equal value_3, hash[key_3]
    end
  end

  def test_can_get_all_keys
    Ref::Mock.use do
      hash = map_class.new
      value_1 = "value 1"
      value_2 = "value 2"
      value_3 = "value 3"
      key_1 = Object.new
      key_2 = Object.new
      key_3 = Object.new
      hash[key_1] = value_1
      hash[key_2] = value_2
      hash[key_3] = value_3
      assert_equal [], [key_1, key_2, key_3] - hash.keys
      Ref::Mock.gc(key_2)
      assert_equal [key_2], [key_1, key_2, key_3] - hash.keys
    end
  end

  def test_can_turn_into_an_array
    Ref::Mock.use do
      hash = map_class.new
      value_1 = "value 1"
      value_2 = "value 2"
      value_3 = "value 3"
      key_1 = Object.new
      key_2 = Object.new
      key_3 = Object.new
      hash[key_1] = value_1
      hash[key_2] = value_2
      hash[key_3] = value_3
      order = lambda{|a,b| a.last <=> b.last}
      assert_equal [[key_1, "value 1"], [key_2, "value 2"], [key_3, "value 3"]].sort(&order), hash.to_a.sort(&order)
      Ref::Mock.gc(key_2)
      assert_equal [[key_1, "value 1"], [key_3, "value 3"]].sort(&order), hash.to_a.sort(&order)
    end
  end

  def test_can_iterate_over_all_entries
    Ref::Mock.use do
      hash = map_class.new
      value_1 = "value 1"
      value_2 = "value 2"
      value_3 = "value 3"
      key_1 = Object.new
      key_2 = Object.new
      key_3 = Object.new
      hash[key_1] = value_1
      hash[key_2] = value_2
      hash[key_3] = value_3
      keys = []
      values = []
      hash.each{|k,v| keys << k; values << v}
      assert_equal [], [key_1, key_2, key_3] - keys
      assert_equal ["value 1", "value 2", "value 3"], values.sort
      Ref::Mock.gc(key_2)
      keys = []
      values = []
      hash.each{|k,v| keys << k; values << v}
      assert_equal [key_2], [key_1, key_2, key_3] - keys
      assert_equal ["value 1", "value 3"], values.sort
    end
  end

  def test_inspect
    Ref::Mock.use do
      hash = map_class.new
      hash[Object.new] = "value 1"
      assert hash.inspect
    end
  end
end
