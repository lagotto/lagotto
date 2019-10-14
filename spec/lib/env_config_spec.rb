require 'rails_helper'

describe EnvConfig, vcr: false, focus: true do
  describe '.config_for' do
    it 'converts specially formatted env vars to a hash' do
      expect(EnvConfig).to receive(:env_vars_for).with('SUBSCRIBERS__').and_return({
          "SUBSCRIBERS__0__JOURNAL" => "pmed",
          "SUBSCRIBERS__0__SOURCE" => "crossref",
          "SUBSCRIBERS__0__MILESTONES__0" => "1",
          "SUBSCRIBERS__0__MILESTONES__1" => "15",
          "SUBSCRIBERS__0__URL" => "https://example.com/notify-me-about-xref-changes-for-journal-pmed",
          "SUBSCRIBERS__1__JOURNAL" => "pone",
          "SUBSCRIBERS__1__SOURCE" => "crossref",
          "SUBSCRIBERS__1__MILESTONES__0" => "1",
          "SUBSCRIBERS__1__MILESTONES__1" => "15",
          "SUBSCRIBERS__1__URL" => "https://example.com/notify-me-about-xref-changes-for-journal-pone",
          "SUBSCRIBERS__2__NESTING__0__0" => "1",
          "SUBSCRIBERS__2__NESTING__0__1" => "25",
          "SUBSCRIBERS__2__NESTING__0__2__0" => "45",
          "SUBSCRIBERS__2__NESTING__0__2__1__NESTED__KEY" => "way nested",
          "SUBSCRIBERS__2__URL" => "https://example.com/complex-nesting"
      })

      expect(EnvConfig.config_for('SUBSCRIBERS__')).to eq({ subscribers: [
        {
          journal: 'pmed',
          source: 'crossref',
          milestones: [1, 15],
          url: 'https://example.com/notify-me-about-xref-changes-for-journal-pmed',
        },
        {
          journal: 'pone',
          source: 'crossref',
          milestones: [1, 15],
          url: 'https://example.com/notify-me-about-xref-changes-for-journal-pone',
        },
        {
          nesting: [[1, 25, [45, {nested: {key: "way nested"}}]]],
          url: 'https://example.com/complex-nesting',
        }
      ]})
    end
  end
end
