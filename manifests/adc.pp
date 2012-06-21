# Class: gitolite::adc
#
# This class allows managing ADC feature
#
# Parameters:
#
# Actions:
#
#   Configures gitolite ADC path in .gitolite.rc, creates adc directory in gitolite home,
#   and defines resources for adc script symlinks in adc directory
#
# Requires:
#
#   class gitolite
#
# Sample Usage:
#
#   class {
#     "gitolite":
#       ...
#   }
#   class {
#     "gitolite::gl-setup":
#       ...
#   }
#   class { "gitolite::adc": }
#   gitolite::adc::command { "able": }
#   gitolite::adc::command { "git-annex-shell": }
#
# [Remember: No empty lines between comments and class definition]
class gitolite::adc {
  Class[ 'gitolite::gl-setup' ] -> Class[ 'gitolite::adc' ]

  exec {
    'set GL_ADC_PATH':
      command => "/bin/sed -i -e '/\$GL_ADC_PATH\\b/s|.\\+|\$GL_ADC_PATH = \"${gitolite::homedir}/adc\";|' ${gitolite::homedir}/.gitolite.rc",
  }

  file {
    "${gitolite::homedir}/adc":
      ensure  => directory,
      force   => true,
      group   => "${gitolite::user}",
      owner   => "${gitolite::user}",
      mode    => 750,
      require => [ Exec[ 'set GL_ADC_PATH' ] ],
  }
  file {
    "${gitolite::homedir}/adc/ua":
      ensure  => directory,
      force   => true,
      group   => "${gitolite::user}",
      owner   => "${gitolite::user}",
      mode    => 750,
  }

  define command ($ua = false, $command_src = "${gitolite::srcdir}/contrib/adc/${title}") {
    file {
      "${gitolite::homedir}/adc/${title}":
        ensure  => $ua ? {
          true    => "absent",
          default => "link",
        },
        force   => true,
        group   => "${gitolite::user}",
        owner   => "${gitolite::user}",
        target  => "$command_src",
    }
    file {
      "${gitolite::homedir}/adc/ua/${title}":
        ensure  => $ua ? {
          true    => "link",
          default => "absent",
        },
        force   => true,
        group   => "${gitolite::user}",
        owner   => "${gitolite::user}",
        target  => "$command_src",
    }
  }

  gitolite::adc::command { "adc.common-functions": }
}
#
# Copyright (C) 2012 Oleg Chunikhin <oleg.chunikhin@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
