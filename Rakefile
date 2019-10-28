task :install do
  sh 'bundle install --standalone --without development'
  sh 'rsync -av --delete ./ ~/opt/pomodorod'
  rm_rf %w(.bundle bundle)
end

task 'install-source-only' do
  sh 'rsync -av --delete ./bin ./lib ./pomodorod.service ~/opt/pomodorod'
end
