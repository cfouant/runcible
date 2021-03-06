require 'rubygems'
require 'minitest/autorun'

require './lib/runcible'
require './test/support/repository_support'

module Resources
  module TestContentBase
    def setup
      @resource = TestRuncible.server.resources.content
    end
  end

  class TestCreateUploadRequest < MiniTest::Unit::TestCase
    include TestContentBase

    def test_create_upload_request
      response = @resource.create_upload_request

      assert response.is_a? Hash
      assert_equal 201, response.code
    end
  end

  class TestUploadBits < MiniTest::Unit::TestCase
    include TestContentBase

    def test_upload_bits
      test_request = @resource.create_upload_request
      response = @resource.upload_bits(test_request['upload_id'], '0', 'abcde')
      assert_equal 200, response.code
    end
  end

  class TestImportIntoRepo < MiniTest::Unit::TestCase
    include TestContentBase

    def test_import_into_repo
      test_unit_key = {'checksumtype' => 'sha256',
                       'checksum' => '5e9fb809128d23a3e25d0c5fd38dd5d37d4ebceae7c6af8f15fed93e39d3145f',
                       'epoch' => '0',
                       'version' => '8.3.3',
                       'release' => '1.elfake',
                       'arch' => 'noarch',
                       'name' => 'recons'}

      self.class.support = RepositorySupport.new
      self.class.support.create_and_sync_repo(:importer_and_distributor => true)
      response = @resource.import_into_repo(RepositorySupport.repo_id, 'rpm', 'uvwx', test_unit_key)
      assert_async_response(response)
    ensure
      self.class.support.destroy_repo
    end
  end

  class TestDeleteUploadRequest < MiniTest::Unit::TestCase
    include TestContentBase

    def test_delete_upload_request
      test_request = @resource.create_upload_request
      response = @resource.delete_upload_request(test_request['upload_id'])
      assert_equal 200, response.code
    end
  end

  class TestListAllUploadRequests < MiniTest::Unit::TestCase
    include TestContentBase

    def test_list_all_requests
      response = @resource.list_all_requests

      assert_equal 200, response.code
    end
  end

  class TestOrphans < MiniTest::Unit::TestCase
    include TestContentBase

    def test_list_orphans
      assert @resource.list_orphans.is_a?(Hash)
    end

    def test_remove_orphans
      assert @resource.remove_orphans.is_a?(Hash)
    end
  end
end
