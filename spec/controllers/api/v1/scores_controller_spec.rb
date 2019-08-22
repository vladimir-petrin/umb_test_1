require 'rails_helper'

RSpec.describe Api::V1::PostsController, type: :request do


  describe '#create' do
    let!(:post_instance) { create(:post) }
    let!(:score) { create(:score, post: post_instance, value: 4) }

    context 'when post exists and value valid' do
      it 'creates score' do
        expect do
          post api_v1_post_scores_path(post_instance), params: { value: 5 }
        end.to change { post_instance.scores.count }.from(1).to(2)
      end

      it 'changes average score' do
        expect do
          post api_v1_post_scores_path(post_instance), params: { value: 5 }
        end.to change { post_instance.reload.avg_score }.from(400).to(450)
      end

      it 'return response with 200 status' do
        post api_v1_post_scores_path(post_instance), params: { value: 5 }
        expect(response).to have_http_status(200)
      end

      it 'returns new post average score' do
        post api_v1_post_scores_path(post_instance), params: { value: 5 }
        json = JSON.parse(response.body)
        expect(json).to match("avg_score"=>450)
      end
    end

    context 'when post does not exist' do
      before do
        post "/api/v1/posts/#{post_instance.id + 1}/scores", params: { value: 5 }
      end

      it 'returns response with 404 status' do
        expect(response).to have_http_status(404)
      end
    end

    context 'when value invalid' do
      before do
        post api_v1_post_scores_path(post_instance), params: { value: 6 }
      end

      it 'returns response with 422 status' do
        expect(response).to have_http_status(422)
      end

      it 'returns errors' do
        json = JSON.parse(response.body)
        expect(json).to eq("value"=>["must be less than or equal to 5"])
      end
    end
  end
end