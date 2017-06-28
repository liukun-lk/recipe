# config/initializers/routing_draw.rb
# Adds draw method into Rails routing
# It allows us to keep routing splitted into files
class ActionDispatch::Routing::Mapper
  def draw(routes_name)
    instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
  end
end

# But the rails server can't autoload route when you modify the route in config/routes.
# So you can use it to listen file update.
class RoutesReloader
  def initialize(app)
    @app = app

    @routes_reloader = ActiveSupport::FileUpdateChecker.new([], 'config/routes' => 'rb') do
      Rails.application.reload_routes!
    end
  end

  def call(env)
    @routes_reloader.execute_if_updated

    @app.call(env)
  end
end
