# frozen_string_literal: true

# Run `bundle exec rake benchmark` to execute benchmark.
# This is very much a work-in-progress. Please feel free to make/suggest improvements!

require "benchmark/ips"
require "json"

bench_data = if File.exist?("gob_bench.json")
  JSON.parse(File.read("gob_bench.json"))
else
  []
end

if bench_data.size == 1
  if ENV.fetch("VIEW_COMPONENT_PREPEND_GOB", "false") != "true"
    raise "Please run #{__FILE__} with VIEW_COMPONENT_PREPEND_GOB=true on the second benchmark run."
  end
elsif bench_data.size == 2
  if ENV.fetch("VIEW_COMPONENT_USE_GLOBAL_OUTPUT_BUFFER", "false") != "true"
    raise "Please run #{__FILE__} with VIEW_COMPONENT_USE_GLOBAL_OUTPUT_BUFFER=true on the third benchmark run."
  end
end

# Configure Rails Environment
ENV["RAILS_ENV"] = "production"
require File.expand_path("../test/sandbox/config/environment.rb", __dir__)

module Performance
  require_relative "components/name_component.rb"
  require_relative "components/nested_name_component.rb"
end

class BenchmarksController < ActionController::Base
end

BenchmarksController.view_paths = [File.expand_path("./views", __dir__)]
controller_view = BenchmarksController.new.view_context

Benchmark.ips do |x|
  x.time = 10
  x.warmup = 2

  x.hold! "gob_bench.json"

  x.report("no GOB or prepend") do
    controller_view.render(Performance::NameComponent.new(name: "Fox Mulder"))
  end

  x.report("no GOB") do
    controller_view.render(Performance::NameComponent.new(name: "Fox Mulder"))
  end

  x.report("with GOB") do
    controller_view.render(Performance::NameComponent.new(name: "Fox Mulder"))
  end

  x.compare!
end
