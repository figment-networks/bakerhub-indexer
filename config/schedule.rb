run_task = "NO_PROGRESS=1 /usr/bin/nice -n 10 bin/rake :task --silent :output"
abort_task = 'echo "Not running, release is old."'

def log_path(name)
  File.join('/home/bakerhub/app/shared/log', name+'.log')
end

job_type :rake, [
  'cd :path', 'source ~/.env',
  %{ [ $(pwd) = $(readlink "/home/bakerhub/app/current") ] && #{run_task} || #{abort_task} }
].join( ' && ' )


every 1.minute do
  rake 'sync', output: log_path('tezos')
  rake 'sync_governance', output: log_path('tezos')
end
