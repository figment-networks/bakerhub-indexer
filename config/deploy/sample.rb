server 'host-or-ip', user: 'bakerhub', roles: %w{ app db web }

set :ssh_options, {
  keys: %w{ ~/.ssh/some-key },
  forward_agent: true
}

set :stage, nil
raise RuntimeError.new( "\n\n#{'*'*45}\n            Hello from BakerHub!\nThis is just a sample stage. Define your own!\n#{'*'*45}\n\n" )
