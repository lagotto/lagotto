def whyrun_supported?
  true
end

use_inline_resources

def load_current_resource
  @current_resource = Chef::Resource::CapistranoTemplate.new(new_resource.name)
end

action :create do
  # create file from template in parent cookbook
  files = new_resource.name.split("/")
  files.each_index do |i|
    if i + 1 < files.length
      # create parent folders of file with correct permissions
      dir = files[0..i].join("/")
      directory "/var/www/#{new_resource.application}/shared/#{dir}" do
        owner new_resource.user
        group new_resource.group
        mode '0755'
      end
    else
      # create file from template
      template "/var/www/#{new_resource.application}/shared/#{new_resource.name}" do
        source new_resource.source
        variables(
          :application => new_resource.application,
          :params      => new_resource.params
        )
        action :create
      end
    end
  end
end
