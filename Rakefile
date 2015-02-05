task :opal do
  require 'opal'
  js_path = 'js/vendor/opal.js'
  built_source = Opal::Builder.build('opal').to_s
  built_source += Opal::Builder.build('native').to_s
  built_source += Opal::Builder.build('promise').to_s
  built_source += Opal::Builder.build('opal-parser').to_s
  built_source += Opal::Builder.build('opal/source_map').to_s
  File.write js_path, built_source
  puts "Compiled Opal to #{js_path}."
end