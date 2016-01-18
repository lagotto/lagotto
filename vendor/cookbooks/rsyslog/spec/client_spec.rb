require 'spec_helper'

describe 'rsyslog::client' do
  let(:chef_run) do
    ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '12.04') do |node|
      node.set['rsyslog']['server_ip'] = server_ip
      node.set['rsyslog']['custom_remote'] = custom_remote
    end.converge(described_recipe)
  end

  let(:server_ip) { "10.#{rand(1..9)}.#{rand(1..9)}.50" }
  let(:custom_remote) { [{ 'server' => '10.0.0.1', 'port' => 555, 'protocol' => 'tcp', 'logs' => 'auth.*,mail.*', 'remote_template' => 'RSYSLOG_SyslogProtocol23Format' }] }
  let(:service_resource) { 'service[rsyslog]' }

  it 'includes the default recipe' do
    expect(chef_run).to include_recipe('rsyslog::default')
  end

  context '/etc/rsyslog.d/49-remote.conf template' do
    let(:template) { chef_run.template('/etc/rsyslog.d/49-remote.conf') }

    it 'creates the template' do
      expect(chef_run).to render_file(template.path).with_content { |content|
        expect(content).to include("*.* @@#{server_ip}:514")
        expect(content).to include("#{custom_remote.first['logs']} @@#{custom_remote.first['server']}:#{custom_remote.first['port']};#{custom_remote.first['remote_template']}")
      }
    end

    it 'is owned by root:root' do
      expect(template.owner).to eq('root')
      expect(template.group).to eq('root')
    end

    it 'has 0644 permissions' do
      expect(template.mode).to eq('0644')
    end

    it 'notifies restarting the service' do
      expect(template).to notify(service_resource).to(:restart)
    end

    context 'on SmartOS' do
      let(:chef_run) do
        ChefSpec::ServerRunner.new(platform: 'smartos', version: 'joyent_20130111T180733Z') do |node|
          node.set['rsyslog']['server_ip'] = server_ip
          node.set['rsyslog']['custom_remote'] = custom_remote
        end.converge(described_recipe)
      end

      let(:template) { chef_run.template('/opt/local/etc/rsyslog.d/49-remote.conf') }

      it 'creates the template' do
        expect(chef_run).to render_file(template.path).with_content { |content|
          expect(content).to include("*.* @@#{server_ip}:514")
          expect(content).to include("#{custom_remote.first['logs']} @@#{custom_remote.first['server']}:#{custom_remote.first['port']};#{custom_remote.first['remote_template']}")
        }
      end

      it 'is owned by root:root' do
        expect(template.owner).to eq('root')
        expect(template.group).to eq('root')
      end

      it 'has 0644 permissions' do
        expect(template.mode).to eq('0644')
      end

      it 'notifies restarting the service' do
        expect(template).to notify(service_resource).to(:restart)
      end
    end
  end

  context '/etc/rsyslog.d/server.conf file' do
    let(:file) { chef_run.file('/etc/rsyslog.d/server.conf') }

    it 'deletes the file' do
      expect(chef_run).to delete_file(file.path)
    end

    it 'notifies restarting the service' do
      expect(file).to notify(service_resource).to(:restart)
    end

    context 'on SmartOS' do
      let(:chef_run) do
        ChefSpec::ServerRunner.new(platform: 'smartos', version: 'joyent_20130111T180733Z') do |node|
          node.set['rsyslog']['server_ip'] = server_ip
        end.converge(described_recipe)
      end

      let(:file) { chef_run.file('/opt/local/etc/rsyslog.d/server.conf') }

      it 'deletes the file' do
        expect(chef_run).to delete_file(file.path)
      end

      it 'notifies restarting the service' do
        expect(file).to notify(service_resource).to(:restart)
      end
    end
  end
end
