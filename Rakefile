#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Money::Application.load_tasks


task default: [:full_test]

desc 'Run RSpec and Cucumber tests'
task full_test: [:spec, :cucumber]
