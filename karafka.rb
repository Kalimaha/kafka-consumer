# frozen_string_literal: true

require "tempfile"

# This file is auto-generated during the install process.
# If by any chance you've wanted a setup for Rails app, either run the `karafka:install`
# command again or refer to the install templates available in the source codes

ENV['RACK_ENV'] ||= 'development'
ENV['KARAFKA_ENV'] ||= ENV['RACK_ENV']
Bundler.require(:default, ENV['KARAFKA_ENV'])

# Zeitwerk custom loader for loading the app components before the whole
# Karafka framework configuration
APP_LOADER = Zeitwerk::Loader.new
APP_LOADER.enable_reloading

%w[
  lib
  app/consumers
  app/responders
  app/workers
].each(&APP_LOADER.method(:push_dir))

APP_LOADER.setup
APP_LOADER.eager_load

class CloudKarafkaTopicMapper
  def initialize(prefix)
    @prefix = "#{prefix}-"
  end

  def incoming(topic)
    topic.to_s.gsub(@prefix, '')
  end

  def outgoing(topic)
    "#{@prefix}#{topic}"
  end
end

class KarafkaApp < Karafka::App
  # tmp_ca_file = Tempfile.new("ca_certs")
  # tmp_ca_file.write(ENV.fetch("KAFKA_TRUSTED_CERT"))
  # tmp_ca_file.close

  
  
  setup do |config|
    # byebug
    # config.kafka.seed_brokers = [ENV.fetch("KAFKA_URL")]

    # seed_brokers = ENV.fetch("KAFKA_URL").split(",")
    # seed_brokers.each_with_index do |idx, sb|
    #   puts "#{idx} -> #{sb}"
    # end

    # config.kafka.seed_brokers = seed_brokers
    # config.kafka.ssl_ca_cert_file_path = tmp_ca_file.path
    # config.kafka.ssl_client_cert = ENV.fetch("KAFKA_CLIENT_CERT")
    # config.kafka.ssl_client_cert_key = ENV.fetch("KAFKA_CLIENT_CERT_KEY")
    # config.kafka.ssl_verify_hostname = false

    config.backend = :sidekiq
    
    # config.redis = {
    #   url: 'redis://h:p4415238204eb97b9e3cf312dc17edfbcc278a4456676cadefb5c1d9e666672c5@ec2-34-234-48-32.compute-1.amazonaws.com:29699'
    # }

    config.topic_mapper = CloudKarafkaTopicMapper.new(ENV['CLOUDKARAFKA_USERNAME'])
    config.consumer_mapper = proc { |name| "#{ENV['CLOUDKARAFKA_USERNAME']}-#{name}" }
    config.kafka.seed_brokers = ENV['CLOUDKARAFKA_BROKERS']&.split(",")&.map { |b| "kafka://#{b}" }
    config.kafka.sasl_scram_username = ENV['CLOUDKARAFKA_USERNAME']
    config.kafka.sasl_scram_password = ENV['CLOUDKARAFKA_PASSWORD']
    config.kafka.sasl_scram_mechanism = "sha256"
    config.kafka.ssl_ca_certs_from_system = true

    config.client_id = "example_app"

    # config.batch_fetching = true
    # config.batch_consuming = true

    # config.client_id = ENV['KAFKA_PREFIX']
  end

  # Comment out this part if you are not using instrumentation and/or you are not
  # interested in logging events for certain environments. Since instrumentation
  # notifications add extra boilerplate, if you want to achieve max performance,
  # listen to only what you really need for given environment.
  Karafka.monitor.subscribe(WaterDrop::Instrumentation::StdoutListener.new)
  Karafka.monitor.subscribe(Karafka::Instrumentation::StdoutListener.new)
  Karafka.monitor.subscribe(Karafka::Instrumentation::ProctitleListener.new)

  # Uncomment that in order to achieve code reload in development mode
  # Be aware, that this might have some side-effects. Please refer to the wiki
  # for more details on benefits and downsides of the code reload in the
  # development mode
  #
  Karafka.monitor.subscribe(
    Karafka::CodeReloader.new(
      APP_LOADER
    )
  )

  consumer_groups.draw do
    consumer_group :batched_group do
      batch_fetching true

      # topic :orders do
      #   consumer BatchConsumer
      #   batch_consuming true
      # end

      topic :orders do
        consumer BatchConsumer
        backend :sidekiq
        worker ApplicationWorker
        # batch_consuming true
      end

      # topic :orders do
      #   consumer CallbackConsumer
      #   batch_consuming true
      # end
    end
  end
end

Karafka.monitor.subscribe('app.initialized') do
  # Put here all the things you want to do after the Karafka framework
  # initialization
  Sidekiq.configure_server do |config|
    config.redis = { url: "redis://h:p4415238204eb97b9e3cf312dc17edfbcc278a4456676cadefb5c1d9e666672c5@ec2-34-234-48-32.compute-1.amazonaws.com:29699" }
  end
  
  Sidekiq.configure_client do |config|
    config.redis = { url: "redis://h:p4415238204eb97b9e3cf312dc17edfbcc278a4456676cadefb5c1d9e666672c5@ec2-34-234-48-32.compute-1.amazonaws.com:29699" }
  end
end



KarafkaApp.boot!
