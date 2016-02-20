Rails.application.config.after_initialize do |app|
  app.config.assets.configure do |envt|
    env.register_engine '.haml', Tilt::HamlTemplate
  end
end
