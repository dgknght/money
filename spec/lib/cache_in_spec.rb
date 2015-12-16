require 'spec_helper'

describe CacheIn do
  it 'adds a memoize method to any object' do
    class MyObject
    end
    expect(MyObject).to respond_to(:memoize)
  end

  describe '::memoize' do
    it 'causes the result of the method to be cached for later calls' do
      class MyObject
        attr_reader :execution_count

        def life_universe_everything
          @execution_count = (@execution_count || 0) + 1
          42
        end

        memoize :life_universe_everything
      end

      obj = MyObject.new
      expect(obj.life_universe_everything).to eq(42)
      expect(obj.execution_count).to eq(1)

      expect do
        obj.life_universe_everything
      end.not_to change(obj, :execution_count)
    end
  end
end
