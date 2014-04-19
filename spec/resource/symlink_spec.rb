require_relative '../spec_helper'

require 'wright/resource/symlink'
require 'fileutils'

describe Wright::Resource::Symlink do
  before(:each) do
    @target = 'foo'
    @link_name = 'bar'
  end

  after(:each) { FakeFS::FileSystem.clear }

  def link_resource(target, link_name)
    link = Wright::Resource::Symlink.new(link_name)
    link.to = target
    link
  end

  describe '#create' do
    it 'should create symlinks' do
      FakeFS do
        link = link_resource(@target, @link_name)
        link.create
        File.symlink?(@link_name).must_equal true
        File.readlink(@link_name).must_equal @target
      end
    end

    it 'should update symlinks to files' do
      FakeFS do
        link = link_resource(@target, @link_name)
        FileUtils.ln_sf('oldtarget', @link_name)
        link.create

        assert File.symlink?(@link_name)
        File.readlink(@link_name).must_equal @target
      end
    end

    it 'should update symlinks to directories' do
      FakeFS do
        link = link_resource(@target, @link_name)
        FileUtils.mkdir_p('somedir')
        FileUtils.ln_s('somedir', @link_name)
        link.create

        assert File.symlink?(@link_name)
        File.readlink(@link_name).must_equal @target
      end
    end

    it 'should not overwrite existing files' do
      FakeFS do
        file_content = 'Hello world'
        File.write(@link_name, file_content)
        link = link_resource(@target, @link_name)
        -> { link.create }.must_raise Errno::EEXIST
        File.read(@link_name).must_equal file_content
      end
    end
  end

  describe '#remove' do
    it 'should remove existing symlinks' do
      FakeFS do
        link = Wright::Resource::Symlink.new(@link_name)
        FileUtils.touch(@target)
        FileUtils.ln_s(@target, @link_name)

        File.exist?(@target).must_equal true
        File.symlink?(@link_name).must_equal true
        link.remove
        File.exist?(@target).must_equal true
        File.symlink?(@link_name).must_equal false
      end
    end

    it 'should not remove existing regular files' do
      FakeFS do
        FileUtils.touch(@link_name)
        link = Wright::Resource::Symlink.new(@link_name)
        File.exist?(@link_name).must_equal true
        -> { link.remove }.must_raise RuntimeError
        File.exist?(@link_name).must_equal true
      end
    end
  end
end
