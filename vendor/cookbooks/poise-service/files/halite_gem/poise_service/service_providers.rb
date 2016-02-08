#
# Copyright 2015-2016, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/platform/provider_priority_map'

require 'poise_service/service_providers/dummy'
require 'poise_service/service_providers/inittab'
require 'poise_service/service_providers/systemd'
require 'poise_service/service_providers/sysvinit'
require 'poise_service/service_providers/upstart'


module PoiseService
  # Inversion providers for the poise_service resource.
  #
  # @since 1.0.0
  module ServiceProviders
    # Set up priority maps
    Chef::Platform::ProviderPriorityMap.instance.priority(:poise_service, [
      PoiseService::ServiceProviders::Systemd,
      PoiseService::ServiceProviders::Upstart,
      PoiseService::ServiceProviders::Sysvinit,
    ])
  end
end
