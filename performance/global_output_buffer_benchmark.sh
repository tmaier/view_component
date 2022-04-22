#! /bin/bash

set -e

# no GOB or prepend
bundle exec ruby performance/global_output_buffer_benchmark.rb

# modules are prepended, but GOB is turned off
VIEW_COMPONENT_PREPEND_GOB=true \
  bundle exec ruby performance/global_output_buffer_benchmark.rb

# modules are prepended and GOB is enabled
VIEW_COMPONENT_USE_GLOBAL_OUTPUT_BUFFER=true \
  bundle exec ruby performance/global_output_buffer_benchmark.rb
