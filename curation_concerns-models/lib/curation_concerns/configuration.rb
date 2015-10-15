module CurationConcerns
  extend Deprecation
  class << self
    attr_accessor :config
  end

  def self.configure
    self.config ||= Configuration.new
    yield(config)
  end

  # Keep this deprecated class here so that anyone that references it in their config gets a deprecation rather than uninitialized constant.
  # Remove when Configuration#queue= is removed
  module Resque
    class Queue
    end
  end

  class Configuration
    # An anonymous function that receives a path to a file
    # and returns AntiVirusScanner::NO_VIRUS_FOUND_RETURN_VALUE if no
    # virus is found; Any other returned value means a virus was found
    attr_writer :default_antivirus_instance
    def default_antivirus_instance
      @default_antivirus_instance ||= lambda do|_file_path|
        AntiVirusScanner::NO_VIRUS_FOUND_RETURN_VALUE
      end
    end

    # Path on the local file system where derivatives will be stored
    attr_writer :derivatives_path
    def derivatives_path
      @derivatives_path ||= File.join(Rails.root, 'tmp', 'derivatives')
    end

    # Path on the local file system where originals will be staged before being ingested into Fedora.
    attr_writer :working_path
    def working_path
      @working_path ||= File.join(Rails.root, 'tmp', 'uploads')
    end

    attr_writer :enable_ffmpeg
    def enable_ffmpeg
      return @enable_ffmpeg unless @enable_ffmpeg.nil?
      @enable_ffmpeg = false
    end

    attr_writer :ffmpeg_path
    def ffmpeg_path
      @ffmpeg_path ||= 'ffmpeg'
    end

    attr_writer :fits_message_length
    def fits_message_length
      @fits_message_length ||= 5
    end

    attr_accessor :temp_file_base, :enable_local_ingest, :analytic_start_date,
                  :fits_to_desc_mapping, :max_days_between_audits,
                  :resource_types, :resource_types_to_schema,
                  :permission_levels, :owner_permission_levels, :analytics,
                  :after_create_content

    attr_writer :enable_noids
    def enable_noids
      return @enable_noids unless @enable_noids.nil?
      @enable_noids = true
    end

    attr_writer :noid_template
    def noid_template
      @noid_template ||= '.reeddeeddk'
    end

    attr_writer :minter_statefile
    def minter_statefile
      @minter_statefile ||= '/tmp/minter-state'
    end

    attr_writer :redis_namespace
    def redis_namespace
      @redis_namespace ||= 'curation_concerns'
    end

    attr_writer :queue
    deprecation_deprecate :queue=

    attr_writer :fits_path
    def fits_path
      @fits_path ||= 'fits.sh'
    end

    # Override characterization runner
    attr_accessor :characterization_runner

    # Attributes for the lock manager which ensures a single process/thread is mutating a ore:Aggregation at once.
    # @!attribute [w] lock_retry_count
    #   How many times to retry to acquire the lock before raising UnableToAcquireLockError
    attr_writer :lock_retry_count
    def lock_retry_count
      @lock_retry_count ||= 600 # Up to 2 minutes of trying at intervals up to 200ms
    end

    # @!attribute [w] lock_time_to_live
    #   How long to hold the lock in milliseconds
    attr_writer :lock_time_to_live
    def lock_time_to_live
      @lock_time_to_live ||= 60_000 # milliseconds
    end

    # @!attribute [w] lock_retry_delay
    #   Maximum wait time in milliseconds before retrying. Wait time is a random value between 0 and retry_delay.
    attr_writer :lock_retry_delay
    def lock_retry_delay
      @lock_retry_delay ||= 200 # milliseconds
    end

    attr_reader :after_create_content
    def after_create_content=(callback)
      raise ArgumentError, 'after_create_content= requires an argument that responds to :call, e.g. a Proc' unless callback.respond_to?(:call) || callback.nil?
      @after_create_content = callback
    end

    def register_curation_concern(*curation_concern_types)
      Array(curation_concern_types).flatten.compact.each do |cc_type|
        class_name = normalize_concern_name(cc_type)
        unless registered_curation_concern_types.include?(class_name)
          registered_curation_concern_types << class_name
        end
      end
    end

    # Returns the class names (strings) of the registered curation concerns
    def registered_curation_concern_types
      @registered_curation_concern_types ||= []
    end

    # Returns the classes of the registered curation concerns
    def curation_concerns
      registered_curation_concern_types.map(&:constantize)
    end

    private

      def normalize_concern_name(c)
        c.to_s.camelize
      end
  end

  configure {}
end
