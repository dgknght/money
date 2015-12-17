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

    it 'can be applied to multiple methods' do
      class MyObject
        def execution_counts
          @execution_counts ||= Hash.new{|h, k| h[k] = 0}
        end

        def method_1
          execution_counts[:method_1] += 1
          44
        end


        def method_2
          execution_counts[:method_2] += 1
          'XLIV'
        end

        memoize [:method_1, :method_2]
      end

      obj = MyObject.new
      expect(obj.method_1).to eq(44)
      expect(obj.method_2).to eq('XLIV')

      obj.method_1
      obj.method_2

      expect(obj.execution_counts[:method_1]).to eq(1)
      expect(obj.execution_counts[:method_2]).to eq(1)
    end

    it 'calls the original method again after the ttl has expired' do
      class MyObject
        attr_reader :execution_count

        def life_universe_everything
          @execution_count = (@execution_count || 0) + 1
          42
        end
        memoize :life_universe_everything, ttl: 2.minutes
      end

      obj = MyObject.new
      expect(obj.life_universe_everything).to eq(42)
      expect(obj.execution_count).to eq(1)
      expect do
        obj.life_universe_everything
      end.not_to change(obj, :execution_count)
      Timecop.travel(DateTime.now + 2.minutes)
      expect do
        obj.life_universe_everything
      end.to change(obj, :execution_count).by(1)
    end
  end
end
