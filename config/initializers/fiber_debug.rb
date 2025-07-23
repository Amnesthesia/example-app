# config/initializers/fiber_debug.rb

module FiberDebug
  def self.setup
    patch_fiber_new
    patch_fiber_yield
  end
  
  def self.patch_fiber_new
    Fiber.singleton_class.prepend(Module.new do
      def new(*args, **kwargs, &block)
        fiber = super
        Rails.logger.debug("Fiber created: #{fiber.object_id} by #{caller_locations(1,1)[0].label} #{caller_locations(1,1)[0].path}:#{caller_locations(1,1)[0].lineno}")

        # Print when garbage collected
        ObjectSpace.define_finalizer(fiber, proc { Rails.logger.debug("Fiber finalized: #{fiber.object_id}") })
        fiber
      end
    end)
  end
  
  def self.patch_fiber_yield
    Fiber.prepend(Module.new do
      def yield(*args)
        Rails.logger.debug("Fiber yielding: #{self.object_id}")
        super
      end
      
      def resume(*args)
        Rails.logger.debug("Fiber resuming: #{self.object_id}")
        super
      end
    end)
  end
end

# Print fiber information in development
unless Rails.env.production?
  FiberDebug.setup
  Thread.new do
    loop do
      dead_ids = ObjectSpace.each_object(Fiber).reject(&:alive?).map { it.object_id }
      alive_count = ObjectSpace.each_object(Fiber).count { it.alive? }
      dead_count = ObjectSpace.each_object(Fiber).count { !it.alive? }
      fiber_count = ObjectSpace.each_object(Fiber).count
      puts "Fiber count: #{fiber_count} (#{alive_count} alive, #{dead_count} dead)"

      puts ObjectSpace.each_object(Fiber).filter_map { !it.alive? && it.try(:created_by) ? [1, it.try(:created_by).try(:first)] : nil }.group_by(&:last).transform_values(&:count)
      puts "Dead fibers: #{dead_ids.join(', ')}" unless dead_ids.empty?
      sleep 10
    end
  end
end