if ENV['COVERAGE']
  SimpleCov.start do
    add_filter '/test/'
    add_filter '/features/'
    add_filter '/spec/'
        
    add_filter '/config/'
    add_filter '/db/'
    add_filter '/AbstractsMetadataService'
  
    add_filter '/vendor/bundle/'

    add_group 'Controllers', 'app/controllers'
    add_group 'Models', 'app/models'
    add_group 'Helpers', 'app/helpers'
    add_group 'Libraries', 'lib'
  end
end