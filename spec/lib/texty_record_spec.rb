require 'spec_helper'
APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
$: << File.join(APP_ROOT, 'lib')
require 'texty_record'

class TextyRecordPage < TextyRecord::Base
  @@storage_file_path = File.join(File.dirname(__FILE__), '..', 'database.json')
end


describe TextyRecord do
  before do
    File.open(TextyRecordPage.storage_file_path, 'w+') do |f|
      f.write({}.to_json)
    end

    @page_first = TextyRecordPage.new(title: 'Title 1', content: 'Test 1').save
    @page_second = TextyRecordPage.new(title: 'Title 2', content: 'Test 2').save
    @page_third = TextyRecordPage.new(title: 'Title 3', content: 'Test 3').save
  end

  it 'should have attribute methods' do
    texty_record_page = TextyRecordPage.first
    texty_record_page.attributes.keys.each do |attribute|
      texty_record_page.should respond_to attribute
      texty_record_page.send(attribute).should eq texty_record_page.attributes[attribute]
    end
  end

  it 'should fetch all' do
    TextyRecordPage.all.length.should eq 3
  end

  it 'should fetch first' do
    TextyRecordPage.first.title.should eq 'Title 1'
  end

  it 'should fetch last' do
    TextyRecordPage.last.title.should eq 'Title 3'
  end

  it 'should destroy record' do
    TextyRecordPage.last.destroy
    TextyRecordPage.all.length.should eq 2
  end

  it 'should save record' do
    TextyRecordPage.new(title: '123', content: '123').save
    TextyRecordPage.all.length.should eq 4
    TextyRecordPage.last.title.should eq '123'
  end

  it 'should find by id' do
    TextyRecordPage.find(@page_second.id).attributes.should eq @page_second.attributes
  end

  it 'should fetch all' do
    TextyRecordPage.all.length.should eq 3
  end
end
