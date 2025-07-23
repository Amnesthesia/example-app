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
GraphQL::Query::Context.prepend(AllocationTracing)


# A debugging module for tracking and analyzing Fiber objects in Ruby applications.
# Provides utilities for counting live/dead fibers, performing aggressive garbage collection,
# and analyzing object allocations with a focus on GraphQL and ActiveRecord components.
class FiberDebugging
  class << self
    # Returns the count of currently alive Fiber objects in the ObjectSpace.
    #
    # @return [Integer] the number of alive fibers
    def alive_count
      ObjectSpace.each_object(Fiber).count { it.alive? }
    end

    # Returns the count of dead Fiber objects in the ObjectSpace.
    #
    # @return [Integer] the number of dead fibers
    def dead_count
      ObjectSpace.each_object(Fiber).count { !it.alive? }
    end

    # Returns the total count of all Fiber objects in the ObjectSpace.
    #
    # @return [Integer] the total number of fibers (alive + dead)
    def total_count
      ObjectSpace.each_object(Fiber).count
    end

    # Executes a block with aggressive garbage collection disabled, then performs
    # multiple full GC cycles until no more objects can be freed, followed by compaction.
    #
    # @yield [block] the block to execute during GC disabled state
    # @return [Object] the result of the yielded block
    def with_aggressive_gc(&block)
      result = nil
      GC.disable
      result = yield

      # Aggressive GC
      size = GC.stat[:heap_live_slots]
      loop do
        GC.start(full_mark: true, immediate_sweep: true)
        new_size = GC.stat[:heap_live_slots]
        break if new_size >= size
        size = new_size
      end

      GC.compact
      result
    end

    # Prints the top 30 most allocated object classes and their counts.
    #
    # @param klass [Class, nil] optional class to filter objects by, defaults to Object
    # @return [void]
    def print_allocations(klass = nil)
      klass ||= Object
      puts "# Allocations for #{klass}:"
      ObjectSpace.each_object(klass)
        .group_by(&:class)
        .transform_values(&:count)
        .sort_by { |k, v| -v }
        .first(30)
        .each { |k, v| puts "#{v}: #{k}" }
    end
  end
end

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

    # NOTE: These specs are all "reversed" as in, they test that it behaves
    # incorrectly — these tests should ALL fail
    describe 'with forced garbage collection' do

      subject do
        FiberDebugging.with_aggressive_gc do
          gql = ExampleappSchema.execute(
            query,
            variables: {},
            context: {
              current_user: Pundit::User.new(family.users.first),
              pundit_user: Pundit::User.new(family.users.first),
            }
          )
          # Try to force dataloader cleanup (this doesnt make a difference)
          gql.context.dataloader.clear_cache
          gql.context.dataloader.cleanup_fiber
        end
          
        # print_allocations 
        { alive: FiberDebugging.alive_count, dead: FiberDebugging.dead_count, total: FiberDebugging.total_count }
      end

      
      describe 'keeps dangling query and multiplex objects in ObjectSpace' do
        # We expect all GraphQL::Execution::Multiplex and GraphQL::Query objects to be cleaned up
        # after the request is done, and all fibers to be dead, but they are still referenced somewhere,
        # and they hold a context, which holds a dataloader, which I believe holds fiber references
        it 'still has multiplex and query objects dangling' do
          subject
          expect(ObjectSpace.each_object(GraphQL::Execution::Multiplex).count).to eq(1)
          expect(ObjectSpace.each_object(GraphQL::Query).count).to eq(1)
        end
      end


      describe 'doesnt clean up dead fibers' do
        # I presume that once the controller is finished with the request,
        # and fibers are no longer needed, they should be cleaned up on
        # a forced GC and we should see at most 1 alive fiber (main thread)
        # and no dead fibers.
        # 
        # What we actually see here is 20 dead fibers and 1 alive

        # Fire another request and watch it grow

        100.times.each_with_index do |idx|
          next if idx < 2
          it { is_expected.to eq({ alive: 1, total: 1 + (idx * 20), dead: (idx * 20) }) }
        end
      end
    end
  end
end