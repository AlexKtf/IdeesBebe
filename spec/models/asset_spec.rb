require 'spec_helper'

describe Asset do

  describe PhotoUploader do
    include CarrierWave::Test::Matchers

    before do
      PhotoUploader.enable_processing = true
      @uploader = PhotoUploader.new(@user, :avatar)
      @uploader.store!(File.open("#{Rails.root}/public/default_avatar.png"))
    end

    after do
      PhotoUploader.enable_processing = false
      @uploader.remove!
    end

    context 'avatar version' do
      it "create an avatar with 160x160" do
        @uploader.should have_dimensions(160, 160)
      end
    end

    context 'the thumb version' do
      it "create an avatar with 100x100" do
        @uploader.thumb.should have_dimensions(100, 100)
      end
    end
  end
end
