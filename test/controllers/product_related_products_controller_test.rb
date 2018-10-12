# frozen_string_literal: true

require 'test_helper'

class ProductRelatedProductsControllerTest < ActionController::TestCase
  setup do
    @product_related_product = product_related_products(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:product_related_products)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create product_related_product' do
    assert_difference('ProductRelatedProduct.count') do
      post :create, product_related_product: { product_id: @product_related_product.product_id, related_prooduct: @product_related_product.related_prooduct }
    end

    assert_redirected_to product_related_product_path(assigns(:product_related_product))
  end

  test 'should show product_related_product' do
    get :show, id: @product_related_product
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @product_related_product
    assert_response :success
  end

  test 'should update product_related_product' do
    patch :update, id: @product_related_product, product_related_product: { product_id: @product_related_product.product_id, related_prooduct: @product_related_product.related_prooduct }
    assert_redirected_to product_related_product_path(assigns(:product_related_product))
  end

  test 'should destroy product_related_product' do
    assert_difference('ProductRelatedProduct.count', -1) do
      delete :destroy, id: @product_related_product
    end

    assert_redirected_to product_related_products_path
  end
end
