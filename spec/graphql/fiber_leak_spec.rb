require 'rails_helper'

module AllocationTracing
  def initialize(*args, **kwargs, &block)
    super
    @allocation_backtrace = caller
  end

  def allocation_backtrace
    @allocation_backtrace
  end
end

ActiveRecord::Relation.prepend(AllocationTracing)
Fiber.prepend(AllocationTracing)

def print_allocations(klass = nil)
  counts = Hash.new(0)
  ObjectSpace.each_object(klass || Object) { |obj| counts[obj.class] += 1 }
  puts counts.sort_by { |_k, v| -v }.first(30).inspect
end

def aggressive_gc!
  # Run full GC cycles until no more objects are freed
  loop do
    before = GC.stat(:total_freed_objects)
    GC.start(full_mark: true, immediate_sweep: true, immediate_mark: true)
    break if GC.stat(:total_freed_objects) == before
  end
  GC.compact
end

def print_fiber_allocations
  ObjectSpace.each_object(Class) do |klass|
    # Check if it's a subclass of ActiveRecord::Relation
    next unless klass == Fiber

    # Iterate over all instances of that class
    ObjectSpace.each_object(klass) do |obj|
      next if obj.alive?
      puts "--"
      puts "#{klass} (now dead) was allocated at #{obj.allocation_backtrace.join("\n")}" if obj.allocation_backtrace
      
    end
  end
end
ObjectSpace.trace_object_allocations_start


RSpec.describe Resolvers::Appointments do
  include_context 'with_organization'
  include_context 'with_appointments'

  before(:suite) do
    ObjectSpace.trace_object_allocations_start
  end
  
  describe 'Querying appointments' do
    let(:query) do
      # Fetch a bunch of dataloaded fields and watch dead fibers grow
      <<~GQL
      query Appointments {
        appointments {
          edges {
            node {
              id
              startTime
              endTime

              owner {
                id
                name
                organization {
                  id
                  name
                }
              }
  
              appointmentGuests {
                id
                user {
                  id
                  name
                }
              }
            }
          }
        }
      }
      GQL
    end

    describe 'increases dead fiber count consistently without cleanup even on forced GC' do

      subject do
        ExampleappSchema.execute(
          query,
          variables: {},
          context: {
            current_user: Pundit::User.new(family.users.first),
            pundit_user: Pundit::User.new(family.users.first),
          }
        ).to_h.dig('data', 'appointments', 'edges').map { _1.dig('node') }
        
        # Force garbage collection to see if fibers are cleaned up
        aggressive_gc!
        fiber_count = ObjectSpace.each_object(Fiber).count
        alive_count = ObjectSpace.each_object(Fiber).count { it.alive? }
        dead_count = ObjectSpace.each_object(Fiber).count { !it.alive? }
        puts "Memory used: #{ObjectSpace.memsize_of_all}"
        # print_fiber_allocations
        # print_allocations 
        { alive: alive_count, dead: dead_count, total: fiber_count }
      end

      
      # I presume that once the controller is finished with the request,
      # and fibers are no longer needed, they should be cleaned up on
      # a forced GC and we should see at most 1 alive fiber (main thread)
      # and no dead fibers.
      # 
      # What we actually see here is 20 dead fibers and 1 alive
      it { is_expected.to eq({ alive: 1, total: 21, dead: 20 }) }

      # Fire another request and watch it grow
      it { is_expected.to eq({ alive: 1, total: 41, dead: 40 }) }

      1000.times.each_with_index do |idx|
        next if idx.zero?
        it { is_expected.to eq({ alive: 1, total: 41 + idx * 20, dead: 40 + idx * 20 }) }
      end
    end
  end
end