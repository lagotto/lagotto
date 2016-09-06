require "rails_helper"

describe "zenodo:requirements_check" do
  include WithEnv

  include_context "rake"

  let(:env_vars){
    {
      "ZENODO_KEY" => "1",
      "ZENODO_URL" => "example.com",
      "APPLICATION" => "value",
      "CREATOR" => "value",
      "SITE_TITLE" => "value",
      "GITHUB_URL" => "value"
    }
  }

  it "runs fine when all env variables expected are set" do
    with_env(env_vars){ subject.invoke }
  end

  context "when Zenodo env variables are missing" do
    %w(ZENODO_URL ZENODO_KEY).each do |env_var|
      it "errors when all the #{env_var} env var isn't set" do
        expect {
          without_env(env_var){ subject.invoke }
        }.to raise_error <<-EOS.gsub(/^\s*/, '')
          Zenodo integration is not configured. To integrate with Zenodo
          please make sure you have set the ZENODO_KEY and ZENODO_URL
          environment variables.
        EOS
      end
    end
  end

  %w(APPLICATION CREATOR SITE_TITLE GITHUB_URL).each do |env_var|
    it "errors when all the #{env_var} env var isn't set" do
      expect {
        without_env(env_var){ subject.invoke }
      }.to raise_error("#{env_var} env variable must be set!")
    end
  end

end
