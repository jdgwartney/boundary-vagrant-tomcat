# Explictly set to avoid warning message
Package {
  allow_virtual => false,
}

exec { 'update-packages':
  command => '/usr/bin/yum update -y',
  creates => '/vagrant/.locks/update-packages',
}

#
# Add the GPG key to our system
#
exec { 'elasticsearch-repo-gpg-key':
  command => '/bin/rpm --import https://packages.elasticsearch.org/GPG-KEY-elasticsearch',
  creates => '/vagrant/.locks/add-elasticsearch-repo',
  require => Exec['update-packages']
}

#
# Update our yum repository
# TODO: Only perform this on Centos/Fedora/RedHat
file { 'elasticsearch.repo':
  path    => '/etc/yum.repos.d/elasticsearch.repo',
  ensure  => file,
  require => Exec['elasticsearch-repo-gpg-key'],
  source  => '/vagrant/manifests/elasticsearch.repo'
}

file { 'bash_profile':
  path    => '/home/vagrant/.bash_profile',
  ensure  => file,
  require => Class['elasticsearch'],
  source  => '/vagrant/manifests/bash_profile'
}


#
# TODO: Multiple Nodes for Elastic Search
#
#node "boundary-elastic-search" {

 class { 'boundary':
    token => 'api.a6df22c660-2105'
  }

  class { 'java':
    distribution => 'jdk',
  }

#  class { 'elasticsearch':
#    ensure => 'present',
#    require => [File['elasticsearch.repo'], Class['java']]
#  }

  class { 'elasticsearch':
    config => { 'cluster.name' => 'boundary' },
    require => [File['elasticsearch.repo'], Class['java']]
  }

  elasticsearch::instance { 'boundary-es-001':
    config => { 'node.master' => 'true', 'node.data' => 'true'}
  }
  elasticsearch::instance { 'boundary-es-002':
    config => { 'node.master' => 'false', 'node.data' => 'true'}
  }
  elasticsearch::instance { 'boundary-es-003':
    config => { 'node.master' => 'false', 'node.data' => 'true'}
  }

#}
