FROM ruby:3.3.6-slim

WORKDIR /app

# Install dependencies required for building native extensions
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy gemspec and version file first to leverage Docker caching
COPY inferno_suite_generator.gemspec /app/
COPY lib/inferno_suite_generator/version.rb /app/lib/inferno_suite_generator/version.rb

# Copy the rest of the application
COPY . /app/

# Install dependencies
RUN bundle install

# Set the entrypoint to the generator
ENTRYPOINT ["ruby", "-e", "require 'inferno_suite_generator'; InfernoSuiteGenerator::Generator.generate(ARGV[0])"]

# Default command (can be overridden)
CMD ["--help"]