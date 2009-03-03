require 'test_helper'

class ArticlesControllerTest < ActionController::TestCase
  include SourceHelper

  def setup
    login_as(:quentin)
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:articles)
  end

  def test_should_get_index_csv
    get :index, :format => "csv"
    assert_response :success
    assert_equal @response.content_type, "text/csv"
  end

  def test_should_order_by_doi_by_default
    get :index, :format => "csv"
    assert_response :success
    results = @response.body.split("\n")[1..-1]
    assert results[0].starts_with?(articles(:not_stale).doi)
    assert results[1].starts_with?(articles(:stale).doi)
  end

  def test_should_order_by_doi_by_published_on
    get :index, :format => "csv", :order => "published_on"
    assert_response :success
    results = @response.body.split("\n")[1..-1]
    assert results[0].starts_with?(articles(:not_stale).doi)
    assert results[1].starts_with?(articles(:stale).doi)
  end

  def test_should_filter_by_query
    get :index, :format => "csv", :query => "pgen"
    assert_response :success
    results = @response.body.split("\n")[1..-1]
    assert results.size == 1
    assert results[0].starts_with?(articles(:stale).doi)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_article
    assert_difference('Article.count') do
      post :create, :article => { :doi => "10.0/dummy" }
    end

    assert_redirected_to article_path(assigns(:article))
  end

  def test_should_require_doi
    post :create, :article => {}
    assert_tag :tag => "div", 
               :attributes => { :class => "fieldWithErrors" },
               :descendant => { :tag => "input", 
                                :attributes => { :id => "article_doi" } }
  end

  def test_should_show_article
    get :show, :id => article_one_id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => article_one_id
    assert_response :success
  end

  def test_should_update_article
    put :update, :id => article_one_id, :article => { }
    assert_redirected_to article_path(assigns(:article))
  end

  def test_should_destroy_article
    assert_difference('Article.count', -1) do
      delete :destroy, :id => article_one_id
    end

    assert_redirected_to articles_path
  end

  def self.make_format_test(format_name, options={})
    format = options.delete(:format) || format_name
    content_type = "application/#{options.delete(:type) || format}"
    define_method("test_should_generate_#{format_name}_format") do
      options[:id] = "#{article_one_id}.#{format}"
      get :show, options
      assert_response :success
      assert_equal @response.content_type, content_type
      if format == "xml"
        result = parse_xml(@response.body)
        citations_count = result.find("//article").first.attributes["citations_count"]
      elsif format == "json"
        body = @response.body
        body = body[options[:callback].length+1..-3] \
          unless options[:callback].nil?
        citations_count = ActiveSupport::JSON.decode(body)["article"]["citations_count"]
      end
      assert Integer(citations_count)
    end
  end
  make_format_test("xml")
  make_format_test("xml_with_citations", :format => "xml", :citations => "1")
  make_format_test("xml_with_history", :format => "xml", :history => "1")
  make_format_test("json")
  make_format_test("jsonp", :format => "json", :callback => "c",
    :type => "javascript")
  make_format_test("jsonp_with_citations", :format => "json", :callback => "c",
    :type => "javascript", :citations => "1")
  make_format_test("jsonp_with_history", :format => "json", :callback => "c",
    :type => "javascript", :history => "1")

private
  def article_one_id
    articles(:not_stale).to_param.gsub("/", "%2F")
  end
end
