# web_static_setup.pp

# Update package repositories
exec { 'apt-update':
  command     => '/usr/bin/apt-get update',
  path        => ['/usr/bin', '/bin'],
  refreshonly => true,
}

# Install nginx package
package { 'nginx':
  ensure => installed,
}

# Create directories
file { '/data/web_static/shared':
  ensure => directory,
}

file { '/data/web_static/releases/test':
  ensure => directory,
}

# Create index.html file with content
file { '/data/web_static/releases/test/index.html':
  ensure  => present,
  content => '<html>
  <head>
  </head>
  <body>
    Holberton School
  </body>
</html>',
}

# Create symbolic link
file { '/data/web_static/current':
  ensure  => link,
  target  => '/data/web_static/releases/test',
  require => File['/data/web_static/releases/test/index.html'],
}

# Set ownership
file { '/data':
  ensure  => directory,
  owner   => 'ubuntu',
  group   => 'ubuntu',
  recurse => true,
}

# Add location block to Nginx configuration
file_line { 'nginx-hbnb_static':
  ensure  => present,
  path    => '/etc/nginx/sites-available/default',
  line    => '        location /hbnb_static {',
  after   => '        index index.html index.htm index.nginx-debian.html;',
  require => Package['nginx'],
}

file { '/etc/nginx/sites-available/default':
  ensure  => file,
  content => "\
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }

    location /hbnb_static {
        alias /data/web_static/current/;
    }
}
",
}

# Restart nginx service
service { 'nginx':
  ensure    => running,
  enable    => true,
  subscribe => [
    File_line['nginx-hbnb_static'],
    File['/data/web_static/releases/test/index.html'],
  ],
}
