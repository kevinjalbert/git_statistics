begin
  if ENV['CI']
    require 'coveralls'
    Coveralls.wear!
  elsif ENV['COVERAGE']
    require 'simplecov'
  end

  if ENV['CI'] || ENV['COVERAGE']
    SimpleCov.start do
      add_filter "/spec/"
    end
  end
rescue LoadError
end
