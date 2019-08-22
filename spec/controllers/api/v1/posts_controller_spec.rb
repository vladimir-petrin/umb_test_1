require 'rails_helper'

RSpec.describe Api::V1::PostsController, type: :request do
  describe '#index' do
    let!(:posts) do
      (0..5).map do
        create(:post)
      end
    end

    let!(:scores) do
      (0..4).map do |index|
        create(:score, post: posts[index], value: index + 1)
      end
    end

    it 'return posts ordered by average score' do
      get '/api/v1/posts'

      json = JSON.parse(response.body)

      expect(json).to eq(
        [
          posts[4].as_json(only: %i[title content]),
          posts[3].as_json(only: %i[title content]),
          posts[2].as_json(only: %i[title content]),
          posts[1].as_json(only: %i[title content]),
          posts[0].as_json(only: %i[title content]),
          posts[5].as_json(only: %i[title content]),
        ]
      )
    end
  end

  describe '#create' do
    context 'valid params' do
      let(:params) do
        {
          login: 'vasya',
          title: 'Test title',
          content: 'Test content',
          author_ip: '192.168.1.1'
        }
      end

      context 'when user exists' do
        let!(:user) { create(:user, login: 'vasya') }

        it 'creates post' do
          expect do
            post '/api/v1/posts', params: params
          end.to change { user.posts.count }.from(0).to(1)
        end

        it 'returns response with 200 status' do
          post '/api/v1/posts', params: params
          expect(response).to have_http_status(200)
        end

        it 'returns response with post' do
          post '/api/v1/posts', params: params
          json = JSON.parse(response.body)
          expect(json).to include(
            'user_id' => user.id,
            'title' => 'Test title',
            'content' => 'Test content',
            'author_ip' => '192.168.1.1',
            'avg_score' => nil
          )
        end
      end

      context 'when user does not exist' do
        it 'creates user' do
          expect do
            post '/api/v1/posts', params: params
          end.to change { User.count }.from(0).to(1)
        end

        it 'creates post' do
          expect do
            post '/api/v1/posts', params: params
          end.to change { Post.count }.from(0).to(1)
        end

        it 'returns response with 200 status' do
          post '/api/v1/posts', params: params
          expect(response).to have_http_status(200)
        end

        it 'returns response with post' do
          post '/api/v1/posts', params: params
          json = JSON.parse(response.body)
          expect(json).to include(
            'title' => 'Test title',
            'content' => 'Test content',
            'author_ip' => '192.168.1.1',
            'avg_score' => nil
          )
        end
      end
    end

    context 'invalid params' do
      let(:params) do
        {
          login: ['not_a_string'],
          content: '',
          author_ip: 'abra-kadabra'
        }
      end

      before do
        post '/api/v1/posts', params: params
      end

      it 'returns response with 422 status' do
        expect(response).to have_http_status(422)
      end

      it 'returns errors' do
        json = JSON.parse(response.body)
        expect(json).to match(
          "login"=>["must be a string"],
          "title"=>["is missing"],
          "content"=>["must be filled"],
          "author_ip"=>["not a vaild IPv4 or IPv6 format"]
        )
      end
    end
  end
end