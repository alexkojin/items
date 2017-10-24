require 'rails_helper'

RSpec.describe Items do
  let(:list) { ['1', '2', '3', '4'] }

  before do
    Items.config.folder = '/tmp'
    Items.cleanup
  end

  it 'save object to file' do
    i = Items.get('list'){ list }

    expect(Items.exists?('list')).to eq(true)
  end

  it 'creates missed folders' do
    i = Items.get('alphabet/page/1'){ list }

    expect(Items.exists?('alphabet/page/1')).to eq(true)

    file_path = File.join(Items.config.folder, 'alphabet/page/1.items')
    expect(File.exists?(file_path)).to eql(true)
  end

  it 'load object from file' do
    i = Items.get('list') { list }
    i.index = 2
    i.save

    ii = Items.get('list') { list }
    expect(ii.index).to eql(2)
    expect(ii.items).to eql(list)
  end

  it 'save and load additional info' do
    i = Items.get('list', info: { name: 'alex' }) { list }

    ii = Items.get('list') { list }
    expect(ii.info).to eql({name: 'alex'})
  end

  it 'iterate over items' do
    items = Items.get('list') { list }

    items.each {|item| }

    ii = Items.get('list') { list }
    expect(ii.index).to eql(3)
  end
end
