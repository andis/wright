require_relative '../spec_helper'

require 'wright/resource/file'
require 'fileutils'

describe Wright::Resource::File do
  before(:each) do
    @filename = 'foo'
    FakeFS { FileUtils.mkdir_p Dir.tmpdir }
  end

  after(:each) { FakeFS::FileSystem.clear }

  describe '#create!' do
    it 'should create files' do
      FakeFS do
        file = Wright::Resource::File.new(@filename)
        file.content = 'hello world'
        file.create!
        assert File.file?(@filename)
        File.read(@filename).must_equal 'hello world'
      end
    end

    it 'should create empty files when content is not set' do
      FakeFS do
        file = Wright::Resource::File.new(@filename)
        file.create!
        assert File.file?(@filename)
        File.read(@filename).must_equal ''
      end
    end

    it 'should create files with the correct owner, group and mode' do
      FakeFS do
        file = Wright::Resource::File.new(@filename)
        file.content = 'hello world'
        file.owner = 23
        file.group = 42
        file.mode = '700'
        file.create!
        assert File.file?(@filename)
        File.read(@filename).must_equal 'hello world'
        Util::File.file_owner(@filename).must_equal 23
        Util::File.file_group(@filename).must_equal 42
      end
    end

    it 'should update existing files' do
      FakeFS do
        FileUtils.touch(@filename)
        FileUtils.chmod(0600, @filename)
        FileUtils.chown(0, 0, @filename)
        file = Wright::Resource::File.new(@filename)
        file.mode = '644'
        file.owner = 23
        file.group = 42
        file.content = 'hello world'
        file.create!
        File.read(@filename).must_equal 'hello world'
        Wright::Util::File.file_mode(@filename).must_equal 0644
        Wright::Util::File.file_owner(@filename).must_equal 23
        Wright::Util::File.file_group(@filename).must_equal 42
      end
    end

    it 'should not overwrite existing files when content is nil' do
      FakeFS do
        File.write(@filename, 'old content')
        File.chmod(0600, @filename)
        file = Wright::Resource::File.new(@filename)
        file.mode = '644'
        file.create!
        File.read(@filename).must_equal 'old content'
        Wright::Util::File.file_mode(@filename).must_equal 0644
      end
    end

    it 'should not change up-to-date files' do
      FakeFS do
        File.write(@filename, 'hello world')
        FileUtils.chmod(0600, @filename)
        FileUtils.chown(23, 42, @filename)
        file = Wright::Resource::File.new(@filename)
        file.mode = '600'
        file.owner = 23
        file.group = 42
        file.content = 'hello world'
        file.create!
        File.read(@filename).must_equal 'hello world'
        Wright::Util::File.file_mode(@filename).must_equal 0600
        Wright::Util::File.file_owner(@filename).must_equal 23
        Wright::Util::File.file_group(@filename).must_equal 42
      end
    end

    it 'should throw an exception if target is a directory' do
      FakeFS do
        FileUtils.mkdir_p(@filename)
        file = Wright::Resource::File.new(@filename)
        proc { file.create! }.must_raise Errno::EISDIR
        assert File.directory?(@filename)
      end
    end

    # it 'should support owner:group notation' do
    #   FakeFS do
    #     FileUtils.mkdir_p(@dirname)
    #     FileUtils.chown(23, 45, @dirname)
    #     owner = Etc.getpwuid(Process.uid).name
    #     group = Etc.getgrgid(Process.gid).name
    #     dir = Wright::Resource::Directory.new(@dirname)
    #     dir.owner = "#{owner}:#{group}"
    #     dir.create!
    #     Wright::Util::File.file_owner(@dirname).must_equal Process.uid
    #     Wright::Util::File.file_group(@dirname).must_equal Process.gid
    #   end
    # end

    # it 'should raise an exception when setting invalid an owner/group' do
    #   dir = Wright::Resource::Directory.new(@dirname)
    #   user = 'this_user_doesnt_exist'
    #   group = 'this_group_doesnt_exist'
    #   proc { dir.owner = user }.must_raise ArgumentError
    #   proc { dir.group = group }.must_raise ArgumentError
    #   proc { dir.owner = "#{user}:#{group}" }.must_raise ArgumentError
    # end

    # it 'should raise an exception if there is a regular file at path' do
    #   FakeFS do
    #     FileUtils.touch(@dirname)
    #     dir = Wright::Resource::Directory.new(@dirname)
    #     proc { dir.create! }.must_raise Errno::EEXIST
    #   end
    # end
  end

  describe '#remove!' do
    it 'should remove files' do
      FakeFS do
        FileUtils.touch(@filename)
        file = Wright::Resource::File.new(@filename)
        file.remove!
        assert !File.exist?(@filename)
      end
    end

    it 'should not remove directories' do
      FakeFS do
        FileUtils.mkdir_p(@filename)
        file = Wright::Resource::File.new(@filename)
        proc { file.remove! }.must_raise Errno::EISDIR
        assert File.directory?(@filename)
      end
    end

    it 'should remove symlinks' do
      FakeFS do
        FileUtils.touch('target_file')
        FileUtils.ln_s('target_file', @filename)
        file = Wright::Resource::File.new(@filename)
        assert File.symlink?(@filename)
        file.remove!
        assert !File.symlink?(@filename)
        assert File.exist?('target_file')
      end
    end
  end
end