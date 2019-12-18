require 'spec_helper'

describe LocaleDetector::Action do

  before do
    @enforce_available_locales = I18n.enforce_available_locales
    I18n.enforce_available_locales = false
  end

  after do
    I18n.enforce_available_locales = @enforce_available_locales
  end

  def set_locale(opts = {})
    action = Object.new.extend(LocaleDetector::Action)

    request =
      if opts[:language].present?
        double('request', :env => { 'HTTP_ACCEPT_LANGUAGE' => opts[:language] })
      elsif opts[:host].present?
        double('request', :env => nil, :host => opts[:host])
      end

    session =
      if opts[:session_language].present?
        double('session', :[] => opts[:session_language])
      else
        double('session', :[] => '')
      end

    allow(action).to receive(:session).and_return(session)
    allow(action).to receive(:request).and_return(request)
    action.send(:set_locale)
  end

  it "can overwrite session[:language] locale" do
    expect(set_locale(:language => 'pt-BR', :session_language => 'pl')).to eq('pl')
  end

  it "can set http header locale" do
    expect(set_locale(:language => 'pl')).to eq('pl')
    expect(set_locale(:language => 'pl-PL')).to eq('pl')
    expect(set_locale(:language => 'pt-BR')).to eq('pt')
    expect(set_locale(:language => 'pl,en-us;q=0.7,en;q=0.3')).to eq('pl')
    expect(set_locale(:language => 'lt,en-us;q=0.8,en;q=0.6,ru;q=0.4,pl;q=0.2')).to eq('lt')
    expect(set_locale(:language => 'pl-PL;q=0.1,en-us;q=0.7,en;q=0.3')).to eq('en')
  end

  it "can set host based locale" do
    expect(set_locale(:host => 'example.pl')).to eq('pl')
    expect(set_locale(:host => 'example.co.uk')).to eq('en')
    expect(set_locale(:host => 'example.mx')).to eq('es')
    expect(set_locale(:host => 'example.br')).to eq('pt')
    expect(set_locale(:host => 'example.jp')).to eq('ja')
    expect(set_locale(:host => 'example.se')).to eq('sv')
  end

  context "default fallback" do
    before do
      I18n.default_locale = 'de'
    end

    it "can be set" do
      expect(set_locale(:host => 'example.com')).to eq('de')
    end
  end

end
