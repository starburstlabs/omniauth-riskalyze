require 'spec_helper'

describe Omniauth::Riskalyze do
  it 'has a version number' do
    expect(Omniauth::Riskalyze::VERSION).not_to be nil
  end

  it 'is version 0.2.0' do
    expect(Omniauth::Riskalyze::VERSION).to eq('0.2.0')
  end
end

describe OmniAuth::Strategies::Riskalyze do
  subject { described_class }

  it 'inherits from OmniAuth::Strategies::OAuth2' do
    expect(described_class.ancestors).to include(OmniAuth::Strategies::OAuth2)
  end

  it 'sets the correct authorize URL' do
    expect(described_class.default_options[:client_options][:authorize_url])
      .to eq('https://pro.riskalyze.com/oauthconnect')
  end

  it 'sets the correct token URL' do
    expect(described_class.default_options[:client_options][:token_url])
      .to eq('https://api2.riskalyze.com/ap/v1/oauthpro/token')
  end

  it 'defines the default scope constant' do
    expect(OmniAuth::Strategies::Riskalyze::DEFAULT_SCOPE).to eq('com.riskalyze.client.read')
  end
end
