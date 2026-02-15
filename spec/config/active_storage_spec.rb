# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ActiveStorage Configuration', type: :config do
  describe 'storage service configuration' do
    it 'uses :test service in test environment' do
      expect(Rails.configuration.active_storage.service).to eq(:test)
    end

    it 'has configured test service in storage.yml' do
      storage_config = YAML.load_file(Rails.root.join('config', 'storage.yml'))
      expect(storage_config).to have_key('test')
      expect(storage_config['test']['service']).to eq('Disk')
    end

    it 'has configured cloudinary service in storage.yml' do
      storage_config = YAML.load_file(Rails.root.join('config', 'storage.yml'))
      expect(storage_config).to have_key('cloudinary')
      expect(storage_config['cloudinary']['service']).to eq('Cloudinary')
    end
  end

  describe 'ActiveStorage tables' do
    it 'has active_storage_blobs table' do
      expect(ActiveStorage::Blob.table_exists?).to be true
    end

    it 'has active_storage_attachments table' do
      expect(ActiveStorage::Attachment.table_exists?).to be true
    end

    it 'has active_storage_variant_records table' do
      expect(ActiveStorage::VariantRecord.table_exists?).to be true
    end

    it 'has correct columns in active_storage_blobs' do
      expect(ActiveStorage::Blob.column_names).to include(
        'key',
        'filename',
        'content_type',
        'metadata',
        'service_name',
        'byte_size',
        'checksum'
      )
    end

    it 'has correct columns in active_storage_attachments' do
      expect(ActiveStorage::Attachment.column_names).to include(
        'name',
        'record_type',
        'record_id',
        'blob_id'
      )
    end
  end

  describe 'Cloudinary initialization' do
    it 'loads Cloudinary configuration without error' do
      expect { Cloudinary.config }.not_to raise_error
    end

    it 'has Cloudinary configuration (in production only)' do
      if Rails.env.production?
        expect(Cloudinary.config.cloud_name).to be_present
        expect(Cloudinary.config.api_key).to be_present
        expect(Cloudinary.config.api_secret).to be_present
        expect(Cloudinary.config.secure).to be true
      else
        # Development/Test環境では設定なしでもエラーにならない
        expect { Cloudinary.config }.not_to raise_error
      end
    end
  end
end
