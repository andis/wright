require_relative '../spec_helper'
require 'wright/contrib/add_apt_repo'

# Test module
module AddAptRepoSpec
  describe 'AddAptRepo#call' do
    # Helper class
    module MockRole
      def mock
        @mock ||= Minitest::Mock.new
      end
    end

    # Helper class
    class MockWright
      def file(_file)
        self
      end

      def directory(_dir)
        self
      end

      def updated?
        'not used'
      end
    end

    def aar_opts(opts = {})
      {
        name:    'none',
        content: 'none',
        key_id:  'none'
      }.merge(opts)
    end

    it 'runs system command to fetch keyfile if empty' do
      aar = AddAptRepo.new(MockWright.new, aar_opts)
      aar.extend(MockRole)
      aar.mock.expect(:system, 'truthy')

      def aar.system(*_args)
        mock.system
        true
      end

      File.stub(:zero?, true) do
        aar.call
      end

      aar.mock.verify
    end

    it 'does not run system command when keyfile has content' do
      aar = AddAptRepo.new(MockWright.new, aar_opts)
      aar.extend(MockRole)

      def aar.system(*_args)
        mock.system
        true
      end

      File.stub(:zero?, false) do
        aar.call
      end

      aar.mock.verify
    end

    it 'delegates listfile creation to wright' do
      mock_wright = MockWright.new
      mock_wright.extend(MockRole)
      mock_wright.mock.expect(:file, mock_wright, [String])

      def mock_wright.file(*_file)
        mock.file('asdf')
        self
      end

      AddAptRepo.new(mock_wright, aar_opts)
        .send(:create_listfile)

      mock_wright.mock.verify
    end

    it 'handles content string' do
      opts = aar_opts(content: 'foo')
      content = AddAptRepo.new(MockWright.new, opts)
                .send(:listfile_content)

      assert_equal "foo\n", content
    end

    it 'handles content array' do
      opts = aar_opts(content: ['foo', 'foo-src'])
      content = AddAptRepo.new(MockWright.new, opts)
                .send(:listfile_content)

      assert_equal "foo\nfoo-src\n", content
    end
  end
end
