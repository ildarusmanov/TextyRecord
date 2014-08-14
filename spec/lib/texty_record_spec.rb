require 'spec_helper'
require 'texty_record'

ENV.store('TEXTY_RECORD_JSON_STORAGE_FILE', File.join(File.dirname(__FILE__), '..', 'database.json'))

class TextyRecordPage < TextyRecord::Base
end


describe TextyRecord do
  before do
    File.open(ENV['TEXTY_RECORD_JSON_STORAGE_FILE'], 'w+') do |f|
      f.write({}.to_json)
    end
    @page_first = TextyRecordPage.new(title: 'Title 1', content: 'Test 1').save
    @page_second = TextyRecordPage.new(title: 'Title 2', content: 'Test 2').save
    @page_third = TextyRecordPage.new(title: 'Title 3', content: 'Test 3').save
  end

  it 'should have attribute methods' do
    texty_record_page = TextyRecordPage.first
    texty_record_page.attributes.keys.each do |attribute|
      expect(texty_record_page).to respond_to(attribute)
      expect(texty_record_page.send(attribute)).to eq(texty_record_page.attributes[attribute])
    end
  end

  it { expect(TextyRecordPage.all.count).to eq(3) }
  it { expect(TextyRecordPage.first.title).to eq('Title 1') }

  it 'should destroy record' do
    TextyRecordPage.first.destroy
    expect(TextyRecordPage.all.count).to eq(2)
  end

  it 'should save record' do
    TextyRecordPage.new(title: '123', content: '123').save
    expect(TextyRecordPage.all.count).to eq(4)
  end

  it { expect(TextyRecordPage.find(@page_second.id).attributes).to eq(@page_second.attributes) }
  it { expect(TextyRecordPage.all.count).to eq(3) }
  it { expect(TextyRecordPage.new(title: 'Test', content: 'Test').new_record?).to eq(true) }
  it { expect(TextyRecordPage.first.new_record?).to eq(false) }
  it { expect(TextyRecordPage.first.attributes.keys).to include(:id, :title, :content) }
  it { expect { TextyRecordPage.find(555) }.to raise_error(TextyRecord::Exceptions::RecordNotFound) }
  it { expect { TextyRecordPage.execute(:create) }.to raise_error(TextyRecord::Exceptions::InvalidCommand) }

  describe 'validations' do
    context 'when the primary key not uniq' do
      before { TextyRecordPage.new(id: 1, title: '123').save }
      it 'should have validation errors' do
        page = TextyRecordPage.new(id: 1, title: '123')
        expect(page.save).to eq(false)
        expect(page.validation_errors[:id].count).to eq(1)
      end
    end

    context 'when the primary key is String' do
      it 'should have validation errors' do
        page = TextyRecordPage.new(id: 'I\'amPrimaryKey')
        expect(page.save).to eq(false)
        expect(page.validation_errors[:id].count).to eq(1)
      end
    end
  end
end
