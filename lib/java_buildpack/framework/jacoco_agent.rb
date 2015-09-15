# Encoding: utf-8
# Cloud Foundry Java Buildpack
# Copyright 2015 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'fileutils'
require 'java_buildpack/component/versioned_dependency_component'
require 'java_buildpack/framework'
require 'java_buildpack/util/qualify_path'

module JavaBuildpack
  module Framework

    # Encapsulates the functionality for enabling zero-touch Jacoco support.
    class JacocoAgent < JavaBuildpack::Component::VersionedDependencyComponent
      include JavaBuildpack::Util

      # (see JavaBuildpack::Component::BaseComponent#compile)
      def compile
        download_zip false
        @droplet.copy_resources
      end

      # (see JavaBuildpack::Component::BaseComponent#release)
      def release
      #-javaagent:D:\jacoco\lib\jacocoagent.jar=address=%JACOCO_SERVER_URL%,port=%JACOCO_SERVER_PORT%,output=tcpclient,includes=com.covisint.platform.clog.*,append=true"
       java_opts   = @droplet.java_opts
       java_opts.add_javaagent(@droplet.sandbox + 'lib/jacocoagent.jar=output=tcpclient,address=localhost,port=6300,includes=*,append=true")
       #@droplet.java_opts
                #.add_agentpath_with_props(@droplet.sandbox + "lib/jacocoagent.jar=", output:"tcpclient", address: "localhost", port:"6300")
                            
      end

      protected

      # (see JavaBuildpack::Component::VersionedDependencyComponent#supports?)
      def supports?
       true
       # @application.services.one_service? FILTER, 'configuration'
      end

      private

      FILTER = /jacoco/.freeze

      private_constant :FILTER

      def application_name
        @application.details['application_name']
      end
      
      def configuration
        @application.services.find_service(FILTER)['agentconfig']['configuration'] || 'output=tcpclient,address=localhost,port=6300,includes=*'
      end
      
      def agent_dir
        @droplet.sandbox + 'home/jacoco'
      end

      def logs_dir
        @droplet.sandbox + 'home/log'
      end

      def home_dir
        @droplet.sandbox + 'home'
      end

    end

  end
end
