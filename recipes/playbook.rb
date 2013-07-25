require 'find'

remove_file 'app/assets/stylesheets/application.css'
remove_file 'public/index.html'
remove_file 'app/assets/images/rails.png'

get 'https://api.github.com/repos/centresource/playbook/tarball', '/tmp/playbook.tar.gz'
remove_dir '/tmp/playbook' if Dir.exist? '/tmp/playbook'
empty_directory '/tmp/playbook'
`tar -zxvf /tmp/playbook.tar.gz -C /tmp/playbook 2> /dev/null`

# exclude:
# => files and directories beginning with "."
# => "burbon" directory
# => "neat" directory
# => versioned "jquery-X.X.X.min.js" file
# => "application.coffee" file
exclude = [/^\./, /^(?:bourbon|neat|jquery.+?min\.js|application\.coffee)$/]

Dir.glob('/tmp/playbook/*/{app,vendor}/assets/').each do |dir_path|
  Find.find(dir_path) do |path|
    if exclude.none? { |regex| regex =~ File.basename(path) }
      if File.directory? path
        FileUtils.makedirs path[/(?:app|vendor).*/]
      else
        copy_file path, path[/(?:app|vendor).*/]
      end
    else
      Find.prune
    end
  end
end

remove_dir '/tmp/playbook'
remove_file '/tmp/playbook.tar.gz'

append_to_file 'app/assets/javascripts/application.js', '//= require plugins'
mirror_file 'app/views/layouts/application.html.erb', "#{template_path}/default"
