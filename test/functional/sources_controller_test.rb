require 'test_helper'

class UnconfiguredSource < Source
end

class SourcesControllerTest < ActionController::TestCase
  def setup
    login_as(:quentin)
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:sources)
  end

  def test_should_get_new
    get :new, :class => "UnconfiguredSource"
    assert_response :success
  end

  def test_should_create_source
    assert_difference('Source.count') do
      post :create, :source => {}, :class => "UnconfiguredSource"
    end

    assert_redirected_to sources_path
  end

  def test_should_show_source
    get :show, :id => sources(:crossref).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => sources(:crossref).id
    assert_response :success
  end

  def test_should_update_source
    put :update, :id => sources(:crossref).id, 
                 :source => { :class => sources(:crossref).class.name }
    assert_redirected_to sources_path
  end

  def test_should_destroy_source
    assert_difference('Source.count', -1) do
      delete :destroy, :id => sources(:crossref).id
    end

    assert_redirected_to sources_path
  end
end
