require 'rails_helper'

RSpec.shared_examples :create_post_failure do |params, expected_errors|
  it 'does not create post' do
    expect do
      post '/api/v1/posts', params: params
    end.to_not change { Post.count }.from(0)
  end

  it 'returns response with 422 status' do
    post '/api/v1/posts', params: params
    expect(response).to have_http_status(422)
  end

  it 'returns errors' do
    post '/api/v1/posts', params: params
    json = JSON.parse(response.body)
    expect(json).to match(expected_errors)
  end
end

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

    it 'return posts ordered by average score (desc, nulls last)' do
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

    context 'when limit provided' do
      it 'return requested number of records' do
        get '/api/v1/posts', params: { limit: 3 }

        json = JSON.parse(response.body)

        expect(json).to eq(
          [
            posts[4].as_json(only: %i[title content]),
            posts[3].as_json(only: %i[title content]),
            posts[2].as_json(only: %i[title content])
          ]
        )
      end
    end
  end

  describe '#create' do
    context 'valid params' do
      let(:params) do
        {
          login: 'leia-organa',
          title: 'Lorem ipsum',
          content: 'dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
          author_ip: '192.168.1.1'
        }
      end

      context 'when user exists' do
        let!(:user) { create(:user, login: 'leia-organa') }

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
            'title' => 'Lorem ipsum',
            'content' => 'dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
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
            'user_id' => User.first.id,
            'title' => 'Lorem ipsum',
            'content' => 'dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            'author_ip' => '192.168.1.1',
            'avg_score' => nil
          )
        end
      end
    end

    context 'invalid params' do
      context 'login not a string' do
        it_behaves_like :create_post_failure,
                        {
                          login: ['leia-organa'],
                          title: 'Lorem ipsum',
                          content: 'dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                          author_ip: '192.168.1.1'
                        },
                        { "login" => ["must be a string"] }
      end

      context 'login missing' do
        it_behaves_like :create_post_failure,
                        {
                          title: 'Lorem ipsum',
                          content: 'dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                          author_ip: '192.168.1.1'
                        },
                        { "login" => ["is missing"] }
      end

      context 'login empty' do
        it_behaves_like :create_post_failure,
                        {
                          login: '',
                          title: 'Lorem ipsum',
                          content: 'dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                          author_ip: '192.168.1.1'
                        },
                        { "login" => ["must be filled"] }
      end

      context 'login does not match login regexp' do
        it_behaves_like :create_post_failure,
                        {
                          login: 'leia~organa',
                          title: 'Lorem ipsum',
                          content: 'dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                          author_ip: '192.168.1.1'
                        },
                        { "login" => ["not a valid login"] }
      end

      context 'title not a string' do
        it_behaves_like :create_post_failure,
                        {
                          login: 'leia-organa',
                          title: ['Lorem ipsum'],
                          content: 'dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                          author_ip: '192.168.1.1'
                        },
                        { "title" => ["must be a string"] }
      end

      context 'title missing' do
        it_behaves_like :create_post_failure,
                        {
                          login: 'leia-organa',
                          content: 'dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                          author_ip: '192.168.1.1'
                        },
                        { "title" => ["is missing"] }
      end

      context 'title empty' do
        it_behaves_like :create_post_failure,
                        {
                          login: 'leia-organa',
                          title: '',
                          content: 'dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                          author_ip: '192.168.1.1'
                        },
                        { "title" => ["must be filled"] }
      end

      context 'content not a string' do
        it_behaves_like :create_post_failure,
                        {
                          login: 'leia-organa',
                          title: 'Lorem ipsum',
                          content: ['dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'],
                          author_ip: '192.168.1.1'
                        },
                        { "content" => ["must be a string"] }
      end

      context 'content missing' do
        it_behaves_like :create_post_failure,
                        {
                          login: 'leia-organa',
                          title: 'Lorem ipsum',
                          author_ip: '192.168.1.1'
                        },
                        { "content" => ["is missing"] }
      end

      context 'content empty' do
        it_behaves_like :create_post_failure,
                        {
                          login: 'leia-organa',
                          title: 'Lorem ipsum',
                          content: '',
                          author_ip: '192.168.1.1'
                        },
                        { "content" => ["must be filled"] }
      end

      context 'author_ip not a string' do
        it_behaves_like :create_post_failure,
                        {
                          login: 'leia-organa',
                          title: 'Lorem ipsum',
                          content: 'dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                          author_ip: ['192.168.1.1']
                        },
                        { "author_ip" => ["must be a string"] }
      end

      context 'author_ip missing' do
        it_behaves_like :create_post_failure,
                        {
                          login: 'leia-organa',
                          title: 'Lorem ipsum',
                          content: 'dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
                        },
                        { "author_ip" => ["is missing"] }
      end

      context 'author_ip empty' do
        it_behaves_like :create_post_failure,
                        {
                          login: 'leia-organa',
                          title: 'Lorem ipsum',
                          content: 'dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                          author_ip: ''
                        },
                        { "author_ip" => ["must be filled"] }
      end

      context 'author_ip does not match IP regexp' do
        it_behaves_like :create_post_failure,
                        {
                          login: 'leia-organa',
                          title: 'Lorem ipsum',
                          content: 'dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                          author_ip: '192.168.1.zzz'
                        },
                        { "author_ip" => ["not a vaild IPv4 or IPv6 format"] }
      end
    end
  end
end