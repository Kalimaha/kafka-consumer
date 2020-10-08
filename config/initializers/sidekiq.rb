Sidekiq.configure_server do |config|
  config.redis = { url: "redis://h:p4415238204eb97b9e3cf312dc17edfbcc278a4456676cadefb5c1d9e666672c5@ec2-34-234-48-32.compute-1.amazonaws.com:29699" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://h:p4415238204eb97b9e3cf312dc17edfbcc278a4456676cadefb5c1d9e666672c5@ec2-34-234-48-32.compute-1.amazonaws.com:29699" }
end
