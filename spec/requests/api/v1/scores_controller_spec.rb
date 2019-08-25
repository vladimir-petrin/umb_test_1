require 'rails_helper'

RSpec.shared_examples :create_score_contract_failure do |params, expected_errors|
  let!(:post_instance) { create(:post) }
  let!(:avg_score) { create(:avg_score, post: post_instance, avg_value: 0) }

  it 'does not create post' do
    expect do
      post api_v1_post_scores_path(post_instance), params: params
    end.to_not change { Score.count }.from(0)
  end

  it 'returns response with 422 status' do
    post api_v1_post_scores_path(post_instance), params: params
    expect(response).to have_http_status(422)
  end

  it 'returns errors' do
    post api_v1_post_scores_path(post_instance), params: params
    json = JSON.parse(response.body)
    expect(json).to match(expected_errors)
  end
end

RSpec.describe Api::V1::PostsController, type: :request do
  describe '#create' do
    context 'when post exists and value valid' do
      let!(:post_instance) { create(:post) }
      let!(:score) { create(:score, post: post_instance, value: 4) }

      it 'creates score' do
        expect do
          post api_v1_post_scores_path(post_instance), params: { value: 5 }
        end.to change { post_instance.scores.count }.from(1).to(2)
      end

      it 'changes average score' do
        expect do
          post api_v1_post_scores_path(post_instance), params: { value: 5 }
        end.to change { post_instance.reload.avg_score_value }.from(400).to(450)
      end

      it 'return response with 200 status' do
        post api_v1_post_scores_path(post_instance), params: { value: 5 }
        expect(response).to have_http_status(200)
      end

      it 'returns new post average score' do
        post api_v1_post_scores_path(post_instance), params: { value: 5 }
        json = JSON.parse(response.body)
        expect(json).to match("avg_score"=>4.5)
      end
    end

    context 'when post does not exist' do
      before do
        post "/api/v1/posts/999999/scores", params: { value: 5 }
      end

      it 'returns response with 404 status' do
        expect(response).to have_http_status(404)
      end
    end

    context 'when value invalid' do
      context 'when value is not integer and can not be converted to it' do
        it_behaves_like :create_score_contract_failure,
                        { value: { non: :convertable} },
                        { "value"=>["must be an integer"] }
      end

      context 'when value is less than 1' do
        it_behaves_like :create_score_contract_failure,
                        { value: 0 },
                        { "value"=>["must be greater than or equal to 1"] }
      end

      context 'when value is greater than 5' do
        it_behaves_like :create_score_contract_failure,
                        { value: 6 },
                        { "value"=>["must be less than or equal to 5"] }
      end
    end
  end
end